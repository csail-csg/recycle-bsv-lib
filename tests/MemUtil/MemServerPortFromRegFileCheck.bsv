
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

module [BlueCheck] checkMemServerPortFromRegFile(Empty);
    Reg#(Bool) initStarted <- mkReg(False);
    Reg#(Bool) init <- mkReg(False);

    // 4 word BRAM
    AtomicBRAM#(32, DataSz#(32), 4) referenceBRAM <- mkAtomicBRAM;

    // DUT
    RegFile#(Bit#(2), Bit#(32)) rf <- mkRegFileFull;
    AtomicMemServerPort#(32, DataSz#(32)) dut <- mkMemServerPortFromRegFile(rf);

    FIFO#(Bool) isAtomicOpFIFO <- mkFIFO;

    Stmt writeZeros =
        (seq
            referenceBRAM.portA.request.enq( AtomicMemReq{ write_en: '1, atomic_op: None, addr: 0, data: 0 } );
            referenceBRAM.portA.response.deq;
            referenceBRAM.portA.request.enq( AtomicMemReq{ write_en: '1, atomic_op: None, addr: 4, data: 0 } );
            referenceBRAM.portA.response.deq;
            referenceBRAM.portA.request.enq( AtomicMemReq{ write_en: '1, atomic_op: None, addr: 8, data: 0 } );
            referenceBRAM.portA.response.deq;
            referenceBRAM.portA.request.enq( AtomicMemReq{ write_en: '1, atomic_op: None, addr: 12, data: 0 } );
            referenceBRAM.portA.response.deq;
            rf.upd(0, 0);
            rf.upd(1, 0);
            rf.upd(2, 0);
            rf.upd(3, 0);
            init <= True;
        endseq);

    let fsm <- mkFSM(writeZeros);

    rule startFSM(!initStarted);
        initStarted <= True;
        fsm.start;
    endrule

    function Action memReq(Bit#(4) write_en, Bit#(4) atomic_op_bits, Bit#(2) word, Bit#(32) data);
        return when(init, action
                AtomicMemOp atomic_op = case (atomic_op_bits)
                                            0: Add;
                                            1: And;
                                            2: Or;
                                            3: Xor;
                                            4: Swap;
                                            5: Min;
                                            6: Max;
                                            7: Minu;
                                            8: Maxu;
                                            default: None;
                                        endcase;
                AtomicMemReq#(32, DataSz#(32)) req = AtomicMemReq {
                        write_en: write_en,
                        atomic_op: atomic_op, 
                        addr: (zeroExtend(word) << 2),
                        data: data };
                if ((req.write_en != 0) && (req.atomic_op != None)) begin
                    isAtomicOpFIFO.enq(True);
                end else begin
                    isAtomicOpFIFO.enq(False);
                end
                referenceBRAM.portA.request.enq(req);
                dut.request.enq(req);
            endaction);
    endfunction

    function ActionValue#(Bool) checkResp();
        return (actionvalue
                let isAtomicOp = isAtomicOpFIFO.first;
                isAtomicOpFIFO.deq;
                Bool err = False;
                if (referenceBRAM.portA.response.first.write != dut.response.first.write) begin
                    err = True;
                end
                if (isAtomicOp || !referenceBRAM.portA.response.first.write) begin
                    // data matters
                    if (referenceBRAM.portA.response.first.data != dut.response.first.data) begin
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
                    $display("        dut:           ", fshow(dut.response.first));
                end
                referenceBRAM.portA.response.deq;
                dut.response.deq;
                return !err;
            endactionvalue);
    endfunction

    prop( "request.enq", memReq );
    prop( "response.first", checkResp );
endmodule

(* synthesize *)
module [Module] mkMemServerPortFromRegFileCheck(Empty);
    blueCheck(checkMemServerPortFromRegFile);
endmodule
