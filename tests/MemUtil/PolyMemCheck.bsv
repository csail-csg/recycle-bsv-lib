
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
import PolymorphicMem::*;
import Port::*;

import BlueCheck::*;

module [BlueCheck] checkPolyMem#(ServerPort#(reqT, respT) referenceMem)(Empty)
        provisos (MkPolymorphicBRAM#(reqT, respT),
                  BlueCheck::Equiv#(function Action f(reqT x1)),
                  // BlueCheck::Equiv#(respT),
                  BlueCheck::Equiv#(ActionValue#(respT)),
                  Eq#(respT));
    ServerPort#(reqT, respT) dut <- mkPolymorphicBRAM(1024);

    function ActionValue#(t) checkAndDeq( OutputPort#(t) x );
        return (actionvalue
                x.deq;
                return x.first;
            endactionvalue);
    endfunction

    equiv( "request.enq", referenceMem.request.enq, dut.request.enq );
    equiv( "checkAndDeq(response)", checkAndDeq(referenceMem.response), checkAndDeq(dut.response) );
endmodule

(* synthesize *)
module [Module] mkPolyMemCheck(Empty);
    CoarseBRAM#(14, 4, 1024) coarseBRAM <- mkCoarseBRAM;
    ByteEnBRAM#(11, 1, 1024) byteEnBRAM <- mkByteEnBRAM;
    AtomicBRAM#(13, 3, 1024) atomicBRAM <- mkAtomicBRAM;

    let test1 <- blueCheckStmt(checkPolyMem(coarseBRAM.portA));
    let test2 <- blueCheckStmt(checkPolyMem(byteEnBRAM.portA));
    let test3 <- blueCheckStmt(checkPolyMem(atomicBRAM.portA));

    Stmt tests = (seq
            test1;
            test2;
            test3;
        endseq);
    mkAutoFSM(tests);
endmodule
