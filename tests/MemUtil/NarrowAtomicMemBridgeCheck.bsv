
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

typedef TLog#(TDiv#(n,8)) DataSz#(numeric type n);

module [BlueCheck] checkNarrowAtomicMemBridge(Empty);
    AtomicBRAM#(10, DataSz#(32), TDiv#(1024,4)) referenceBRAM <- mkAtomicBRAM;

    AtomicBRAM#(10, DataSz#(128), TDiv#(1024,16)) wideBRAM <- mkAtomicBRAM;
    AtomicMemServerPort#(10, DataSz#(32)) narrowBRAM <- mkNarrowAtomicMemBridge(wideBRAM.portA);

    FIFO#(Bool) isAtomicOpFIFO <- mkFIFO;

    function Action memReq(AtomicMemReq#(10, DataSz#(32)) req);
        return (action
                if ((req.write_en != 0) && (req.atomic_op != None)) begin
                    isAtomicOpFIFO.enq(True);
                end else begin
                    isAtomicOpFIFO.enq(False);
                end
                referenceBRAM.portA.request.enq(req);
                narrowBRAM.request.enq(req);
            endaction);
    endfunction

    function ActionValue#(Bool) checkResp();
        return (actionvalue
                let isAtomicOp = isAtomicOpFIFO.first;
                isAtomicOpFIFO.deq;
                Bool err = False;
                if (referenceBRAM.portA.response.first.write != narrowBRAM.response.first.write) begin
                    err = True;
                end
                if (isAtomicOp || !referenceBRAM.portA.response.first.write) begin
                    // data matters
                    if (referenceBRAM.portA.response.first.data != narrowBRAM.response.first.data) begin
                        err = True;
                    end
                end
                if (err) begin
                    if (isAtomicOp) begin
                        $display("[ERROR] Responses do not match for an atomic memory operation");
                    end else begin
                        $display("[ERROR] Responses do not match for a normal memory operation");
                    end
                    $display("        referenceBRAM: ", fshow(referenceBRAM.portA.response.first));
                    $display("        narrowBRAM:    ", fshow(narrowBRAM.response.first));
                end
                referenceBRAM.portA.response.deq;
                narrowBRAM.response.deq;
                return !err;
            endactionvalue);
    endfunction

    prop( "request.enq", memReq );
    prop( "response.first", checkResp );
endmodule

(* synthesize *)
module [Module] mkNarrowAtomicMemBridgeCheck(Empty);
    blueCheck(checkNarrowAtomicMemBridge);
endmodule
