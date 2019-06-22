
// Copyright (c) 2019 Massachusetts Institute of Technology
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Vector::*;

// This package uses Arrays for EHR interfaces in order to avoid needing
// a typeclass to say if there is an implementation of a VerilogEHR with
// the given number of ports.
typedef Array#(Reg#(t)) VerilogEHR#(type t);

% for num_ports in range(1, max_num_ports+1):
(* always_ready *)
interface VerilogEHR_${num_ports}_Raw#(numeric type dataSz);
 % for i in range(num_ports):
    method Bit#(dataSz) read_${i};
    method Action write_${i}(Bit#(dataSz) x);
 % endfor
endinterface

import "BVI" EHR_${num_ports} =
module mkVerilogEHR_${num_ports}_Raw#(Bit#(dataSz) init)(VerilogEHR_${num_ports}_Raw#(dataSz));
    parameter DATA_SZ = valueOf(dataSz);
    parameter RESET_VAL = init;

    default_clock clk(CLK);
    default_reset rst(RST_N);

 % for i in range(num_ports):
    method read_${i} read_${i};
    method write_${i}(write_${i}) enable (EN_write_${i});
 % endfor

    // intra-port scheduling
 % for i in range(num_ports):
    schedule (read_${i}) CF (read_${i});
    schedule (read_${i}) SB (write_${i});
    schedule (write_${i}) SBR (write_${i});
 % endfor

    // inter-port scheduling
 % for i in range(num_ports):
  % for j in range(i+1, num_ports):
    schedule (read_${i}, write_${i}) SB (read_${j}, write_${j});
  % endfor
 % endfor

    // paths
 % for i in range(num_ports):
  % for j in range(i+1, num_ports):
    path (write_${i}, read_${j});
    path (EN_write_${i}, read_${j});
  % endfor
 % endfor
endmodule

import "BVI" EHRU_${num_ports} =
module mkVerilogEHRU_${num_ports}_Raw(VerilogEHR_${num_ports}_Raw#(dataSz));
    parameter DATA_SZ = valueOf(dataSz);

    default_clock clk(CLK);
    no_reset;

 % for i in range(num_ports):
    method read_${i} read_${i};
    method write_${i}(write_${i}) enable (EN_write_${i});
 % endfor

    // intra-port scheduling
 % for i in range(num_ports):
    schedule (read_${i}) CF (read_${i});
    schedule (read_${i}) SB (write_${i});
    schedule (write_${i}) SBR (write_${i});
 % endfor

    // inter-port scheduling
 % for i in range(num_ports):
  % for j in range(i+1, num_ports):
    schedule (read_${i}, write_${i}) SB (read_${j}, write_${j});
  % endfor
 % endfor

    // paths
 % for i in range(num_ports):
  % for j in range(i+1, num_ports):
    path (write_${i}, read_${j});
    path (EN_write_${i}, read_${j});
  % endfor
 % endfor
endmodule

module mkVerilogEHR_${num_ports}#(dataT init)(VerilogEHR#(dataT)) provisos (Bits#(dataT, dataSz));
    VerilogEHR_${num_ports}_Raw#(dataSz) ehr_raw <- mkVerilogEHR_${num_ports}_Raw(pack(init));
    Reg#(dataT) ehr_ifc[${num_ports}];
    
 % for i in range(num_ports):
    ehr_ifc[${i}] =
        (interface Reg#(dataT);
            method dataT _read;
                return unpack(ehr_raw.read_${i});
            endmethod
            method Action _write(dataT x);
                ehr_raw.write_${i}(pack(x));
            endmethod
        endinterface);
 % endfor

    return ehr_ifc;
endmodule

module mkVerilogEHRU_${num_ports}(VerilogEHR#(dataT)) provisos (Bits#(dataT, dataSz));
    VerilogEHR_${num_ports}_Raw#(dataSz) ehr_raw <- mkVerilogEHRU_${num_ports}_Raw;
    Reg#(dataT) ehr_ifc[${num_ports}];
    
 % for i in range(num_ports):
    ehr_ifc[${i}] =
        (interface Reg#(dataT);
            method dataT _read;
                return unpack(ehr_raw.read_${i});
            endmethod
            method Action _write(dataT x);
                ehr_raw.write_${i}(pack(x));
            endmethod
        endinterface);
 % endfor

    return ehr_ifc;
endmodule

% endfor

module mkVerilogEHR#(Integer num_ports, dataT init)(VerilogEHR#(dataT)) provisos (Bits#(dataT, dataSz));
    Reg#(dataT) _ifc[num_ports];
% for i in range(1,max_num_ports+1):
    if (num_ports == ${i}) begin
        _ifc <- mkVerilogEHR_${i}(init);
    end else
% endfor
    begin
        errorM("num_ports is too large for mkVerilogEHR");
    end
    return _ifc;
endmodule
module mkVerilogEHRU#(Integer num_ports)(VerilogEHR#(dataT)) provisos (Bits#(dataT, dataSz));
    Reg#(dataT) _ifc[num_ports];
% for i in range(1,max_num_ports+1):
    if (num_ports == ${i}) begin
        _ifc <- mkVerilogEHRU_${i};
    end else
% endfor
    begin
        errorM("num_ports is too large for mkVerilogEHRU");
    end
    return _ifc;
endmodule
