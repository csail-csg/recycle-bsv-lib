
// Copyright (c) 2017 Massachusetts Institute of Technology

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

import BuildVector::*;
import Clocks::*;
import FIFO::*;
import List::*;
import RegFile::*;
import StmtFSM::*;
import Vector::*;

import MemUtil::*;
import Port::*;

import BlueCheck::*;

module [BlueCheck] checkMemBus(Empty);
    AtomicBRAM#(10, 2, TDiv#(1024, 4)) referenceBRAM <- mkAtomicBRAM;

    Vector#(4, AtomicBRAM#(10, 2, TDiv#(1024, 4))) bankBRAM <- replicateM(mkAtomicBRAM);

    Vector#(4, MemBusItem#(AtomicMemReq#(10, 2), AtomicMemResp#(2), 10)) busMap = vec(
        MemBusItem{ addr_mask: 10'h300, addr_match: 10'h000, ifc: bankBRAM[0].portA },
        MemBusItem{ addr_mask: 10'h300, addr_match: 10'h100, ifc: bankBRAM[1].portA },
        MemBusItem{ addr_mask: 10'h300, addr_match: 10'h200, ifc: bankBRAM[2].portA },
        MemBusItem{ addr_mask: 10'h300, addr_match: 10'h300, ifc: bankBRAM[3].portA });

    Vector#(2, AtomicMemServerPort#(10, 2)) busPorts <- mkMemBus( busMap );

    equiv( "request.enq", referenceBRAM.portA.request.enq, busPorts[0].request.enq );
    equiv( "response.first", referenceBRAM.portA.response.first, busPorts[0].response.first );
    equiv( "response.deq", referenceBRAM.portA.response.deq, busPorts[0].response.deq );
endmodule

(* synthesize *)
module [Module] mkMemBusCheck(Empty);
    blueCheck(checkMemBus);
endmodule
