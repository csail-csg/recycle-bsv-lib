
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

import Clocks::*;
import FIFO::*;
import List::*;
import RegFile::*;
import StmtFSM::*;
import Vector::*;

import MemUtil::*;
import Port::*;

import BlueCheck::*;

typedef 2 LogNumBytes;
typedef 32 DataSz;
typedef 32 AddrSz;
typedef 1024 NumWords;

typedef struct {
    Bit#(10) wordAddr;
    Bool write;
    Maybe#(Bit#(DataSz)) maybeData;
} CheckResp deriving (Bits, Eq, FShow);

module [BlueCheck] checkAtomicBRAM(Empty);
    Reg#(Bool) initStarted <- mkReg(False);
    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(32)) i <- mkReg(0);
    Reg#(Bit#(32)) j <- mkReg(0);

    AtomicBRAM#(AddrSz, LogNumBytes, NumWords) atomicBRAM <- mkAtomicBRAM;
    RegFile#(Bit#(AddrSz), Bit#(DataSz)) regfile <- mkRegFile(0, fromInteger(4 * valueOf(NumWords)));

    FIFO#(CheckResp) checkRespFIFO <- mkSizedFIFO(16);

    Stmt writeZeros =
        (seq
            par
                seq
                    i <= 0;
                    while (i < fromInteger(valueOf(NumWords) * 4)) action
                        atomicBRAM.portA.request.enq( AtomicMemReq{ write_en: '1, atomic_op: None, addr: i, data: 0 } );
                        regfile.upd( i , 0 );
                        i <= i + 4;
                    endaction
                endseq
                seq
                    j <= 0;
                    while (j < fromInteger(valueOf(NumWords) * 4)) action
                        atomicBRAM.portA.response.deq;
                        j <= j + 4;
                    endaction
                endseq
            endpar
            //init <= True;
        endseq);

    let fsm <- mkFSM(writeZeros);

    rule startFSM(!initStarted);
        initStarted <= True;
        fsm.start;
    endrule

    function Action doWrite( Bit#(4) byteEn, Bit#(10) wordAddr, Bit#(32) data );
        return when(init && (byteEn != 0),
            action
                Bit#(32) addr = zeroExtend(wordAddr) << 2;
                atomicBRAM.portA.request.enq( AtomicMemReq{ write_en: byteEn, atomic_op: None, addr: addr, data: data } );
                let old_data = regfile.sub( addr );
                Vector#(4, Bit#(1)) byteEnVec = unpack(byteEn);
                Bit#(32) bitmask = pack(map(signExtend, byteEnVec));
                let new_data = ((old_data & ~bitmask) | (data & bitmask));
                regfile.upd( addr, new_data );
                checkRespFIFO.enq( CheckResp{ wordAddr: wordAddr, write: True, maybeData: tagged Invalid } );
            endaction);
    endfunction

    function Action doRead( Bit#(10) wordAddr );
        return when(init,
            action
                Bit#(32) addr = zeroExtend(wordAddr) << 2;
                atomicBRAM.portA.request.enq( AtomicMemReq{ write_en: 0, atomic_op: None, addr: addr, data: 0 } );
                let result = regfile.sub( addr );
                checkRespFIFO.enq( CheckResp{ wordAddr: wordAddr, write: False, maybeData: tagged Valid result } );
            endaction);
    endfunction

    function Action doLogicAMO( Bit#(2) amotype, Bit#(4) byteEn, Bit#(10) wordAddr, Bit#(32) data );
        return when(init && (byteEn != 0),
            action
                AtomicMemOp atomic_op = (case (amotype)
                                            0: And;
                                            1: Or;
                                            2: Xor;
                                            3: Swap;
                                        endcase);
                Bit#(32) addr = zeroExtend(wordAddr) << 2;
                atomicBRAM.portA.request.enq( AtomicMemReq{ write_en: byteEn, atomic_op: atomic_op, addr: addr, data: data } );
                let old_data = regfile.sub( addr );
                Vector#(4, Bit#(1)) byteEnVec = unpack(byteEn);
                Bit#(32) bitmask = pack(map(signExtend, byteEnVec));
                Bit#(32) amo_data = (case (atomic_op)
                        And: (old_data & data);
                        Or: (old_data | data);
                        Xor: (old_data ^ data);
                        Swap: (data);
                    endcase);
                let new_data = ((old_data & ~bitmask) | (amo_data & bitmask));
                regfile.upd( addr, new_data );
                checkRespFIFO.enq( CheckResp{ wordAddr: wordAddr, write: True, maybeData: tagged Valid old_data} );
            endaction);
    endfunction

    function ActionValue#(Bool) checkResp();
        return when(init,
            actionvalue
                Bool err = False;
                if (checkRespFIFO.first.write != atomicBRAM.portA.response.first.write) begin
                    err = True;
                end
                if (checkRespFIFO.first.maybeData matches tagged Valid .data) begin
                    if (data != atomicBRAM.portA.response.first.data) begin
                        err = True;
                    end
                end
                if (err) begin
                    $fdisplay(stderr, "    [ERROR] checkResp:");
                    $fdisplay(stderr, "        Expected: ", fshow(checkRespFIFO.first));
                    $fdisplay(stderr, "        Received: ", fshow(atomicBRAM.portA.response.first));
                end 
                atomicBRAM.portA.response.deq;
                checkRespFIFO.deq;
                return !err;
            endactionvalue);
    endfunction

    prop("doWrite", doWrite);
    prop("doRead", doRead);
    prop("doLogicAMO", doLogicAMO);
    prop("checkResp", checkResp);
    parallel(list("doWrite", "checkResp"));
    parallel(list("doRead", "checkResp"));
endmodule

(* synthesize *)
module [Module] mkAtomicBRAMCheck(Empty);
    blueCheck(checkAtomicBRAM);
endmodule
