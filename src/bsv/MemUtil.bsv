
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

/**
 * This package contains interfaces, typeclasses, functions, and modules that
 * are essential for dealing with general purpose memory and memory mapped
 * interfaces.
 *
 * This package adopts two main design choices that simplifies working with
 * general purpose memory:
 *
 * 1. All addresses are byte addresses.
 * 2. Data lines are always word aligned.
 *
 * As a result of these two design choices, we have adopted some conventions:
 *
 * - Data widths are always a power of 2 bytes (`logNumBytes`).
 * - The bottom `logNumBytes` bits of each address is ignored.
 *
 * ### Future Improvements
 *
 * - Write a custom `Bits` instance so pack and unpack can ignore the bottom
 *   `logNumBytes` of a memory request's address.
 */
package MemUtil;

import BRAMCore::*;
import Connectable::*;
import Vector::*;

import Ehr::*;
import FIFOG::*;
import Port::*;

// CoarseMem - Only supports reads and writes on full words

typedef struct {
    Bool         write;
    Bit#(addrSz) addr;                          // bottom logNumBytes bits are unused
    Bit#(TMul#(8,TExp#(logNumBytes))) data;     // always word-aligned
} CoarseMemReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);

typedef struct {
    Bool                              write;    // true for write responses
    Bit#(TMul#(8,TExp#(logNumBytes))) data;     // data for read responses, always word-aligned
} CoarseMemResp#(numeric type logNumBytes) deriving (Bits, Eq, FShow);

// ByteEnMem - Has byte enable signals for narrow writes

typedef struct {
    Bit#(TExp#(logNumBytes))          write_en; // corresponds to bytes in data
    Bit#(addrSz)                      addr;     // bottom two bits are unused
    Bit#(TMul#(8,TExp#(logNumBytes))) data;     // always word-aligned
} ByteEnMemReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);

typedef CoarseMemResp#(logNumBytes) ByteEnMemResp#(numeric type logNumBytes);

// AtomicMem - ByteEnMem with an atomic operation field for atomic memory ops

// This matches the supported atomic memory operations from RISC-V
typedef enum {
    None,
    Swap,
    Add,
    Xor,
    And,
    Or,
    Min,
    Max,
    Minu,
    Maxu
} AtomicMemOp deriving (Bits, Eq, FShow, Bounded);

typedef struct {
    Bit#(TExp#(logNumBytes))          write_en;  // corresponds to bytes in data
    AtomicMemOp                       atomic_op; // which atomic operation to perform, requires write_en to be set to specified bytes
    Bit#(addrSz)                      addr;      // bottom two bits are unused
    Bit#(TMul#(8,TExp#(logNumBytes))) data;      // always word-aligned
} AtomicMemReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);

typedef CoarseMemResp#(logNumBytes) AtomicMemResp#(numeric type logNumBytes);

////////////////////////////////////////////////////////////////////////////////

// Port interfaces

typedef ServerPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemClientPort#(numeric type addrSz, numeric type logNumBytes);

////////////////////////////////////////////////////////////////////////////////

// 32-bit memory interfaces

typedef CoarseMemReq#(addrSz, 2)        CoarseMem32Req#(numeric type addrSz);
typedef CoarseMemResp#(2)               CoarseMem32Resp;
typedef CoarseMemServerPort#(addrSz, 2) CoarseMem32ServerPort#(numeric type addrSz);
typedef CoarseMemClientPort#(addrSz, 2) CoarseMem32ClientPort#(numeric type addrSz);

typedef ByteEnMemReq#(addrSz, 2)        ByteEnMem32Req#(numeric type addrSz);
typedef ByteEnMemResp#(2)               ByteEnMem32Resp;
typedef ByteEnMemServerPort#(addrSz, 2) ByteEnMem32ServerPort#(numeric type addrSz);
typedef ByteEnMemClientPort#(addrSz, 2) ByteEnMem32ClientPort#(numeric type addrSz);

typedef AtomicMemReq#(addrSz, 2)        AtomicMem32Req#(numeric type addrSz);
typedef AtomicMemResp#(2)               AtomicMem32Resp;
typedef AtomicMemServerPort#(addrSz, 2) AtomicMem32ServerPort#(numeric type addrSz);
typedef AtomicMemClientPort#(addrSz, 2) AtomicMem32ClientPort#(numeric type addrSz);

// 64-bit memory interfaces

typedef CoarseMemReq#(addrSz, 3)        CoarseMem64Req#(numeric type addrSz);
typedef CoarseMemResp#(3)               CoarseMem64Resp;
typedef CoarseMemServerPort#(addrSz, 3) CoarseMem64ServerPort#(numeric type addrSz);
typedef CoarseMemClientPort#(addrSz, 3) CoarseMem64ClientPort#(numeric type addrSz);

typedef ByteEnMemReq#(addrSz, 3)        ByteEnMem64Req#(numeric type addrSz);
typedef ByteEnMemResp#(3)               ByteEnMem64Resp;
typedef ByteEnMemServerPort#(addrSz, 3) ByteEnMem64ServerPort#(numeric type addrSz);
typedef ByteEnMemClientPort#(addrSz, 3) ByteEnMem64ClientPort#(numeric type addrSz);

typedef AtomicMemReq#(addrSz, 3)        AtomicMem64Req#(numeric type addrSz);
typedef AtomicMemResp#(3)               AtomicMem64Resp;
typedef AtomicMemServerPort#(addrSz, 3) AtomicMem64ServerPort#(numeric type addrSz);
typedef AtomicMemClientPort#(addrSz, 3) AtomicMem64ClientPort#(numeric type addrSz);

////////////////////////////////////////////////////////////////////////////////

typeclass IsMemReq#(type memReqT, type memRespT, type addrSz, type logNumBytes)
            dependencies (memReqT determines (addrSz, logNumBytes, memRespT));
    function Bit#(addrSz) getAddr(memReqT req);
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(memReqT req);
    function Bool isWrite(memReqT req);
    function Bit#(TExp#(logNumBytes)) getWriteEn(memReqT req);
    function AtomicMemOp getAtomicOp(memReqT req);
    function Bool isAtomicOp(memReqT req);
    function memRespT getDefaultResp(memReqT req);
endtypeclass

instance IsMemReq#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(CoarseMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(CoarseMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(CoarseMemReq#(addrSz, logNumBytes) req) = req.write;
    function Bit#(TExp#(logNumBytes)) getWriteEn(CoarseMemReq#(addrSz, logNumBytes) req) = req.write ? '1 : 0;
    function AtomicMemOp getAtomicOp(CoarseMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(CoarseMemReq#(addrSz, logNumBytes) req) = False;
    function CoarseMemResp#(logNumBytes) getDefaultResp(CoarseMemReq#(addrSz, logNumBytes) req) = CoarseMemResp{ write: req.write, data: 0 };
endinstance

instance IsMemReq#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(ByteEnMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(ByteEnMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(ByteEnMemReq#(addrSz, logNumBytes) req) = req.write_en != 0;
    function Bit#(TExp#(logNumBytes)) getWriteEn(ByteEnMemReq#(addrSz, logNumBytes) req) = req.write_en;
    function AtomicMemOp getAtomicOp(ByteEnMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(ByteEnMemReq#(addrSz, logNumBytes) req) = False;
    function ByteEnMemResp#(logNumBytes) getDefaultResp(ByteEnMemReq#(addrSz, logNumBytes) req) = ByteEnMemResp{ write: req.write_en != 0, data: 0 };
endinstance

instance IsMemReq#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(AtomicMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(AtomicMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(AtomicMemReq#(addrSz, logNumBytes) req) = req.write_en != 0;
    function Bit#(TExp#(logNumBytes)) getWriteEn(AtomicMemReq#(addrSz, logNumBytes) req) = req.write_en;
    function AtomicMemOp getAtomicOp(AtomicMemReq#(addrSz, logNumBytes) req) = req.atomic_op;
    function Bool isAtomicOp(AtomicMemReq#(addrSz, logNumBytes) req) = req.atomic_op != None;
    function AtomicMemResp#(logNumBytes) getDefaultResp(AtomicMemReq#(addrSz, logNumBytes) req) = AtomicMemResp{ write: req.write_en != 0, data: 0 };
endinstance

////////////////////////////////////////////////////////////////////////////////

// Helper function for atomic memory operations

/**
 * This function performs the specified atomic memory operation on the
 * provided memory data and operand data. The byte enable is only used for
 * min and max operations. The output of this function is only valid for the
 * enabled bytes.
 */
function Bit#(dataSz) atomicMemOpAlu(AtomicMemOp op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(numBytes) byteEn)
        provisos (Mul#(numBytes, 8, dataSz));
    // Adder inputs
    Bool isSigned = (case (op)
                        Add: False; // This only affects the behavior of independent
                        Min: True;
                        Max: True;
                        Minu: False;
                        Maxu: False;
                        default: ?;
                    endcase);
    Bool isMin = (case (op)
                        Add: False;
                        Min: True;
                        Max: False;
                        Minu: True;
                        Maxu: False;
                        default: ?;
                    endcase);
    Bool isMax = (case (op)
                        Add: False;
                        Min: False;
                        Max: True;
                        Minu: False;
                        Maxu: True;
                        default: ?;
                    endcase);

    // Produce maskedMemData and maskedOperandData
    Vector#(numBytes, Bit#(8)) maskedMemDataByteVec = unpack(memData);
    Vector#(numBytes, Bit#(8)) maskedOperandDataByteVec = unpack(operandData);
    Bit#(1) prevMemDataByteMSB = 0;
    Bit#(1) prevOperandDataByteMSB = 0;
    for (Integer i = 0 ; i < valueOf(numBytes) ; i = i+1) begin
        if (byteEn[i] == 0) begin
            maskedMemDataByteVec[i] = isSigned ? signExtend(prevMemDataByteMSB) : 0;
            maskedOperandDataByteVec[i] = isSigned ? signExtend(prevOperandDataByteMSB) : 0;
        end
        prevMemDataByteMSB = maskedMemDataByteVec[i][7];
        prevOperandDataByteMSB = maskedOperandDataByteVec[i][7];
    end
    Bit#(dataSz) maskedMemData = pack(maskedMemDataByteVec);
    Bit#(dataSz) maskedOperandData = pack(maskedOperandDataByteVec);

    Bit#(TAdd#(2,dataSz)) a = {1'b0, isSigned ? signExtend(maskedMemData) : zeroExtend(maskedMemData)};
    Bit#(TAdd#(2,dataSz)) b = {1'b0, isSigned ? signExtend(maskedOperandData) : zeroExtend(maskedOperandData)};

    Bit#(TAdd#(2,dataSz)) adderOut = a + ((isMin || isMax) ? ~b : b) + ((isMin || isMax) ? 1 : 0);

    // Bool operandDataLarger = unpack(adderOut[1+valueOf(dataSz)]); // carry out of memData - operandData -- doesn't really work
    Int#(TAdd#(1,dataSz)) memInt = unpack(isSigned ? signExtend(maskedMemData) : zeroExtend(maskedMemData));
    Int#(TAdd#(1,dataSz)) operandInt = unpack(isSigned ? signExtend(maskedOperandData) : zeroExtend(maskedOperandData));
    Bool operandDataLarger = operandInt > memInt;

    Bit#(dataSz) minMaxOut = operandDataLarger ? ( isMax ? operandData : memData )
                                               : ( isMax ? memData : operandData );

    return (case (op)
            None: 0;
            Swap: operandData;
            Add:  truncate(adderOut);
            Xor:  (memData ^ operandData);
            And:  (memData & operandData);
            Or:   (memData | operandData);
            Min:  minMaxOut;
            Max:  minMaxOut;
            Minu: minMaxOut;
            Maxu: minMaxOut;
        endcase);
endfunction

(* noinline *)
function Bit#(32) atomicMemOpAlu32(AtomicMemOp op, Bit#(32) memData, Bit#(32) operandData, Bit#(4) byteEn);
    return atomicMemOpAlu(op, memData, operandData, byteEn);
endfunction
(* noinline *)
function Bit#(64) atomicMemOpAlu64(AtomicMemOp op, Bit#(64) memData, Bit#(64) operandData, Bit#(8) byteEn);
    return atomicMemOpAlu(op, memData, operandData, byteEn);
endfunction

////////////////////////////////////////////////////////////////////////////////

/// This bridge attempts to emulate atomic memory operations across a memory
/// interface that does not support atomic memory operations.
typeclass MkAtomicMemEmulationBridge#(type memIfc, numeric type addrSz, numeric type logNumBytes)
        dependencies (memIfc determines (addrSz, logNumBytes));
    module mkAtomicMemEmulationBridge#(memIfc mem)(AtomicMemServerPort#(addrSz, logNumBytes));
endtypeclass

//// This structure is defined below
// typedef struct {
//     Bit#(TExp#(logNumBytes)) write_en;  // corresponds to bytes in data
//     AtomicMemOp              atomic_op; // which atomic operation to perform, requires write_en to be set to specified bytes
//     Bool                     rmw_write; // if the pending request is the write of a read modify write operation
// } AtomicBRAMPendingReq#(numeric type logNumBytes) deriving (Bits, Eq, FShow);

instance MkAtomicMemEmulationBridge#(CoarseMemServerPort#(addrSz, logNumBytes), addrSz, logNumBytes) provisos (Div#(TMul#(8,TExp#(logNumBytes)), 8, TExp#(logNumBytes)));
    module mkAtomicMemEmulationBridge#(CoarseMemServerPort#(addrSz, logNumBytes) mem)(AtomicMemServerPort#(addrSz, logNumBytes))
            provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
        // bookkeeping reg
        Ehr#(2, Maybe#(AtomicBRAMPendingReq#(logNumBytes))) pendingReq <- mkEhr(tagged Invalid);
        Reg#(Bit#(dataSz)) atomicOpData <- mkReg(0);
        Reg#(Bit#(addrSz)) atomicOpAddress <- mkReg(0);
        // pendingReq needs to save data, 
        Ehr#(2, Maybe#(AtomicMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

        // Add a buffer to the coarse mem response to avoid having requests.enq
        // and response.deq together in performAtomicMemoryOp
        FIFOG#(CoarseMemResp#(logNumBytes)) coarseMemRespFIFO <- mkBypassFIFOG;

        mkConnection(mem.response, toInputPort(coarseMemRespFIFO));

        rule performAtomicMemoryOp(pendingReq[0] matches tagged Valid .req
                                    &&& req.atomic_op != None);
            let writeData = atomicMemOpAlu(req.atomic_op, coarseMemRespFIFO.first.data, atomicOpData, req.write_en);
            Vector#(TExp#(logNumBytes), Bit#(1)) byteEnVec = unpack(req.write_en);
            Bit#(dataSz) bitMask = pack(map(signExtend, byteEnVec));
            writeData = (writeData & bitMask) | (coarseMemRespFIFO.first.data & ~bitMask);
            mem.request.enq( CoarseMemReq{ write: True, addr: atomicOpAddress, data: writeData } );
            pendingReq[0] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: None, rmw_write: True };
            atomicOpData <= coarseMemRespFIFO.first.data;
            coarseMemRespFIFO.deq;
        endrule

        rule getRespFromCore(pendingReq[0] matches tagged Valid .req
                                &&& req.atomic_op == None
                                &&& !isValid(pendingResp[0]));
            pendingResp[0] <= tagged Valid AtomicMemResp{ write: req.write_en != 0, data: (req.rmw_write ? atomicOpData : coarseMemRespFIFO.first.data) };
            pendingReq[0] <= tagged Invalid;
            coarseMemRespFIFO.deq;
        endrule

        interface InputPort request;
            method Action enq(AtomicMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                // Clean the atomic_op passed in
                let atomic_op = req.atomic_op;
                if (req.write_en == 0) begin
                    atomic_op = None;
                end else if ((req.atomic_op == None) && (req.write_en != '1)) begin
                    // use swap to implement narrow loads
                    atomic_op = Swap;
                end
                pendingReq[1] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: atomic_op, rmw_write: False };
                if (atomic_op == None) begin
                    // normal read/write
                    mem.request.enq( CoarseMemReq { write: req.write_en == '1, addr: req.addr, data: req.data } );
                end else begin
                    // atomic memory operation, do read first
                    mem.request.enq( CoarseMemReq { write: False, addr: req.addr, data: req.data } );
                    // store operand data for later
                    atomicOpData <= req.data;
                    atomicOpAddress <= req.addr;
                end
            endmethod
            method Bool canEnq;
                return !isValid(pendingReq[1]);
            endmethod
        endinterface
        interface OutputPort response;
            method ByteEnMemResp#(logNumBytes) first if (pendingResp[1] matches tagged Valid .resp);
                return resp;
            endmethod
            method Action deq if (isValid(pendingResp[1]));
                pendingResp[1] <= tagged Invalid;
            endmethod
            method Bool canDeq;
                return isValid(pendingResp[1]);
            endmethod
        endinterface
    endmodule
endinstance

// simple for ByteEnMem and AtomicMem, complicated for CoarseMem
//// TODO: Implement this
module mkNarrowAtomicMemBridge#(AtomicMemServerPort#(addrSz, TAdd#(logNumBytes, logNumWords)) wideMem)(AtomicMemServerPort#(addrSz, logNumBytes))
        provisos(Add#(a__, logNumWords, addrSz));
    function Bit#(logNumWords) getWhichWord(Bit#(addrSz) x);
        return truncate(x >> valueOf(logNumBytes));
    endfunction

    FIFOG#(Bit#(logNumWords)) whichWordFIFO <- mkFIFOG;

    interface InputPort request;
        method Action enq(AtomicMemReq#(addrSz, logNumBytes) req);
            let wordIndex = getWhichWord(req.addr);
            Vector#(TExp#(logNumWords), Bit#(TExp#(logNumBytes))) write_en_vec = replicate(0);
            Vector#(TExp#(logNumWords), Bit#(TMul#(8,TExp#(logNumBytes)))) data_vec = replicate(0);
            write_en_vec[wordIndex] = req.write_en;
            data_vec[wordIndex] = req.data;
            whichWordFIFO.enq(wordIndex);
            wideMem.request.enq( AtomicMemReq{write_en: pack(write_en_vec), atomic_op: req.atomic_op, addr: req.addr, data: pack(data_vec)} );
        endmethod
        method Bool canEnq;
            return wideMem.request.canEnq && whichWordFIFO.canEnq;
        endmethod
    endinterface
    interface OutputPort response;
        method AtomicMemResp#(logNumBytes) first;
            let resp = wideMem.response.first;
            Vector#(TExp#(logNumWords), Bit#(TMul#(8,TExp#(logNumBytes)))) dataVec = unpack(resp.data);
            return AtomicMemResp{write: resp.write, data: dataVec[whichWordFIFO.first]};
        endmethod
        method Action deq;
            wideMem.response.deq;
            whichWordFIFO.deq;
        endmethod
        method Bool canDeq;
            return wideMem.response.canDeq && whichWordFIFO.canDeq;
        endmethod
    endinterface
endmodule

////////////////////////////////////////////////////////////////////////////////

// Helper functions for memory capacity

// typedef numWords                               Words#(numeric type numWords, numeric type dataSz);
// typedef TDiv#(numBytes, TDiv#(dataSz, 8))      Bytes#(numeric type numBytes, numeric type dataSz);
// typedef Bytes#(TMul#(1024, numKB), dataSz)     KiloBytes#(numeric type numKB, numeric type dataSz);
// typedef KiloBytes#(TMul#(1024, numMB), dataSz) MegaBytes#(numeric type numMB, numeric type dataSz);
// typedef MegaBytes#(TMul#(1024, numMB), dataSz) GigaBytes#(numeric type numMB, numeric type dataSz);

interface CoarseBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface CoarseMemServerPort#(addrSz, logNumBytes) portA;
endinterface

// response < request
module mkPipelineCoarseBRAM( CoarseBRAM#(addrSz, logNumBytes, numWords) )
        provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
    // bookkeeping reg
    Ehr#(2, Maybe#(Bool)) pendingReq <- mkEhr(tagged Invalid);

    // bram core
    BRAM_PORT#(Bit#(addrSz), Bit#(dataSz)) bram <- mkBRAMCore1(valueOf(numWords), False);

    interface CoarseMemServerPort portA;
        interface InputPort request;
            method Action enq(CoarseMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                pendingReq[1] <= tagged Valid req.write;
                bram.put(req.write, req.addr, req.data);
            endmethod
            method Bool canEnq;
                return !isValid(pendingReq[1]);
            endmethod
        endinterface
        interface OutputPort response;
            method CoarseMemResp#(logNumBytes) first if (pendingReq[0] matches tagged Valid .isWrite);
                return CoarseMemResp{ write: isWrite, data: bram.read };
            endmethod
            method Action deq if (isValid(pendingReq[0]));
                pendingReq[0] <= tagged Invalid;
            endmethod
            method Bool canDeq;
                return isValid(pendingReq[0]);
            endmethod
        endinterface
    endinterface
endmodule

// response CF request
module mkCoarseBRAM( CoarseBRAM#(addrSz, logNumBytes, numWords) )
        provisos (NumAlias#(TMul#(8, TExp#(logNumBytes)), dataSz),
                  NumAlias#(TSub#(addrSz, logNumBytes), wordAddrSz));
    function Bit#(wordAddrSz) toWordAddr(Bit#(addrSz) addr);
        return truncateLSB(addr);
    endfunction
    // bookkeeping reg
    Ehr#(2, Maybe#(Bool)) pendingReq <- mkEhr(tagged Invalid);
    Ehr#(2, Maybe#(CoarseMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

    // bram core
    BRAM_PORT#(Bit#(wordAddrSz), Bit#(dataSz)) bram <- mkBRAMCore1(valueOf(numWords), False);

    rule getRespFromCore(pendingReq[0] matches tagged Valid .isWrite
                            &&& !isValid(pendingResp[0]));
        pendingResp[0] <= tagged Valid CoarseMemResp{ write: isWrite, data: bram.read };
        pendingReq[0] <= tagged Invalid;
    endrule

    interface CoarseMemServerPort portA;
        interface InputPort request;
            method Action enq(CoarseMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                pendingReq[1] <= tagged Valid req.write;
                bram.put(req.write, toWordAddr(req.addr), req.data);
            endmethod
            method Bool canEnq;
                return !isValid(pendingReq[1]);
            endmethod
        endinterface
        interface OutputPort response;
            method CoarseMemResp#(logNumBytes) first if (pendingResp[1] matches tagged Valid .resp);
                return resp;
            endmethod
            method Action deq if (isValid(pendingResp[1]));
                pendingResp[1] <= tagged Invalid;
            endmethod
            method Bool canDeq;
                return isValid(pendingResp[1]);
            endmethod
        endinterface
    endinterface
endmodule

interface ByteEnBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface ByteEnMemServerPort#(addrSz, logNumBytes) portA;
endinterface

// response CF request
module mkByteEnBRAM( ByteEnBRAM#(addrSz, logNumBytes, numWords) )
        provisos (NumAlias#(TMul#(8, TExp#(logNumBytes)), dataSz),
                  NumAlias#(TSub#(addrSz, logNumBytes), wordAddrSz),
                  Mul#(TDiv#(dataSz, TExp#(logNumBytes)), TExp#(logNumBytes), dataSz));
    function Bit#(wordAddrSz) toWordAddr(Bit#(addrSz) addr);
        return truncateLSB(addr);
    endfunction
    // bookkeeping reg
    Ehr#(2, Maybe#(Bool)) pendingReq <- mkEhr(tagged Invalid);
    Ehr#(2, Maybe#(ByteEnMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

    // bram core
    BRAM_PORT_BE#(Bit#(wordAddrSz), Bit#(dataSz), TExp#(logNumBytes)) bram <- mkBRAMCore1BE(valueOf(numWords), False);

    rule getRespFromCore(pendingReq[0] matches tagged Valid .isWrite
                            &&& !isValid(pendingResp[0]));
        pendingResp[0] <= tagged Valid ByteEnMemResp{ write: isWrite, data: bram.read };
        pendingReq[0] <= tagged Invalid;
    endrule

    interface ByteEnMemServerPort portA;
        interface InputPort request;
            method Action enq(ByteEnMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                pendingReq[1] <= tagged Valid (req.write_en != 0);
                bram.put(req.write_en, toWordAddr(req.addr), req.data);
            endmethod
            method Bool canEnq;
                return !isValid(pendingReq[1]);
            endmethod
        endinterface
        interface OutputPort response;
            method ByteEnMemResp#(logNumBytes) first if (pendingResp[1] matches tagged Valid .resp);
                return resp;
            endmethod
            method Action deq if (isValid(pendingResp[1]));
                pendingResp[1] <= tagged Invalid;
            endmethod
            method Bool canDeq;
                return isValid(pendingResp[1]);
            endmethod
        endinterface
    endinterface
endmodule

interface AtomicBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface AtomicMemServerPort#(addrSz, logNumBytes) portA;
endinterface

typedef struct {
    Bit#(TExp#(logNumBytes)) write_en;  // corresponds to bytes in data
    AtomicMemOp              atomic_op; // which atomic operation to perform, requires write_en to be set to specified bytes
    Bool                     rmw_write; // if the pending request is the write of a read modify write operation
} AtomicBRAMPendingReq#(numeric type logNumBytes) deriving (Bits, Eq, FShow);

/**
 * This module creates an AtomicMemServerPort from a BRAMCore.
 *
 * This module supports narrow atomic memory operations through the use of the
 * `write_en` field in the `AtomicMemReq` struct. In normal operation, the
 * `write_en` field should only have contiguous bits set. If non-contiguous
 * bytes are enabled, they will behave as separate atomic memory operations
 * except for the min/max atomic memory operations. Those will behave as if
 * all the enabled bytes are concatenated.
 */
module mkAtomicBRAM( AtomicBRAM#(addrSz, logNumBytes, numWords) )
        provisos (NumAlias#(TMul#(8, TExp#(logNumBytes)), dataSz),
                  NumAlias#(TSub#(addrSz, logNumBytes), wordAddrSz),
                  Mul#(TDiv#(dataSz, TExp#(logNumBytes)), TExp#(logNumBytes), dataSz));
    function Bit#(wordAddrSz) toWordAddr(Bit#(addrSz) addr);
        return truncateLSB(addr);
    endfunction
    // bookkeeping reg
    Ehr#(2, Maybe#(AtomicBRAMPendingReq#(logNumBytes))) pendingReq <- mkEhr(tagged Invalid);
    Reg#(Bit#(dataSz)) atomicOpData <- mkReg(0);
    Reg#(Bit#(wordAddrSz)) atomicOpAddress <- mkReg(0);
    // pendingReq needs to save data, 
    Ehr#(2, Maybe#(AtomicMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

    // bram core
    BRAM_PORT_BE#(Bit#(wordAddrSz), Bit#(dataSz), TExp#(logNumBytes)) bram <- mkBRAMCore1BE(valueOf(numWords), False);

    rule performAtomicMemoryOp(pendingReq[0] matches tagged Valid .req
                                &&& req.atomic_op != None);
        let writeData = atomicMemOpAlu(req.atomic_op, bram.read, atomicOpData, req.write_en);
        bram.put(req.write_en, atomicOpAddress, writeData);
        pendingReq[0] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: None, rmw_write: True };
        atomicOpData <= bram.read;
    endrule

    rule getRespFromCore(pendingReq[0] matches tagged Valid .req
                            &&& req.atomic_op == None
                            &&& !isValid(pendingResp[0]));
        pendingResp[0] <= tagged Valid AtomicMemResp{ write: req.write_en != 0, data: (req.rmw_write ? atomicOpData : bram.read) };
        pendingReq[0] <= tagged Invalid;
    endrule

    interface ByteEnMemServerPort portA;
        interface InputPort request;
            method Action enq(AtomicMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                let atomic_op = (req.write_en != 0) ? req.atomic_op : None;
                pendingReq[1] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: atomic_op, rmw_write: False };
                if (atomic_op == None) begin
                    // normal read/write
                    bram.put(req.write_en, toWordAddr(req.addr), req.data);
                end else begin
                    // atomic memory operation, do read first
                    bram.put(0, toWordAddr(req.addr), req.data);
                    // store operand data for later
                    atomicOpData <= req.data;
                    atomicOpAddress <= toWordAddr(req.addr);
                end
            endmethod
            method Bool canEnq;
                return !isValid(pendingReq[1]);
            endmethod
        endinterface
        interface OutputPort response;
            method ByteEnMemResp#(logNumBytes) first if (pendingResp[1] matches tagged Valid .resp);
                return resp;
            endmethod
            method Action deq if (isValid(pendingResp[1]));
                pendingResp[1] <= tagged Invalid;
            endmethod
            method Bool canDeq;
                return isValid(pendingResp[1]);
            endmethod
        endinterface
    endinterface
endmodule

////////////////////////////////////////////////////////////////////////////////

// Memory bus -- Works with CoarseMem, ByteEnMem, and AtomicMem interfaces

typedef struct {
    Bit#(addrSz) addr_mask;
    Bit#(addrSz) addr_match;
    ServerPort#(memReqT, memRespT) ifc;
} MemBusItem#(type memReqT, type memRespT, numeric type addrSz);

/**
 * This function produces a `MemBusItem` from an address range.
 *
 * This function will return an error at compile time if the address range
 * cannot be exptessed with an address mask and a match value.
 */
function MemBusItem#(memReqT, memRespT, addrSz) busItemFromAddrRange( Bit#(addrSz) low, Bit#(addrSz) high, ServerPort#(memReqT, memRespT) ifc );
    let addr_mask = ~(low ^ high);
    let addr_match = low & addr_mask;
    // mask should be a contiguous region of upper bits,
    // low should be the lowest valid address for mask/match combination,
    // and high should be the highest valid address for mask/match combination,
    Bool valid = ((addr_mask & ((~addr_mask) >> 1)) == 0)
                    && ((low & ~addr_mask) == 0)
                    && ((high & ~addr_mask) == ~addr_mask);
    if (valid) begin
        return MemBusItem {
            addr_mask: addr_mask,
            addr_match: addr_match,
            ifc: ifc
        };
    end else begin
        return error("busItemFromAddrRange compilation error: Address range cannot be expressed as match/mask", ?);
    end
endfunction

/**
 * This module makes a memory bus from a provided address map.
 *
 * This module takes in an address map as a vector of `MemBusItem`. Each item
 * consists of a `ServerPort` interface and an address mask and match. This
 * module produces a vector of `ServerPort` memory interfaces for clients to
 * attach to to.
 *
 * The internal implementation consists of many bypass FIFOs for decoupling
 * to avoid adding unnecessary scheduling constraints between the independent
 * memory servers. This implementation also consists of many internal rules to
 * easily support concurrent access between independent clients and servers.
 * There are better ways to get this concurrency, but they require more
 * implementation effort and are harder to verify.
 */
module mkMemBus#(Vector#(nServers, MemBusItem#(memReqT, memRespT, addrSz)) bus_items)(Vector#(nClients, ServerPort#(memReqT, memRespT)))
            provisos(Bits#(memReqT, memReqSz),
                    Bits#(memRespT, memRespSz),
                    IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    // check for consistency of addr_mask and addr_match in bus_items
    for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
        if ((bus_items[i].addr_mask & bus_items[i].addr_match) != bus_items[i].addr_match) begin
            errorM("mkMemBus compilation error: Illegal addr_mask addr_match combination");
        end
        for (Integer j = 0 ; j < valueOf(nServers) ; j = j+1) begin
            if (i != j) begin
                Bit#(addrSz) shared_mask = bus_items[i].addr_mask & bus_items[j].addr_mask;
                Bit#(addrSz) different_match = bus_items[i].addr_match ^ bus_items[j].addr_match;
                if ((shared_mask & different_match) == 0) begin
                    errorM("mkMemBus compilation error: Overlapping address regions in bus_items");
                end
            end
        end
    end

    // Bypass FIFOs to buffer all the inputs and outputs. Without these
    // buffers, this module would add additional scheduling constraints
    // between client items and server items.
    Vector#(nClients, FIFOG#(memReqT)) clientMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nClients, FIFOG#(memRespT)) clientMemResp <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(memReqT)) serverMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(memRespT)) serverMemResp <- replicateM(mkBypassFIFOG);
    // Bookkeeping FIFOs to keep track of request routing
    // clientBookkeeping can hold valueOf(nServers) to corresponds to an
    // out-of-bounds address.
    Vector#(nClients, FIFOG#(Bit#(TLog#(TAdd#(nServers,1))))) clientBookkeeping <- replicateM(mkPipelineFIFOG);
    Vector#(nServers, FIFOG#(Bit#(TLog#(nClients)))) serverBookkeeping <- replicateM(mkPipelineFIFOG);
    // out-of-bounds responses, acts like another client.
    FIFOG#(memRespT) oobResp <- mkPipelineFIFOG;

    function Bit#(TLog#(TAdd#(nServers,1))) getServer(memReqT req);
        Bit#(addrSz) addr = getAddr(req);
        // This value corresponds to an out-of-bounds address
        Bit#(TLog#(TAdd#(nServers,1))) server = fromInteger(valueOf(nServers));
        for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
            if ((addr & bus_items[i].addr_mask) == bus_items[i].addr_match) begin
                server = fromInteger(i);
            end
        end
        return server;
    endfunction

    // make a ton of rules
    for (Integer c = 0 ; c < valueOf(nClients) ; c = c+1) begin
        for (Integer s = 0 ; s < valueOf(nServers) ; s = s+1) begin
            rule connectReq( getServer(clientMemReq[c].first) == fromInteger(s) );
                // $display("connectReq: c = %0d to s = %0d", c, s);
                serverMemReq[s].enq( clientMemReq[c].first );
                clientMemReq[c].deq;
                clientBookkeeping[c].enq( fromInteger(s) );
                serverBookkeeping[s].enq( fromInteger(c) );
            endrule

            rule connectResp( (clientBookkeeping[c].first == fromInteger(s)) && (serverBookkeeping[s].first == fromInteger(c)) );
                // $display("connectResp: c = %0d to s = %0d", c, s);
                clientBookkeeping[c].deq;
                serverBookkeeping[s].deq;
                clientMemResp[c].enq( serverMemResp[s].first );
                serverMemResp[s].deq;
            endrule
        end

        // out-of-bounds requests
        rule connectOobReq( getServer(clientMemReq[c].first) == fromInteger(valueOf(nServers)) );
            // $display("connectOobReq: c = %0d", c);
            oobResp.enq( getDefaultResp(clientMemReq[c].first) );
            clientMemReq[c].deq;
            clientBookkeeping[c].enq( fromInteger(valueOf(nServers)) );
        endrule

        rule connectOobResp( clientBookkeeping[c].first == fromInteger(valueOf(nServers)) );
            // $display("connectOobResp: c = %0d", c);
            clientBookkeeping[c].deq;
            clientMemResp[c].enq( oobResp.first );
            oobResp.deq;
        endrule
    end
    for (Integer s = 0 ; s < valueOf(nServers) ; s = s+1) begin
        //rule connectServerReq;
        //    // $display("connectServerReq: s = %0d", s);
        //    bus_items[s].ifc.request.enq( serverMemReq[s].first );
        //    serverMemReq[s].deq;
        //endrule
        //rule connectServerResp;
        //    // $display("connectServerResp: s = %0d", s);
        //    serverMemResp[s].enq( bus_items[s].ifc.response.first );
        //    bus_items[s].ifc.response.deq;
        //endrule
        mkConnection(toOutputPort(serverMemReq[s]), bus_items[s].ifc.request);
        mkConnection(bus_items[s].ifc.response, toInputPort(serverMemResp[s]));
    end

    Vector#(nClients, ServerPort#(memReqT, memRespT)) ifc = zipWith( toServerPort, clientMemReq, clientMemResp );

    return ifc;
endmodule

endpackage