import Vector::*;

typedef Vector#(n, Reg#(t)) VerilogEHR#(numeric type n, type t);

typeclass MkVerilogEHR#(numeric type n, type dataT);
    module mkVerilogEHR#(dataT init)(VerilogEHR#(n, dataT));
    module mkVerilogEHRU(VerilogEHR#(n, dataT));
endtypeclass

% for num_ports in range(1, max_num_ports+1):
(* always_ready *)
interface VerilogEHR_${num_ports}#(numeric type dataSz);
 % for i in range(num_ports):
    method Bit#(dataSz) read_${i};
    method Action write_${i}(Bit#(dataSz) x);
 % endfor
endinterface

import "BVI" EHR_${num_ports} =
module mkVerilogEHR_${num_ports}#(Bit#(dataSz) init)(VerilogEHR_${num_ports}#(dataSz));
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
module mkVerilogEHRU_${num_ports}(VerilogEHR_${num_ports}#(dataSz));
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

instance MkVerilogEHR#(${num_ports}, dataT) provisos (Bits#(dataT, dataSz));
    module mkVerilogEHR#(dataT init)(VerilogEHR#(${num_ports}, dataT)) provisos (Bits#(dataT, dataSz));
        VerilogEHR_${num_ports}#(dataSz) ehr <- mkVerilogEHR_${num_ports}(pack(init));
        Vector#(${num_ports}, Reg#(dataT)) _ifc = newVector;
 % for i in range(num_ports):
        _ifc[${i}] = (interface Reg;
                method dataT _read;
                    return unpack(ehr.read_${i});
                endmethod
                method Action _write(dataT x);
                    ehr.write_${i}(pack(x));
                endmethod
            endinterface);
 % endfor
        return _ifc;
    endmodule
    module mkVerilogEHRU(VerilogEHR#(${num_ports}, dataT)) provisos (Bits#(dataT, dataSz));
        VerilogEHR_${num_ports}#(dataSz) ehr <- mkVerilogEHRU_${num_ports};
        Vector#(${num_ports}, Reg#(dataT)) _ifc = newVector;
 % for i in range(num_ports):
        _ifc[${i}] = (interface Reg;
                method dataT _read;
                    return unpack(ehr.read_${i});
                endmethod
                method Action _write(dataT x);
                    ehr.write_${i}(pack(x));
                endmethod
            endinterface);
 % endfor
        return _ifc;
    endmodule
endinstance

% endfor
