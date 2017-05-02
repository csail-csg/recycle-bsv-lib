
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

module [BlueCheck] checkMixedAtomicMemBus(Empty);
    AtomicBRAM#(10, 2, TDiv#(1024, 4)) referenceBRAM <- mkAtomicBRAM;

    Vector#(4, AtomicBRAM#(10, 2, TDiv#(1024, 4))) bankBRAM <- replicateM(mkAtomicBRAM);

    Vector#(4, MixedMemBusItem#(10, 2)) busMap = vec(
        MixedMemBusItem{ addr_mask: 10'h300, addr_match: 10'h000, ifc: tagged Atomic bankBRAM[0].portA },
        MixedMemBusItem{ addr_mask: 10'h300, addr_match: 10'h100, ifc: tagged Atomic bankBRAM[1].portA },
        MixedMemBusItem{ addr_mask: 10'h300, addr_match: 10'h200, ifc: tagged Atomic bankBRAM[2].portA },
        MixedMemBusItem{ addr_mask: 10'h300, addr_match: 10'h300, ifc: tagged Atomic bankBRAM[3].portA });

    MixedAtomicMemBus#(2, 10, 2) bus <- mkMixedAtomicMemBus( busMap );

    equiv( "request.enq", referenceBRAM.portA.request.enq, bus.clients[0].request.enq );
    equiv( "response.first", referenceBRAM.portA.response.first, bus.clients[0].response.first );
    equiv( "response.deq", referenceBRAM.portA.response.deq, bus.clients[0].response.deq );
endmodule

(* synthesize *)
module [Module] mkMixedAtomicMemBusCheck(Empty);
    blueCheck(checkMixedAtomicMemBus);
endmodule
