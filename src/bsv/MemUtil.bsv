
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
import RegFile::*;
import Vector::*;

import Ehr::*;
import FIFOG::*;
import GenericAtomicMem::*;
import PolymorphicMem::*;
import Port::*;

// ReadOnlyMem - Only supports reads

// logNumBytes is not necessary for this type, but it is necessary if we want
// a custom Bits implementation.
typedef struct {
    Bit#(addrSz) addr;
} ReadOnlyMemReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);

typedef struct {
    Bit#(TMul#(8,TExp#(logNumBytes))) data;
} ReadOnlyMemResp#(numeric type logNumBytes) deriving (Bits, Eq, FShow);

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

// MMIO - AtomicMem with separate write and byte_en

typedef struct {
    Bool                              write;
    Bit#(TExp#(logNumBytes))          byte_en;   // corresponds to bytes in data
    AtomicMemOp                       atomic_op; // which atomic operation to perform, requires write_en to be set to specified bytes
    Bit#(addrSz)                      addr;      // bottom two bits are unused
    Bit#(TMul#(8,TExp#(logNumBytes))) data;      // always word-aligned
} MMIOReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);

typedef CoarseMemResp#(logNumBytes) MMIOResp#(numeric type logNumBytes);

////////////////////////////////////////////////////////////////////////////////

// Port interfaces

typedef ServerPort#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes)) ReadOnlyMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes)) ReadOnlyMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemClientPort#(numeric type addrSz, numeric type logNumBytes);

typedef ServerPort#(MMIOReq#(addrSz, logNumBytes), MMIOResp#(logNumBytes)) MMIOServerPort#(numeric type addrSz, numeric type logNumBytes);
typedef ClientPort#(MMIOReq#(addrSz, logNumBytes), MMIOResp#(logNumBytes)) MMIOClientPort#(numeric type addrSz, numeric type logNumBytes);

////////////////////////////////////////////////////////////////////////////////

// 32-bit memory interfaces

typedef ReadOnlyMemReq#(addrSz, 2)        ReadOnlyMem32Req#(numeric type addrSz);
typedef ReadOnlyMemResp#(2)               ReadOnlyMem32Resp;
typedef ReadOnlyMemServerPort#(addrSz, 2) ReadOnlyMem32ServerPort#(numeric type addrSz);
typedef ReadOnlyMemClientPort#(addrSz, 2) ReadOnlyMem32ClientPort#(numeric type addrSz);

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

typedef MMIOReq#(addrSz, 2)        MMIO32Req#(numeric type addrSz);
typedef MMIOResp#(2)               MMIO32Resp;
typedef MMIOServerPort#(addrSz, 2) MMIO32ServerPort#(numeric type addrSz);
typedef MMIOClientPort#(addrSz, 2) MMIO32ClientPort#(numeric type addrSz);

// 64-bit memory interfaces

typedef ReadOnlyMemReq#(addrSz, 3)        ReadOnlyMem64Req#(numeric type addrSz);
typedef ReadOnlyMemResp#(3)               ReadOnlyMem64Resp;
typedef ReadOnlyMemServerPort#(addrSz, 3) ReadOnlyMem64ServerPort#(numeric type addrSz);
typedef ReadOnlyMemClientPort#(addrSz, 3) ReadOnlyMem64ClientPort#(numeric type addrSz);

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

typedef MMIOReq#(addrSz, 3)        MMIO64Req#(numeric type addrSz);
typedef MMIOResp#(3)               MMIO64Resp;
typedef MMIOServerPort#(addrSz, 3) MMIO64ServerPort#(numeric type addrSz);
typedef MMIOClientPort#(addrSz, 3) MMIO64ClientPort#(numeric type addrSz);

////////////////////////////////////////////////////////////////////////////////

// Unifying Memory Types and Typeclasses

typedef enum {
    ReadOnly,
    Coarse,
    ByteEn,
    Atomic,
    MMIO
} MemType deriving (Bits, Eq, FShow, Bounded);

typedef union tagged {
    ReadOnlyMemServerPort#(addrSz, logNumBytes) ReadOnly;
    CoarseMemServerPort#(addrSz, logNumBytes)   Coarse;
    ByteEnMemServerPort#(addrSz, logNumBytes)   ByteEn;
    AtomicMemServerPort#(addrSz, logNumBytes)   Atomic;
    MMIOServerPort#(addrSz, logNumBytes)        MMIO;
} TaggedMemServerPort#(numeric type addrSz, numeric type logNumBytes);

typeclass IsMemReq#(type memReqT, type memRespT, type addrSz, type logNumBytes)
            dependencies (memReqT determines (addrSz, logNumBytes, memRespT));
    function Bit#(addrSz)                      getAddr(memReqT req);
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(memReqT req);
    function Bool                              isWrite(memReqT req);
    function Bit#(TExp#(logNumBytes))          getWriteEn(memReqT req);
    function AtomicMemOp                       getAtomicOp(memReqT req);
    function Bool                              isAtomicOp(memReqT req);
    function memRespT                          getDefaultResp(memReqT req);
endtypeclass

instance IsMemReq#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(ReadOnlyMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(ReadOnlyMemReq#(addrSz, logNumBytes) req) = 0;
    function Bool isWrite(ReadOnlyMemReq#(addrSz, logNumBytes) req) = False;
    function Bit#(TExp#(logNumBytes)) getWriteEn(ReadOnlyMemReq#(addrSz, logNumBytes) req) = 0;
    function AtomicMemOp getAtomicOp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = False;
    function ReadOnlyMemResp#(logNumBytes) getDefaultResp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = ReadOnlyMemResp{ data: 0 };
endinstance

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

instance IsMemReq#(MMIOReq#(addrSz, logNumBytes), MMIOResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(MMIOReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(MMIOReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(MMIOReq#(addrSz, logNumBytes) req) = req.write;
    function Bit#(TExp#(logNumBytes)) getWriteEn(MMIOReq#(addrSz, logNumBytes) req) = req.write ? req.byte_en : 0;
    function AtomicMemOp getAtomicOp(MMIOReq#(addrSz, logNumBytes) req) = req.atomic_op;
    function Bool isAtomicOp(MMIOReq#(addrSz, logNumBytes) req) = req.atomic_op != None;
    function MMIOResp#(logNumBytes) getDefaultResp(MMIOReq#(addrSz, logNumBytes) req) = MMIOResp{ write: req.write, data: 0 };
endinstance

function ReadOnlyMemReq#(addrSz, logNumBytes) toReadOnlyMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return ReadOnlyMemReq { addr: getAddr(req) };
endfunction
function Bool isReadOnlyMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req);
endfunction

function CoarseMemReq#(addrSz, logNumBytes) toCoarseMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return CoarseMemReq { write: isWrite(req), addr: getAddr(req), data: getData(req) };
endfunction
function Bool isCoarseMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req) || ((getWriteEn(req) == '1) && (getAtomicOp(req) == None));
endfunction

function ByteEnMemReq#(addrSz, logNumBytes) toByteEnMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return ByteEnMemReq { write_en: getWriteEn(req), addr: getAddr(req), data: getData(req) };
endfunction
function Bool isByteEnMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req) || (getAtomicOp(req) == None);
endfunction

function AtomicMemReq#(addrSz, logNumBytes) toAtomicMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return AtomicMemReq { write_en: getWriteEn(req), atomic_op: getAtomicOp(req), addr: getAddr(req), data: getData(req) };
endfunction
function Bool isAtomicMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return True;
endfunction

// Assume reads try to read entire word
function MMIOReq#(addrSz, logNumBytes) toMMIOReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return MMIOReq { write: isWrite(req), byte_en: isWrite(req) ? getWriteEn(req) : '1, atomic_op: getAtomicOp(req), addr: getAddr(req), data: getData(req) };
endfunction
function Bool isMMIOReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return True;
endfunction

//

typeclass IsMemResp#(type memRespT, numeric type logNumBytes) dependencies (memRespT determines logNumBytes);
    function memRespT fromReadOnlyMemResp(ReadOnlyMemResp#(logNumBytes) resp);
    function memRespT fromCoarseMemResp(CoarseMemResp#(logNumBytes) resp);
    function memRespT fromByteEnMemResp(CoarseMemResp#(logNumBytes) resp) = fromCoarseMemResp(resp);
    function memRespT fromAtomicMemResp(CoarseMemResp#(logNumBytes) resp) = fromCoarseMemResp(resp);
    function memRespT fromMMIOResp(CoarseMemResp#(logNumBytes) resp) = fromCoarseMemResp(resp);
    function ReadOnlyMemResp#(logNumBytes) toReadOnlyMemResp(memRespT resp);
    function CoarseMemResp#(logNumBytes) toCoarseMemResp(memRespT resp);
    function ByteEnMemResp#(logNumBytes) toByteEnMemResp(memRespT resp) = toCoarseMemResp(resp);
    function AtomicMemResp#(logNumBytes) toAtomicMemResp(memRespT resp) = toCoarseMemResp(resp);
    function MMIOResp#(logNumBytes) toMMIOResp(memRespT resp) = toCoarseMemResp(resp);
endtypeclass

instance IsMemResp#(ReadOnlyMemResp#(logNumBytes), logNumBytes);
    function ReadOnlyMemResp#(logNumBytes) fromReadOnlyMemResp(ReadOnlyMemResp#(logNumBytes) resp);
        return resp;
    endfunction
    function ReadOnlyMemResp#(logNumBytes) fromCoarseMemResp(CoarseMemResp#(logNumBytes) resp);
        return ReadOnlyMemResp{ data: resp.data };
    endfunction
    function ReadOnlyMemResp#(logNumBytes) toReadOnlyMemResp(ReadOnlyMemResp#(logNumBytes) resp);
        return resp;
    endfunction
    function CoarseMemResp#(logNumBytes) toCoarseMemResp(ReadOnlyMemResp#(logNumBytes) resp);
        return CoarseMemResp { write: False, data: resp.data };
    endfunction
endinstance

instance IsMemResp#(CoarseMemResp#(logNumBytes), logNumBytes);
    function CoarseMemResp#(logNumBytes) fromReadOnlyMemResp(ReadOnlyMemResp#(logNumBytes) resp);
        return CoarseMemResp{ write: False, data: resp.data };
    endfunction
    function CoarseMemResp#(logNumBytes) fromCoarseMemResp(CoarseMemResp#(logNumBytes) resp);
        return resp;
    endfunction
    function ReadOnlyMemResp#(logNumBytes) toReadOnlyMemResp(CoarseMemResp#(logNumBytes) resp);
        return ReadOnlyMemResp { data: resp.data };
    endfunction
    function CoarseMemResp#(logNumBytes) toCoarseMemResp(CoarseMemResp#(logNumBytes) resp);
        return resp;
    endfunction
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
                AtomicMemOp atomic_op = req.atomic_op;
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

// Memory Mapped Registers

function ActionValue#(memRespT) performMemReqOnRegs(Vector#(numRegs, Reg#(Bit#(TMul#(8,TExp#(logNumBytes))))) regs, memReqT req)
        provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes),
                  IsMemResp#(memRespT, logNumBytes),
                  Add#(a__, TLog#(numRegs), addrSz));
    return (actionvalue
            // Basically perform this operation as if it were an atomic memory
            // operation. Constant propagation should allow for unused hardware to be
            // optimized away.
            Bit#(addrSz) addr = getAddr(req);
            Bit#(TMul#(8,TExp#(logNumBytes))) data = getData(req);
            Bit#(TExp#(logNumBytes)) write_en = getWriteEn(req);
            Vector#(TExp#(logNumBytes), Bit#(1)) write_en_vec = unpack(write_en);
            Bit#(TMul#(8,TExp#(logNumBytes))) write_bit_en = pack(map(signExtend, write_en_vec));
            AtomicMemOp atomic_op = getAtomicOp(req);
            memRespT resp = getDefaultResp(req);

            Bit#(TLog#(numRegs)) index = truncate(addr >> valueOf(logNumBytes));
            if (index <= fromInteger(valueOf(numRegs)-1)) begin
                // valid register
                if (write_en == 0) begin
                    // read only
                    resp = fromAtomicMemResp( AtomicMemResp { write: False, data: regs[index] } );
                end else if ((write_en == '1) && (atomic_op == None)) begin
                    // coarse write
                    regs[index] <= data;
                    resp = fromAtomicMemResp( AtomicMemResp { write: True, data: 0 } );
                end else if (atomic_op == None) begin
                    // byteen write
                    regs[index] <= (data & write_bit_en) | (regs[index] & ~write_bit_en);
                    resp = fromAtomicMemResp( AtomicMemResp { write: True, data: 0 } );
                end else begin
                    // atomic
                    let write_data = atomicMemOpAlu(atomic_op, regs[index], data, write_en);
                    regs[index] <= (write_data & write_bit_en) | (regs[index] & ~write_bit_en);
                    resp = fromAtomicMemResp( AtomicMemResp { write: True, data: regs[index] } );
                end
            end
            return resp;
        endactionvalue);
endfunction

/// This module can create a `ServerPort` of various memory types given a
/// vector of registers.
module mkMemServerPortFromRegs#( Vector#(numRegs, Reg#(Bit#(TMul#(8,TExp#(logNumBytes))))) regs )( ServerPort#(memReqT, memRespT) )
        provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes),
                  IsMemResp#(memRespT, logNumBytes),
                  Bits#(memReqT, memReqSz),
                  Bits#(memRespT, memRespSz),
                  Add#(a__, TLog#(numRegs), addrSz));

    FIFOG#(memReqT) memReqFIFO <- mkLFIFOG;
    FIFOG#(memRespT) memRespFIFO <- mkLFIFOG;

    rule performMemReq;
        let req = memReqFIFO.first;
        memReqFIFO.deq;
        let resp <- performMemReqOnRegs( regs, req );
        memRespFIFO.enq(resp);
    endrule

    interface InputPort request = toInputPort(memReqFIFO);
    interface OutputPort response = toOutputPort(memRespFIFO);
endmodule

function ActionValue#(memRespT) performMemReqOnRegFile(RegFile#(Bit#(rfAddrSz), Bit#(TMul#(8,TExp#(logNumBytes)))) rf, memReqT req)
        provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes),
                  IsMemResp#(memRespT, logNumBytes),
                  Add#(a__, rfAddrSz, addrSz));
    return (actionvalue
            // Basically perform this operation as if it were an atomic memory
            // operation. Constant propagation should allow for unused hardware to be
            // optimized away.
            Bit#(addrSz) addr = getAddr(req);
            Bit#(TMul#(8, TExp#(logNumBytes))) data = getData(req);
            Bit#(TExp#(logNumBytes)) write_en = getWriteEn(req);
            Vector#(TExp#(logNumBytes), Bit#(1)) write_en_vec = unpack(write_en);
            Bit#(TMul#(8, TExp#(logNumBytes))) write_bit_en = pack(map(signExtend, write_en_vec));
            AtomicMemOp atomic_op = getAtomicOp(req);
            memRespT resp = getDefaultResp(req);

            Bit#(rfAddrSz) index = truncate(addr >> valueOf(logNumBytes));
            if (write_en == 0) begin
                // read only
                resp = fromAtomicMemResp( AtomicMemResp { write: False, data: rf.sub(index) } );
            end else if ((write_en == '1) && (atomic_op == None)) begin
                // coarse write
                rf.upd(index, data);
                resp = fromAtomicMemResp( AtomicMemResp { write: True, data: 0 } );
            end else if (atomic_op == None) begin
                // byteen write
                let new_data = (data & write_bit_en) | (rf.sub(index) & ~write_bit_en);
                rf.upd(index, new_data);
                resp = fromAtomicMemResp( AtomicMemResp { write: True, data: 0 } );
            end else begin
                // atomic
                let old_data = rf.sub(index);
                let new_data = (atomicMemOpAlu(atomic_op, old_data, data, write_en) & write_bit_en) | (old_data & ~write_bit_en);
                rf.upd(index, new_data);
                resp = fromAtomicMemResp( AtomicMemResp { write: True, data: old_data } );
            end
            return resp;
        endactionvalue);
endfunction

/// This module can create a `ServerPort` of various memory types given a
/// `RegFile`.
module mkMemServerPortFromRegFile#( RegFile#(Bit#(rfAddrSz), Bit#(TMul#(8,TExp#(logNumBytes)))) rf )( ServerPort#(memReqT, memRespT) )
        provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes),
                  IsMemResp#(memRespT, logNumBytes),
                  Bits#(memReqT, memReqSz),
                  Bits#(memRespT, memRespSz),
                  Add#(a__, rfAddrSz, addrSz));

    FIFOG#(memReqT) memReqFIFO <- mkLFIFOG;
    FIFOG#(memRespT) memRespFIFO <- mkLFIFOG;

    rule performMemReq;
        let req = memReqFIFO.first;
        memReqFIFO.deq;
        let resp <- performMemReqOnRegFile( rf, req );
        memRespFIFO.enq(resp);
    endrule

    interface InputPort request = toInputPort(memReqFIFO);
    interface OutputPort response = toOutputPort(memRespFIFO);
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

// Memory bus -- Works with CoarseMem, ByteEnMem, and AtomicMem interfaces

typedef struct {
    Bit#(addrSz) addr_mask;
    Bit#(addrSz) addr_match;
    TaggedMemServerPort#(addrSz, logNumBytes) ifc;
} MixedMemBusItem#(numeric type addrSz, numeric type logNumBytes);

/**
 * This function produces a `MixedMemBusItem` from an address range.
 *
 * This function will return an error at compile time if the address range
 * cannot be exptessed with an address mask and a match value.
 */
function MixedMemBusItem#(addrSz, logNumBytes) mixedMemBusItemFromAddrRange( Bit#(addrSz) low, Bit#(addrSz) high, TaggedMemServerPort#(addrSz, logNumBytes) ifc );
    let addr_mask = ~(low ^ high);
    let addr_match = low & addr_mask;
    // mask should be a contiguous region of upper bits,
    // low should be the lowest valid address for mask/match combination,
    // and high should be the highest valid address for mask/match combination,
    Bool valid = ((addr_mask & ((~addr_mask) >> 1)) == 0)
                    && ((low & ~addr_mask) == 0)
                    && ((high & ~addr_mask) == ~addr_mask);
    if (valid) begin
        return MixedMemBusItem {
            addr_mask: addr_mask,
            addr_match: addr_match,
            ifc: ifc
        };
    end else begin
        return error("mixedMemBusItemFromAddrRange compilation error: Address range cannot be expressed as match/mask", ?);
    end
endfunction

interface MixedAtomicMemBus#(numeric type nClients, numeric type addrSz, numeric type logNumBytes);
    interface Vector#(nClients, AtomicMemServerPort#(addrSz, logNumBytes)) clients;
    method Maybe#(MemType) getMemType(Bit#(addrSz) addr);
endinterface

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
module mkMixedAtomicMemBus#(Vector#(nServers, MixedMemBusItem#(addrSz, logNumBytes)) bus_items)(MixedAtomicMemBus#(nClients, addrSz, logNumBytes));
    // check for consistency of addr_mask and addr_match in bus_items
    for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
        if ((bus_items[i].addr_mask & bus_items[i].addr_match) != bus_items[i].addr_match) begin
            errorM("mkMixedAtomicMemBus compilation error: Illegal addr_mask addr_match combination");
        end
        for (Integer j = 0 ; j < valueOf(nServers) ; j = j+1) begin
            if (i != j) begin
                Bit#(addrSz) shared_mask = bus_items[i].addr_mask & bus_items[j].addr_mask;
                Bit#(addrSz) different_match = bus_items[i].addr_match ^ bus_items[j].addr_match;
                if ((shared_mask & different_match) == 0) begin
                    errorM("mkMixedAtomicMemBus compilation error: Overlapping address regions in bus_items");
                end
            end
        end
    end

    // Bypass FIFOs to buffer all the inputs and outputs. Without these
    // buffers, this module would add additional scheduling constraints
    // between client items and server items.
    Vector#(nClients, FIFOG#(AtomicMemReq#(addrSz, logNumBytes))) clientMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nClients, FIFOG#(AtomicMemResp#(logNumBytes))) clientMemResp <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(AtomicMemReq#(addrSz, logNumBytes))) serverMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(AtomicMemResp#(logNumBytes))) serverMemResp <- replicateM(mkBypassFIFOG);
    // Bookkeeping FIFOs to keep track of request routing
    // clientBookkeeping can hold valueOf(nServers) to corresponds to an
    // out-of-bounds address.
    Vector#(nClients, FIFOG#(Bit#(TLog#(TAdd#(nServers,1))))) clientBookkeeping <- replicateM(mkPipelineFIFOG);
    Vector#(nServers, FIFOG#(Bit#(TLog#(nClients)))) serverBookkeeping <- replicateM(mkPipelineFIFOG);
    // out-of-bounds responses, acts like another client.
    FIFOG#(AtomicMemResp#(logNumBytes)) oobResp <- mkPipelineFIFOG;

    function Bit#(TLog#(TAdd#(nServers,1))) getServer(AtomicMemReq#(addrSz, logNumBytes) req);
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
        rule connectServerReq;
            // $display("connectServerReq: s = %0d", s);
            case (bus_items[s].ifc) matches
                tagged ReadOnly .ifc: begin
                    if(!isReadOnlyMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedAtomicMemBus: non-ReadOnly request sent to ReadOnly server %0d", s);
                    end
                    ifc.request.enq( toReadOnlyMemReq(serverMemReq[s].first) );
                end
                tagged Coarse   .ifc: begin
                    if(!isCoarseMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedAtomicMemBus: non-Coarse request sent to Coarse server %0d", s);
                    end
                    ifc.request.enq( toCoarseMemReq(serverMemReq[s].first) );
                end
                tagged ByteEn   .ifc: begin
                    if(!isByteEnMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedAtomicMemBus: non-ByteEn request sent to ByteEn server %0d", s);
                    end
                    ifc.request.enq( toByteEnMemReq(serverMemReq[s].first) );
                end
                tagged Atomic   .ifc: begin
                    if(!isAtomicMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedAtomicMemBus: non-Atomic request sent to Atomic server %0d", s);
                    end
                    ifc.request.enq( toAtomicMemReq(serverMemReq[s].first) );
                end
            endcase
            serverMemReq[s].deq;
        endrule
        rule connectServerResp;
            // $display("connectServerResp: s = %0d", s);
            case (bus_items[s].ifc) matches
                tagged ReadOnly .ifc: begin
                    serverMemResp[s].enq( fromReadOnlyMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged Coarse   .ifc: begin
                    serverMemResp[s].enq( fromCoarseMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged ByteEn   .ifc: begin
                    serverMemResp[s].enq( fromByteEnMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged Atomic   .ifc: begin
                    serverMemResp[s].enq( fromAtomicMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
            endcase
        endrule
    end

    MixedAtomicMemBus#(nClients, addrSz, logNumBytes) ifc = (interface MixedAtomicMemBus;
            interface Vector clients = zipWith( toServerPort, clientMemReq, clientMemResp );
            method Maybe#(MemType) getMemType(Bit#(addrSz) addr);
                // This value corresponds to an out-of-bounds address
                Maybe#(Bit#(TLog#(nServers))) server = tagged Invalid;
                for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
                    if ((addr & bus_items[i].addr_mask) == bus_items[i].addr_match) begin
                        server = tagged Valid fromInteger(i);
                    end
                end
                if (server matches tagged Valid .serverIndex) begin
                    return (case (bus_items[serverIndex].ifc) matches
                                tagged ReadOnly .*: tagged Valid ReadOnly;
                                tagged Coarse .*: tagged Valid Coarse;
                                tagged ByteEn .*: tagged Valid ByteEn;
                                tagged Atomic .*: tagged Valid Atomic;
                                default: tagged Invalid;
                            endcase);
                end else begin
                    return tagged Invalid;
                end
            endmethod
        endinterface);

    return ifc;
endmodule

interface MixedMMIOBus#(numeric type nClients, numeric type addrSz, numeric type logNumBytes);
    interface Vector#(nClients, MMIOServerPort#(addrSz, logNumBytes)) clients;
    method Maybe#(MemType) getMemType(Bit#(addrSz) addr);
endinterface

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
module mkMixedMMIOBus#(Vector#(nServers, MixedMemBusItem#(addrSz, logNumBytes)) bus_items)(MixedMMIOBus#(nClients, addrSz, logNumBytes));
    // check for consistency of addr_mask and addr_match in bus_items
    for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
        if ((bus_items[i].addr_mask & bus_items[i].addr_match) != bus_items[i].addr_match) begin
            errorM("mkMixedMMIOBus compilation error: Illegal addr_mask addr_match combination");
        end
        for (Integer j = 0 ; j < valueOf(nServers) ; j = j+1) begin
            if (i != j) begin
                Bit#(addrSz) shared_mask = bus_items[i].addr_mask & bus_items[j].addr_mask;
                Bit#(addrSz) different_match = bus_items[i].addr_match ^ bus_items[j].addr_match;
                if ((shared_mask & different_match) == 0) begin
                    errorM("mkMixedMMIOBus compilation error: Overlapping address regions in bus_items");
                end
            end
        end
    end

    // Bypass FIFOs to buffer all the inputs and outputs. Without these
    // buffers, this module would add additional scheduling constraints
    // between client items and server items.
    Vector#(nClients, FIFOG#(MMIOReq#(addrSz, logNumBytes))) clientMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nClients, FIFOG#(MMIOResp#(logNumBytes))) clientMemResp <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(MMIOReq#(addrSz, logNumBytes))) serverMemReq <- replicateM(mkBypassFIFOG);
    Vector#(nServers, FIFOG#(MMIOResp#(logNumBytes))) serverMemResp <- replicateM(mkBypassFIFOG);
    // Bookkeeping FIFOs to keep track of request routing
    // clientBookkeeping can hold valueOf(nServers) to corresponds to an
    // out-of-bounds address.
    Vector#(nClients, FIFOG#(Bit#(TLog#(TAdd#(nServers,1))))) clientBookkeeping <- replicateM(mkPipelineFIFOG);
    Vector#(nServers, FIFOG#(Bit#(TLog#(nClients)))) serverBookkeeping <- replicateM(mkPipelineFIFOG);
    // out-of-bounds responses, acts like another client.
    FIFOG#(MMIOResp#(logNumBytes)) oobResp <- mkPipelineFIFOG;

    function Bit#(TLog#(TAdd#(nServers,1))) getServer(MMIOReq#(addrSz, logNumBytes) req);
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
        rule connectServerReq;
            // $display("connectServerReq: s = %0d", s);
            case (bus_items[s].ifc) matches
                tagged ReadOnly .ifc: begin
                    if(!isReadOnlyMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedMMIOBus: non-ReadOnly request sent to ReadOnly server %0d", s);
                    end
                    ifc.request.enq( toReadOnlyMemReq(serverMemReq[s].first) );
                end
                tagged Coarse   .ifc: begin
                    if(!isCoarseMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedMMIOBus: non-Coarse request sent to Coarse server %0d", s);
                    end
                    ifc.request.enq( toCoarseMemReq(serverMemReq[s].first) );
                end
                tagged ByteEn   .ifc: begin
                    if(!isByteEnMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedMMIOBus: non-ByteEn request sent to ByteEn server %0d", s);
                    end
                    ifc.request.enq( toByteEnMemReq(serverMemReq[s].first) );
                end
                tagged Atomic   .ifc: begin
                    if(!isAtomicMemReq(serverMemReq[s].first)) begin
                        $fdisplay(stderr, "[WARNING] mkMixedMMIOBus: non-Atomic request sent to Atomic server %0d", s);
                    end
                    ifc.request.enq( toAtomicMemReq(serverMemReq[s].first) );
                end
                tagged MMIO     .ifc: begin
                    // all memory accesses can be mapped to MMIO
                    ifc.request.enq( toMMIOReq(serverMemReq[s].first) );
                end
            endcase
            serverMemReq[s].deq;
        endrule
        rule connectServerResp;
            // $display("connectServerResp: s = %0d", s);
            case (bus_items[s].ifc) matches
                tagged ReadOnly .ifc: begin
                    serverMemResp[s].enq( fromReadOnlyMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged Coarse   .ifc: begin
                    serverMemResp[s].enq( fromCoarseMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged ByteEn   .ifc: begin
                    serverMemResp[s].enq( fromByteEnMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged Atomic   .ifc: begin
                    serverMemResp[s].enq( fromAtomicMemResp(ifc.response.first) );
                    ifc.response.deq;
                end
                tagged MMIO     .ifc: begin
                    serverMemResp[s].enq( ifc.response.first );
                    ifc.response.deq;
                end
            endcase
        endrule
    end

    MixedMMIOBus#(nClients, addrSz, logNumBytes) ifc = (interface MixedMMIOBus;
            interface Vector clients = zipWith( toServerPort, clientMemReq, clientMemResp );
            method Maybe#(MemType) getMemType(Bit#(addrSz) addr);
                // This value corresponds to an out-of-bounds address
                Maybe#(Bit#(TLog#(nServers))) server = tagged Invalid;
                for (Integer i = 0 ; i < valueOf(nServers) ; i = i+1) begin
                    if ((addr & bus_items[i].addr_mask) == bus_items[i].addr_match) begin
                        server = tagged Valid fromInteger(i);
                    end
                end
                if (server matches tagged Valid .serverIndex) begin
                    return (case (bus_items[serverIndex].ifc) matches
                                tagged ReadOnly .*: tagged Valid ReadOnly;
                                tagged Coarse .*: tagged Valid Coarse;
                                tagged ByteEn .*: tagged Valid ByteEn;
                                tagged Atomic .*: tagged Valid Atomic;
                                tagged MMIO .*: tagged Valid MMIO;
                                default: tagged Invalid;
                            endcase);
                end else begin
                    return tagged Invalid;
                end
            endmethod
        endinterface);

    return ifc;
endmodule

////////////////////////////////////////////////////////////////////////////////

// instances for PolymorphicMem

instance ToGenericAtomicMemReq#(ReadOnlyMemReq#(addrSz, logNumBytes), 1, void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes)));
    function GenericAtomicMemReq#(1, void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes))) toGenericAtomicMemReq(ReadOnlyMemReq#(addrSz, logNumBytes) req);
        return GenericAtomicMemReq {
                write_en: 0,
                atomic_op: ?,
                word_addr: truncate(req.addr >> valueOf(logNumBytes)),
                data: 0
            };
    endfunction
endinstance
instance ToGenericAtomicMemPendingReq#(ReadOnlyMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(ReadOnlyMemReq#(addrSz, logNumBytes) req) = ?;
endinstance
instance FromGenericAtomicMemResp#(ReadOnlyMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
    function ReadOnlyMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
        return ReadOnlyMemResp {
                data: resp.data
            };
    endfunction
endinstance

instance ToGenericAtomicMemReq#(CoarseMemReq#(addrSz, logNumBytes), 1, void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes)));
    function GenericAtomicMemReq#(1, void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes))) toGenericAtomicMemReq(CoarseMemReq#(addrSz, logNumBytes) req);
        return GenericAtomicMemReq {
                write_en: pack(req.write),
                atomic_op: ?,
                word_addr: truncate(req.addr >> valueOf(logNumBytes)),
                data: req.data
            };
    endfunction
endinstance
instance ToGenericAtomicMemPendingReq#(CoarseMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(CoarseMemReq#(addrSz, logNumBytes) req) = ?;
endinstance
instance FromGenericAtomicMemResp#(CoarseMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
    function CoarseMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
        return CoarseMemResp {
                write: resp.write,
                data: resp.data
            };
    endfunction
endinstance

instance ToGenericAtomicMemReq#(ByteEnMemReq#(addrSz, logNumBytes), TExp#(logNumBytes), void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes)));
    function GenericAtomicMemReq#(TExp#(logNumBytes), void, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes))) toGenericAtomicMemReq(ByteEnMemReq#(addrSz, logNumBytes) req);
        return GenericAtomicMemReq {
                write_en: req.write_en,
                atomic_op: ?,
                word_addr: truncate(req.addr >> valueOf(logNumBytes)),
                data: req.data
            };
    endfunction
endinstance
instance ToGenericAtomicMemPendingReq#(ByteEnMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(ByteEnMemReq#(addrSz, logNumBytes) req) = ?;
endinstance
// // ByteEnMemResp is an alias of CoarseMemResp, so this instance is not needed
// instance FromGenericAtomicMemResp#(ByteEnMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
//     function ByteEnMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
//         return ByteEnMemResp {
//                 write: resp.write,
//                 data: resp.data
//             };
//     endfunction
// endinstance

instance ToGenericAtomicMemReq#(AtomicMemReq#(addrSz, logNumBytes), TExp#(logNumBytes), AtomicMemOp, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes)));
    function GenericAtomicMemReq#(TExp#(logNumBytes), AtomicMemOp, TSub#(addrSz, logNumBytes), TMul#(8,TExp#(logNumBytes))) toGenericAtomicMemReq(AtomicMemReq#(addrSz, logNumBytes) req);
        return GenericAtomicMemReq {
                write_en: req.write_en,
                atomic_op: req.atomic_op,
                word_addr: truncate(req.addr >> valueOf(logNumBytes)),
                data: req.data
            };
    endfunction
endinstance
instance ToGenericAtomicMemPendingReq#(AtomicMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(AtomicMemReq#(addrSz, logNumBytes) req) = ?;
endinstance
// // AtomicMemResp is an alias of CoarseMemResp, so this instance is not needed
// instance FromGenericAtomicMemResp#(AtomicMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
//     function AtomicMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
//         return AtomicMemResp {
//                 write: resp.write,
//                 data: resp.data
//             };
//     endfunction
// endinstance

instance IsAtomicMemOp#(AtomicMemOp);
    function AtomicMemOp nonAtomicMemOp = None;
    function Bool isAtomicMemOp(AtomicMemOp op);
        return op != None;
    endfunction
endinstance
instance HasAtomicMemOpFunc#(AtomicMemOp, dataSz, writeEnSz)
        provisos (Mul#(writeEnSz, 8, dataSz));
    function Bit#(dataSz) atomicMemOpFunc(AtomicMemOp op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        return atomicMemOpAlu(op, memData, operandData, writeEn);
    endfunction
endinstance

////////////////////////////////////////////////////////////////////////////////

// Translation typeclasses

typeclass SimplifyMemServerPort#(type inMemServerT, type outMemServerT);
    function outMemServerT simplifyMemServerPort(inMemServerT mem);
endtypeclass

instance SimplifyMemServerPort#(MMIOServerPort#(addrSz, logNumBytes), AtomicMemServerPort#(addrSz, logNumBytes));
    function AtomicMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(MMIOServerPort#(addrSz, logNumBytes) mem);
        return (interface AtomicMemServerPort;
                interface InputPort request;
                    method Action enq(AtomicMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( MMIOReq {
                                            write: req.write_en != 0,
                                            byte_en: ((req.write_en != 0) ? req.write_en : '1),
                                            atomic_op: req.atomic_op,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(MMIOServerPort#(addrSz, logNumBytes), ByteEnMemServerPort#(addrSz, logNumBytes));
    function ByteEnMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(MMIOServerPort#(addrSz, logNumBytes) mem);
        return (interface ByteEnMemServerPort;
                interface InputPort request;
                    method Action enq(ByteEnMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( MMIOReq {
                                            write: req.write_en != 0,
                                            byte_en: ((req.write_en != 0) ? req.write_en : '1),
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(MMIOServerPort#(addrSz, logNumBytes), CoarseMemServerPort#(addrSz, logNumBytes));
    function CoarseMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(MMIOServerPort#(addrSz, logNumBytes) mem);
        return (interface CoarseMemServerPort;
                interface InputPort request;
                    method Action enq(CoarseMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( MMIOReq {
                                            write: req.write,
                                            byte_en: '1,
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(MMIOServerPort#(addrSz, logNumBytes), ReadOnlyMemServerPort#(addrSz, logNumBytes));
    function ReadOnlyMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(MMIOServerPort#(addrSz, logNumBytes) mem);
        return (interface ReadOnlyMemServerPort;
                interface InputPort request;
                    method Action enq(ReadOnlyMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( MMIOReq {
                                            write: False,
                                            byte_en: '1,
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: 0 } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response;
                    method ReadOnlyMemResp#(logNumBytes) first;
                        return ReadOnlyMemResp { data: mem.response.first.data };
                    endmethod
                    method Action deq;
                        mem.response.deq;
                    endmethod
                    method Bool canDeq;
                        return mem.response.canDeq;
                    endmethod
                endinterface
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(AtomicMemServerPort#(addrSz, logNumBytes), ByteEnMemServerPort#(addrSz, logNumBytes));
    function ByteEnMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(AtomicMemServerPort#(addrSz, logNumBytes) mem);
        return (interface ByteEnMemServerPort;
                interface InputPort request;
                    method Action enq(ByteEnMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( AtomicMemReq {
                                            write_en: req.write_en,
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(AtomicMemServerPort#(addrSz, logNumBytes), CoarseMemServerPort#(addrSz, logNumBytes));
    function CoarseMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(AtomicMemServerPort#(addrSz, logNumBytes) mem);
        return (interface CoarseMemServerPort;
                interface InputPort request;
                    method Action enq(CoarseMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( AtomicMemReq {
                                            write_en: req.write ? '1 : 0,
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(AtomicMemServerPort#(addrSz, logNumBytes), ReadOnlyMemServerPort#(addrSz, logNumBytes));
    function ReadOnlyMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(AtomicMemServerPort#(addrSz, logNumBytes) mem);
        return (interface ReadOnlyMemServerPort;
                interface InputPort request;
                    method Action enq(ReadOnlyMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( AtomicMemReq {
                                            write_en: 0,
                                            atomic_op: None,
                                            addr: req.addr,
                                            data: 0 } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response;
                    method ReadOnlyMemResp#(logNumBytes) first;
                        return ReadOnlyMemResp { data: mem.response.first.data };
                    endmethod
                    method Action deq;
                        mem.response.deq;
                    endmethod
                    method Bool canDeq;
                        return mem.response.canDeq;
                    endmethod
                endinterface
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(ByteEnMemServerPort#(addrSz, logNumBytes), CoarseMemServerPort#(addrSz, logNumBytes));
    function CoarseMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(ByteEnMemServerPort#(addrSz, logNumBytes) mem);
        return (interface CoarseMemServerPort;
                interface InputPort request;
                    method Action enq(CoarseMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( ByteEnMemReq {
                                            write_en: req.write ? '1 : 0,
                                            addr: req.addr,
                                            data: req.data } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response = mem.response;
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(ByteEnMemServerPort#(addrSz, logNumBytes), ReadOnlyMemServerPort#(addrSz, logNumBytes));
    function ReadOnlyMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(ByteEnMemServerPort#(addrSz, logNumBytes) mem);
        return (interface ReadOnlyMemServerPort;
                interface InputPort request;
                    method Action enq(ReadOnlyMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( ByteEnMemReq {
                                            write_en: 0,
                                            addr: req.addr,
                                            data: 0 } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response;
                    method ReadOnlyMemResp#(logNumBytes) first;
                        return ReadOnlyMemResp { data: mem.response.first.data };
                    endmethod
                    method Action deq;
                        mem.response.deq;
                    endmethod
                    method Bool canDeq;
                        return mem.response.canDeq;
                    endmethod
                endinterface
            endinterface);
    endfunction
endinstance

instance SimplifyMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes), ReadOnlyMemServerPort#(addrSz, logNumBytes));
    function ReadOnlyMemServerPort#(addrSz, logNumBytes) simplifyMemServerPort(CoarseMemServerPort#(addrSz, logNumBytes) mem);
        return (interface ReadOnlyMemServerPort;
                interface InputPort request;
                    method Action enq(ReadOnlyMemReq#(addrSz, logNumBytes) req);
                        mem.request.enq( CoarseMemReq {
                                            write: False,
                                            addr: req.addr,
                                            data: 0 } );
                    endmethod
                    method Bool canEnq;
                        return mem.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response;
                    method ReadOnlyMemResp#(logNumBytes) first;
                        return ReadOnlyMemResp { data: mem.response.first.data };
                    endmethod
                    method Action deq;
                        mem.response.deq;
                    endmethod
                    method Bool canDeq;
                        return mem.response.canDeq;
                    endmethod
                endinterface
            endinterface);
    endfunction
endinstance

////

typeclass MkEmulateMemServerPort#(type inMemServerT, type outMemServerT);
    module mkEmulateMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass

instance MkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes), MMIOServerPort#(addrSz, logNumBytes));
    module mkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes) mem)(MMIOServerPort#(addrSz, logNumBytes))
            provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
        AtomicMemServerPort#(addrSz, logNumBytes) _mem <- mkEmulateMemServerPort(mem);
        interface InputPort request;
            method Action enq(MMIOReq#(addrSz, logNumBytes) req);
                _mem.request.enq(AtomicMemReq{ write_en: getWriteEn(req), atomic_op: req.atomic_op, addr: req.addr, data: req.data });
            endmethod
            method Bool canEnq;
                return _mem.request.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method ByteEnMemResp#(logNumBytes) first;
                return _mem.response.first;
            endmethod
            method Action deq;
                _mem.response.deq;
            endmethod
            method Bool canDeq;
                return _mem.response.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes), AtomicMemServerPort#(addrSz, logNumBytes));
    module mkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes) mem)(AtomicMemServerPort#(addrSz, logNumBytes))
            provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
        // bookkeeping reg
        Ehr#(2, Maybe#(AtomicBRAMPendingReq#(logNumBytes))) pendingReq <- mkEhr(tagged Invalid);
        Reg#(Bit#(dataSz)) atomicOpData <- mkReg(0);
        Reg#(Bit#(addrSz)) atomicOpAddress <- mkReg(0);
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
                AtomicMemOp atomic_op = req.atomic_op;
                if (req.write_en == 0) begin
                    atomic_op = None;
                end else if ((req.atomic_op == None) && (req.write_en != '1)) begin
                    // use swap to implement narrow stores
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

instance MkEmulateMemServerPort#(ByteEnMemServerPort#(addrSz, logNumBytes), AtomicMemServerPort#(addrSz, logNumBytes));
    module mkEmulateMemServerPort#(ByteEnMemServerPort#(addrSz, logNumBytes) mem)(AtomicMemServerPort#(addrSz, logNumBytes))
            provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
        // bookkeeping reg
        Ehr#(2, Maybe#(AtomicBRAMPendingReq#(logNumBytes))) pendingReq <- mkEhr(tagged Invalid);
        Reg#(Bit#(dataSz)) atomicOpData <- mkReg(0);
        Reg#(Bit#(addrSz)) atomicOpAddress <- mkReg(0);
        Ehr#(2, Maybe#(AtomicMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

        // Add a buffer to the byteEn mem response to avoid having requests.enq
        // and response.deq together in performAtomicMemoryOp
        FIFOG#(ByteEnMemResp#(logNumBytes)) byteEnMemRespFIFO <- mkBypassFIFOG;

        mkConnection(mem.response, toInputPort(byteEnMemRespFIFO));

        rule performAtomicMemoryOp(pendingReq[0] matches tagged Valid .req
                                    &&& req.atomic_op != None);
            let writeData = atomicMemOpAlu(req.atomic_op, byteEnMemRespFIFO.first.data, atomicOpData, req.write_en);
            mem.request.enq( ByteEnMemReq{ write_en: req.write_en, addr: atomicOpAddress, data: writeData } );
            pendingReq[0] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: None, rmw_write: True };
            atomicOpData <= byteEnMemRespFIFO.first.data;
            byteEnMemRespFIFO.deq;
        endrule

        rule getRespFromCore(pendingReq[0] matches tagged Valid .req
                                &&& req.atomic_op == None
                                &&& !isValid(pendingResp[0]));
            pendingResp[0] <= tagged Valid AtomicMemResp{ write: req.write_en != 0, data: (req.rmw_write ? atomicOpData : byteEnMemRespFIFO.first.data) };
            pendingReq[0] <= tagged Invalid;
            byteEnMemRespFIFO.deq;
        endrule

        interface InputPort request;
            method Action enq(AtomicMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReq[1]));
                // Clean the atomic_op passed in
                AtomicMemOp atomic_op = req.atomic_op;
                if (req.write_en == 0) begin
                    atomic_op = None;
                end
                pendingReq[1] <= tagged Valid AtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: atomic_op, rmw_write: False };
                if (atomic_op == None) begin
                    // normal read/write
                    mem.request.enq( ByteEnMemReq { write_en: req.write_en, addr: req.addr, data: req.data } );
                end else begin
                    // atomic memory operation, do read first
                    mem.request.enq( ByteEnMemReq { write_en: 0, addr: req.addr, data: req.data } );
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

// This is implemented like the emulated AtomicMem
instance MkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes), ByteEnMemServerPort#(addrSz, logNumBytes));
    module mkEmulateMemServerPort#(CoarseMemServerPort#(addrSz, logNumBytes) mem)(ByteEnMemServerPort#(addrSz, logNumBytes))
            provisos (NumAlias#(TMul#(8,TExp#(logNumBytes)), dataSz));
        // bookkeeping reg
        Ehr#(2, Maybe#(Bit#(TExp#(logNumBytes)))) pendingReqWriteEn <- mkEhr(tagged Invalid);
        Reg#(Bit#(dataSz)) byteEnData <- mkReg(0);
        Reg#(Bit#(addrSz)) byteEnAddress <- mkReg(0);
        Ehr#(2, Maybe#(ByteEnMemResp#(logNumBytes))) pendingResp <- mkEhr(tagged Invalid);

        // Add a buffer to the coarse mem response to avoid having requests.enq
        // and response.deq together in performByteEnMemoryOp
        FIFOG#(CoarseMemResp#(logNumBytes)) coarseMemRespFIFO <- mkBypassFIFOG;

        mkConnection(mem.response, toInputPort(coarseMemRespFIFO));

        rule performByteEnMemoryOp(pendingReqWriteEn[0] matches tagged Valid .write_en
                                    &&& ((write_en != 0) && (write_en != '1)));
            Vector#(TExp#(logNumBytes), Bit#(1)) byteEnVec = unpack(write_en);
            Bit#(dataSz) bitMask = pack(map(signExtend, byteEnVec));
            let writeData = (byteEnData & bitMask) | (coarseMemRespFIFO.first.data & ~bitMask);
            mem.request.enq( CoarseMemReq{ write: True, addr: byteEnAddress, data: writeData } );
            pendingReqWriteEn[0] <= tagged Valid '1;
            coarseMemRespFIFO.deq;
        endrule

        rule getRespFromCore(pendingReqWriteEn[0] matches tagged Valid .write_en
                                &&& ((write_en == 0) || (write_en == '1))
                                &&& !isValid(pendingResp[0]));
            pendingResp[0] <= tagged Valid ByteEnMemResp{ write: write_en != 0, data: coarseMemRespFIFO.first.data };
            pendingReqWriteEn[0] <= tagged Invalid;
            coarseMemRespFIFO.deq;
        endrule

        interface InputPort request;
            method Action enq(ByteEnMemReq#(addrSz, logNumBytes) req) if (!isValid(pendingReqWriteEn[1]));
                pendingReqWriteEn[1] <= tagged Valid req.write_en;
                if ((req.write_en == 0) || (req.write_en == '1)) begin
                    // normal read/write
                    mem.request.enq( CoarseMemReq { write: req.write_en == '1, addr: req.addr, data: req.data } );
                end else begin
                    // narrow store, do read first
                    mem.request.enq( CoarseMemReq { write: False, addr: req.addr, data: req.data } );
                    // store operand data for later
                    byteEnData <= req.data;
                    byteEnAddress <= req.addr;
                end
            endmethod
            method Bool canEnq;
                return !isValid(pendingReqWriteEn[1]);
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

//----------------------------------------------------------------------------//

typeclass MkNarrowerMemServerPort#(type inMemServerT, type outMemServerT);
    module mkNarrowerMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass

instance MkNarrowerMemServerPort#(CoarseMemServerPort#(addrSz, inLogNumBytes), CoarseMemServerPort#(addrSz, outLogNumBytes))
        provisos (Add#(logWidthFactor, outLogNumBytes, inLogNumBytes),
                  Add#(a__, logWidthFactor, addrSz));
    module mkNarrowerMemServerPort#(CoarseMemServerPort#(addrSz, inLogNumBytes) mem)(CoarseMemServerPort#(addrSz, outLogNumBytes));
        // read requires a single read
        // write requires a read followed by a write
        FIFOG#(CoarseMemResp#(inLogNumBytes)) inRespFIFO <- mkBypassFIFOG;
        FIFOG#(CoarseMemResp#(outLogNumBytes)) outRespFIFO <- mkBypassFIFOG;
        Reg#(Bit#(TMul#(TExp#(outLogNumBytes), 8))) reqData <- mkReg(0);
        Reg#(Bit#(addrSz)) reqAddr <- mkReg(0);
        Ehr#(2, Maybe#(Bool)) pendingReqIsWrite <- mkEhr(tagged Invalid);

        mkConnection(mem.response, toInputPort(inRespFIFO));

        rule handleWrite(pendingReqIsWrite[0] matches tagged Valid .isWrite
                        &&& (isWrite && !inRespFIFO.first.write));
            Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) write_data_vec = unpack(inRespFIFO.first.data);
            Bit#(logWidthFactor) offset = truncate(reqAddr >> valueOf(outLogNumBytes));
            write_data_vec[offset] = reqData;
            mem.request.enq( CoarseMemReq { write: True, addr: reqAddr, data: pack(write_data_vec) } );
            inRespFIFO.deq;
        endrule

        rule handleResp(pendingReqIsWrite[0] matches tagged Valid .isWrite
                        &&& (!isWrite || inRespFIFO.first.write));
            Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) read_data_vec = unpack(inRespFIFO.first.data);
            Bit#(logWidthFactor) offset = truncate(reqAddr >> valueOf(outLogNumBytes));
            outRespFIFO.enq( CoarseMemResp { write: isWrite, data: read_data_vec[offset] } );
            inRespFIFO.deq;
            pendingReqIsWrite[0] <= tagged Invalid;
        endrule

        interface InputPort request;
            method Action enq(CoarseMemReq#(addrSz, outLogNumBytes) req) if (!isValid(pendingReqIsWrite[1]));
                reqAddr <= req.addr;
                if (req.write) begin
                    reqData <= req.data;
                end
                mem.request.enq( CoarseMemReq {
                                    write: False,
                                    addr: req.addr,
                                    data: 0
                                } );
                pendingReqIsWrite[1] <= tagged Valid req.write;
            endmethod
            method Bool canEnq;
                return mem.request.canEnq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkNarrowerMemServerPort#(AtomicMemServerPort#(addrSz, inLogNumBytes), AtomicMemServerPort#(addrSz, outLogNumBytes))
        provisos (Add#(logWidthFactor, outLogNumBytes, inLogNumBytes),
                  Add#(a__, logWidthFactor, addrSz));
    module mkNarrowerMemServerPort#(AtomicMemServerPort#(addrSz, inLogNumBytes) mem)(AtomicMemServerPort#(addrSz, outLogNumBytes));
        FIFOG#(Bit#(logWidthFactor)) pendingReqOffset <- mkFIFOG;

        interface InputPort request;
            method Action enq(AtomicMemReq#(addrSz, outLogNumBytes) req);
                Bit#(logWidthFactor) offset = truncate(req.addr >> valueOf(outLogNumBytes));
                Vector#(TExp#(logWidthFactor), Bit#(TExp#(outLogNumBytes))) write_en_vec = replicate(0);
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(TExp#(outLogNumBytes),8))) data_vec = replicate(req.data);
                write_en_vec[offset] = req.write_en;
                mem.request.enq( AtomicMemReq {
                                    write_en: pack(write_en_vec),
                                    atomic_op: req.atomic_op,
                                    addr: req.addr,
                                    data: pack(data_vec)
                                } );
                pendingReqOffset.enq(offset);
            endmethod
            method Bool canEnq;
                return mem.request.canEnq && pendingReqOffset.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method AtomicMemResp#(outLogNumBytes) first;
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) read_data_vec = unpack(mem.response.first.data);
                return AtomicMemResp { write: mem.response.first.write, data: read_data_vec[pendingReqOffset.first] };
            endmethod
            method Action deq;
                mem.response.deq;
                pendingReqOffset.deq;
            endmethod
            method Bool canDeq;
                return mem.response.canDeq && pendingReqOffset.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkNarrowerMemServerPort#(MMIOServerPort#(addrSz, inLogNumBytes), MMIOServerPort#(addrSz, outLogNumBytes))
        provisos (Add#(logWidthFactor, outLogNumBytes, inLogNumBytes),
                  Add#(a__, logWidthFactor, addrSz));
    module mkNarrowerMemServerPort#(MMIOServerPort#(addrSz, inLogNumBytes) mem)(MMIOServerPort#(addrSz, outLogNumBytes));
        FIFOG#(Bit#(logWidthFactor)) pendingReqOffset <- mkFIFOG;

        interface InputPort request;
            method Action enq(MMIOReq#(addrSz, outLogNumBytes) req);
                Bit#(logWidthFactor) offset = truncate(req.addr >> valueOf(outLogNumBytes));
                Vector#(TExp#(logWidthFactor), Bit#(TExp#(outLogNumBytes))) byte_en_vec = replicate(0);
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(TExp#(outLogNumBytes),8))) data_vec = replicate(req.data);
                byte_en_vec[offset] = req.byte_en;
                mem.request.enq( MMIOReq {
                                    write: req.write,
                                    byte_en: pack(byte_en_vec),
                                    atomic_op: req.atomic_op,
                                    addr: req.addr,
                                    data: pack(data_vec)
                                } );
                pendingReqOffset.enq(offset);
            endmethod
            method Bool canEnq;
                return mem.request.canEnq && pendingReqOffset.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method MMIOResp#(outLogNumBytes) first;
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) read_data_vec = unpack(mem.response.first.data);
                return MMIOResp { write: mem.response.first.write, data: read_data_vec[pendingReqOffset.first] };
            endmethod
            method Action deq;
                mem.response.deq;
                pendingReqOffset.deq;
            endmethod
            method Bool canDeq;
                return mem.response.canDeq && pendingReqOffset.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkNarrowerMemServerPort#(ByteEnMemServerPort#(addrSz, inLogNumBytes), ByteEnMemServerPort#(addrSz, outLogNumBytes))
        provisos (Add#(logWidthFactor, outLogNumBytes, inLogNumBytes),
                  Add#(a__, logWidthFactor, addrSz));
    module mkNarrowerMemServerPort#(ByteEnMemServerPort#(addrSz, inLogNumBytes) mem)(ByteEnMemServerPort#(addrSz, outLogNumBytes));
        FIFOG#(Bit#(logWidthFactor)) pendingReqOffset <- mkFIFOG;

        interface InputPort request;
            method Action enq(ByteEnMemReq#(addrSz, outLogNumBytes) req);
                Bit#(logWidthFactor) offset = truncate(req.addr >> valueOf(outLogNumBytes));
                Vector#(TExp#(logWidthFactor), Bit#(TExp#(outLogNumBytes))) write_en_vec = replicate(0);
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(TExp#(outLogNumBytes),8))) data_vec = replicate(req.data);
                write_en_vec[offset] = req.write_en;
                mem.request.enq( ByteEnMemReq {
                                    write_en: pack(write_en_vec),
                                    addr: req.addr,
                                    data: pack(data_vec)
                                } );
                pendingReqOffset.enq(offset);
            endmethod
            method Bool canEnq;
                return mem.request.canEnq && pendingReqOffset.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method ByteEnMemResp#(outLogNumBytes) first;
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) read_data_vec = unpack(mem.response.first.data);
                return ByteEnMemResp { write: mem.response.first.write, data: read_data_vec[pendingReqOffset.first] };
            endmethod
            method Action deq;
                mem.response.deq;
                pendingReqOffset.deq;
            endmethod
            method Bool canDeq;
                return mem.response.canDeq && pendingReqOffset.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkNarrowerMemServerPort#(ReadOnlyMemServerPort#(addrSz, inLogNumBytes), ReadOnlyMemServerPort#(addrSz, outLogNumBytes))
        provisos (Add#(logWidthFactor, outLogNumBytes, inLogNumBytes),
                  Add#(a__, logWidthFactor, addrSz));
    module mkNarrowerMemServerPort#(ReadOnlyMemServerPort#(addrSz, inLogNumBytes) mem)(ReadOnlyMemServerPort#(addrSz, outLogNumBytes));
        FIFOG#(Bit#(logWidthFactor)) pendingReqOffset <- mkFIFOG;

        interface InputPort request;
            method Action enq(ReadOnlyMemReq#(addrSz, outLogNumBytes) req);
                Bit#(logWidthFactor) offset = truncate(req.addr >> valueOf(outLogNumBytes));
                mem.request.enq( ReadOnlyMemReq { addr: req.addr } );
                pendingReqOffset.enq(offset);
            endmethod
            method Bool canEnq;
                return mem.request.canEnq && pendingReqOffset.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method ReadOnlyMemResp#(outLogNumBytes) first;
                Vector#(TExp#(logWidthFactor), Bit#(TMul#(8,TExp#(outLogNumBytes)))) read_data_vec = unpack(mem.response.first.data);
                return ReadOnlyMemResp { data: read_data_vec[pendingReqOffset.first] };
            endmethod
            method Action deq;
                mem.response.deq;
                pendingReqOffset.deq;
            endmethod
            method Bool canDeq;
                return mem.response.canDeq && pendingReqOffset.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

//----------------------------------------------------------------------------//

typeclass WiderMemServerPort#(type inMemServerT, type outMemServerT);
    module mkWiderMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass

endpackage
