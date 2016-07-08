
// Copyright (c) 2016 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import BRAM::*;

// BRAM with 1 write port and 1 read port
interface RWBram#(type addrT, type dataT);
    method Action wrReq(addrT a, dataT d);
    method Action rdReq(addrT a);
    method ActionValue#(dataT) rdResp;
endinterface

module mkRWBram(RWBram#(addrT, dataT)) provisos(
    Bits#(addrT, a__), Bits#(dataT, b__));

    BRAM_Configure cfg = defaultValue;
    BRAM2Port#(addrT, dataT) ram <- mkBRAM2Server(cfg);

    // port A: read
    // port B: write

    method Action wrReq(addrT a, dataT d);
        ram.portB.request.put(BRAMRequest {
            write: True,
            responseOnWrite: False,
            address: a,
            datain: d
        });
    endmethod

    method Action rdReq(addrT a);
        ram.portA.request.put(BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: a,
            datain: ?
        });
    endmethod

    method ActionValue#(dataT) rdResp;
        let d <- ram.portA.response.get;
        return d;
    endmethod
endmodule
