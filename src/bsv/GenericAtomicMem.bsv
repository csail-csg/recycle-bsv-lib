
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
 * This package contains types, interfaces, and modules for a generic memory
 * type that supports atomic memory operations.
 *
 * The motivation behind this package is to give base memory implementations
 * that can be built upon to produce specialized memory interfaces.
 */
package GenericAtomicMem;

import BRAMCore::*;
import BuildVector::*;
import RegFile::*;
import Vector::*;

import Ehr::*;
import FIFOG::*;
import Port::*;

typedef struct {
    Bit#(writeEnSz) write_en;
    atomicMemOpT atomic_op;
    Bit#(wordAddrSz) word_addr;
    Bit#(dataSz) data;
} GenericAtomicMemReq#(numeric type writeEnSz, type atomicMemOpT, numeric type wordAddrSz, numeric type dataSz) deriving (Bits, Eq, FShow);

typedef struct {
    Bool write;
    Bit#(dataSz) data;
} GenericAtomicMemResp#(numeric type dataSz) deriving (Bits, Eq, FShow);

typedef ServerPort#(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz), GenericAtomicMemResp#(dataSz))
        GenericAtomicMemServerPort#(numeric type writeEnSz, type atomicMemOpT, numeric type wordAddrSz, numeric type dataSz);

typedef ClientPort#(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz), GenericAtomicMemResp#(dataSz))
        GenericAtomicMemClientPort#(numeric type writeEnSz, type atomicMemOpT, numeric type wordAddrSz, numeric type dataSz);

////////////////////////////////////////////////////////////////////////////////

// AtomicMemOp types, typeclasses, and instances

typeclass IsAtomicMemOp#(type atomicMemOpT);
    function atomicMemOpT nonAtomicMemOp;
    function Bool isAtomicMemOp(atomicMemOpT op);
endtypeclass

typeclass HasAtomicMemOpFunc#(type atomicMemOpT, numeric type dataSz, numeric type writeEnSz)
        provisos (IsAtomicMemOp#(atomicMemOpT));
    function Bit#(dataSz) atomicMemOpFunc(atomicMemOpT op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
endtypeclass

typedef void AMONone;

typedef enum {
    None,
    Swap
} AMOSwap deriving (Bits, Eq, FShow, Bounded);

typedef enum {
    None,
    Swap,
    And,
    Or,
    Xor
} AMOLogical deriving (Bits, Eq, FShow, Bounded);

typedef enum {
    None,
    Swap,
    And,
    Or,
    Xor,
    Add,
    Min,
    Max,
    Minu,
    Maxu
} AMOArithmetic deriving (Bits, Eq, FShow, Bounded);

/// This function extends byte enables into bit enables.
function Bit#(dataSz) writeEnExtend(Bit#(writeEnSz) write_en)
        provisos (Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz));
    Vector#(writeEnSz, Bit#(1)) write_en_vec = unpack(write_en);
    return pack(map(signExtend, write_en_vec));
endfunction

function Bit#(dataSz) emulateWriteEn(Bit#(dataSz) memData, Bit#(dataSz) writeData, Bit#(writeEnSz) writeEn)
        provisos (Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz));
    Bit#(dataSz) bitEn = writeEnExtend(writeEn);
    return (writeData & bitEn) | (memData & ~bitEn);
endfunction

instance IsAtomicMemOp#(AMONone);
    function AMONone nonAtomicMemOp = ?;
    function Bool isAtomicMemOp(AMONone op) = False;
endinstance
instance HasAtomicMemOpFunc#(AMONone, dataSz, writeEnSz);
    function Bit#(dataSz) atomicMemOpFunc(AMONone op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        return operandData;
    endfunction
endinstance

instance IsAtomicMemOp#(AMOSwap);
    function AMOSwap nonAtomicMemOp = None;
    function Bool isAtomicMemOp(AMOSwap op) = (op != None);
endinstance
instance HasAtomicMemOpFunc#(AMOSwap, dataSz, writeEnSz);
    function Bit#(dataSz) atomicMemOpFunc(AMOSwap op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        return operandData;
    endfunction
endinstance

instance IsAtomicMemOp#(AMOLogical);
    function AMOLogical nonAtomicMemOp = None;
    function Bool isAtomicMemOp(AMOLogical op) = (op != None);
endinstance
instance HasAtomicMemOpFunc#(AMOLogical, dataSz, writeEnSz);
    function Bit#(dataSz) atomicMemOpFunc(AMOLogical op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        return (case (op)
                    None: operandData;
                    Swap: operandData;
                    And:  (operandData & memData);
                    Or:   (operandData | memData);
                    Xor:  (operandData ^ memData);
                    default: operandData;
                endcase);
    endfunction
endinstance

instance IsAtomicMemOp#(AMOArithmetic);
    function AMOArithmetic nonAtomicMemOp = None;
    function Bool isAtomicMemOp(AMOArithmetic op) = (op != None);
endinstance
instance HasAtomicMemOpFunc#(AMOArithmetic, dataSz, writeEnSz)
        provisos(Mul#(writeEnSz, byteSz, dataSz),
                 Add#(a__, 1, dataSz),
                 Add#(b__, 1, byteSz));
    function Bit#(dataSz) atomicMemOpFunc(AMOArithmetic op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        Bit#(dataSz) bitEn = writeEnExtend(writeEn);
        Vector#(writeEnSz, Bit#(byteSz)) memDataVec = unpack(memData);
        Vector#(writeEnSz, Bit#(byteSz)) operandDataVec = unpack(operandData);
        Bit#(1) memDataMSB = 0;
        Bit#(1) operandDataMSB = 0;
        Bool isSigned = ((op == Min) || (op == Max));
        for (Integer i = 0 ; i < valueOf(writeEnSz) ; i = i+1) begin
            if (writeEn[i] == 1) begin
                memDataMSB = msb(memDataVec[i]);
                operandDataMSB = msb(operandDataVec[i]);
            end
        end

        Bit#(dataSz) maskedMemData = (memData & bitEn) | (isSigned ? (signExtend(memDataMSB) & ~bitEn) : 0);
        Bit#(dataSz) maskedOperandData = (operandData & bitEn) | (isSigned ? (signExtend(operandDataMSB) & ~bitEn) : 0);

        Int#(TAdd#(1,dataSz)) memInt = unpack(isSigned ? signExtend(maskedMemData) : zeroExtend(maskedMemData));
        Int#(TAdd#(1,dataSz)) operandInt = unpack(isSigned ? signExtend(maskedOperandData) : zeroExtend(maskedOperandData));
        Bool operandDataLarger = operandInt > memInt;

        return (case (op)
                    None: operandData;
                    Swap: operandData;
                    And:  (operandData & memData);
                    Or:   (operandData | memData);
                    Xor:  (operandData ^ memData);
                    Add:  ((operandData & bitEn) + (memData & bitEn));
                    Min:  (operandDataLarger ? memData : operandData);
                    Max:  (operandDataLarger ? operandData : memData);
                    Minu: (operandDataLarger ? memData : operandData);
                    Maxu: (operandDataLarger ? operandData : memData);
                    default: operandData;
                endcase);
    endfunction
endinstance

////////////////////////////////////////////////////////////////////////////////

// Memory implementations

typedef struct {
    Bit#(writeEnSz) write_en;
    atomicMemOpT atomic_op;
    Bool rmw_write;
} GenericAtomicBRAMPendingReq#(numeric type writeEnSz, type atomicMemOpT) deriving (Bits, Eq, FShow);

/// This function is needed because BRAMCore does not support write enables
/// that are not 8 or 9 bits wide.
function BRAM_PORT_BE#(addrT, dataT, writeEnSz) to_BRAM_PORT_BE(BRAM_PORT#(addrT, dataT) bram);
    return (interface BRAM_PORT_BE;
                method Action put(Bit#(writeEnSz) writeen, addrT addr, dataT data);
                    bram.put(writeen != 0, addr, data);
                endmethod
                method dataT read = bram.read;
            endinterface);
endfunction

function BRAM_DUAL_PORT_BE#(addrT, dataT, writeEnSz) to_BRAM_DUAL_PORT_BE(BRAM_DUAL_PORT#(addrT, dataT) bram);
    return (interface BRAM_DUAL_PORT_BE;
                interface BRAM_PORT_BE a;
                    method Action put(Bit#(writeEnSz) writeen, addrT addr, dataT data);
                        bram.a.put(writeen != 0, addr, data);
                    endmethod
                    method dataT read = bram.a.read;
                endinterface
                interface BRAM_PORT_BE b;
                    method Action put(Bit#(writeEnSz) writeen, addrT addr, dataT data);
                        bram.b.put(writeen != 0, addr, data);
                    endmethod
                    method dataT read = bram.b.read;
                endinterface
            endinterface);
endfunction

/// This type matches the LoadFormat type in the Bluespec Reference Guide
typedef union tagged {
    void   None;
    String Hex;
    String Binary;
} LoadFormat deriving (Bits, Eq);

module mkGenericAtomicBRAM#(Integer numWords)(GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz),
                  Bits#(atomicMemOpT, atomicMemOpSz));
    let _m <- mkGenericAtomicBRAMLoad(numWords, tagged None);
    return _m;
endmodule

module mkGenericAtomicBRAMLoad#(Integer numWords, LoadFormat loadFile)(GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz), // This is needed for mkBRAMCore1BE
                  Bits#(atomicMemOpT, atomicMemOpSz));
    // If numWords == 0, then assume the entire address space is used
    Integer actualNumWords = numWords == 0 ? valueOf(TExp#(wordAddrSz)) : numWords;

    // Instantiate the BRAM
    BRAM_PORT_BE#(Bit#(wordAddrSz), Bit#(dataSz), writeEnSz) bram;
    if (valueOf(writeEnSz) == 1) begin
        BRAM_PORT#(Bit#(wordAddrSz), Bit#(dataSz)) bram_non_be;
        case (loadFile) matches
            tagged None: bram_non_be <- mkBRAMCore1(actualNumWords, False);
            tagged Hex .hexfile: bram_non_be <- mkBRAMCore1Load(actualNumWords, False, hexfile, False);
            tagged Binary .binfile: bram_non_be <- mkBRAMCore1Load(actualNumWords, False, binfile, True);
        endcase
        bram = to_BRAM_PORT_BE(bram_non_be);
    end else begin
        case (loadFile) matches
            tagged None: bram <- mkBRAMCore1BE(actualNumWords, False);
            tagged Hex .hexfile: bram <- mkBRAMCore1BELoad(actualNumWords, False, hexfile, False);
            tagged Binary .binfile: bram <- mkBRAMCore1BELoad(actualNumWords, False, binfile, True);
        endcase
    end

    Ehr#(2, Maybe#(GenericAtomicBRAMPendingReq#(writeEnSz, atomicMemOpT))) pendingReq <- mkEhr(tagged Invalid);
    FIFOG#(GenericAtomicMemResp#(dataSz)) pendingResp <- mkBypassFIFOG;
    Reg#(Bit#(wordAddrSz)) atomicOpWordAddr <- mkReg(0);
    Reg#(Bit#(dataSz)) atomicOpData <- mkReg(0);

    rule performAtomicMemoryOp( pendingReq[0] matches tagged Valid .req
                                &&& isAtomicMemOp(req.atomic_op));
        let writeData = atomicMemOpFunc(req.atomic_op, bram.read, atomicOpData, req.write_en);
        bram.put(req.write_en, atomicOpWordAddr, writeData);
        pendingReq[0] <= tagged Valid GenericAtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: nonAtomicMemOp, rmw_write: True };
        atomicOpData <= bram.read;
    endrule

    rule getRespFromCore( pendingReq[0] matches tagged Valid .req
                          &&& !isAtomicMemOp(req.atomic_op));
        pendingResp.enq(GenericAtomicMemResp{ write: req.write_en != 0, data: (req.rmw_write ? atomicOpData : bram.read) });
        pendingReq[0] <= tagged Invalid;
    endrule

    interface InputPort request;
        method Action enq(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req) if (!isValid(pendingReq[1]));
            let atomic_op = (req.write_en == 0) ? nonAtomicMemOp : req.atomic_op;
            if (isAtomicMemOp(atomic_op)) begin
                bram.put(0, req.word_addr, req.data);
                atomicOpWordAddr <= req.word_addr;
                atomicOpData <= req.data;
            end else begin
                bram.put(req.write_en, req.word_addr, req.data);
            end
            pendingReq[1] <= tagged Valid GenericAtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: atomic_op, rmw_write: False };
        endmethod
        method Bool canEnq;
            return !isValid(pendingReq[1]);
        endmethod
    endinterface
    interface OutputPort response = toOutputPort(pendingResp);
endmodule

module mkGenericAtomicBRAMLoad2Port#(Integer numWords, LoadFormat loadFile)(Vector#(2, GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz), // This is needed for mkBRAMCore1BE
                  Bits#(atomicMemOpT, atomicMemOpSz));
    // If numWords == 0, then assume the entire address space is used
    Integer actualNumWords = numWords == 0 ? valueOf(TExp#(wordAddrSz)) : numWords;

    // Instantiate the BRAM
    BRAM_DUAL_PORT_BE#(Bit#(wordAddrSz), Bit#(dataSz), writeEnSz) bram;
    if (valueOf(writeEnSz) == 1) begin
        BRAM_DUAL_PORT#(Bit#(wordAddrSz), Bit#(dataSz)) bram_non_be;
        case (loadFile) matches
            tagged None: bram_non_be <- mkBRAMCore2(actualNumWords, False);
            tagged Hex .hexfile: bram_non_be <- mkBRAMCore2Load(actualNumWords, False, hexfile, False);
            tagged Binary .binfile: bram_non_be <- mkBRAMCore2Load(actualNumWords, False, binfile, True);
        endcase
        bram = to_BRAM_DUAL_PORT_BE(bram_non_be);
    end else begin
        case (loadFile) matches
            tagged None: bram <- mkBRAMCore2BE(actualNumWords, False);
            tagged Hex .hexfile: bram <- mkBRAMCore2BELoad(actualNumWords, False, hexfile, False);
            tagged Binary .binfile: bram <- mkBRAMCore2BELoad(actualNumWords, False, binfile, True);
        endcase
    end

    Vector#(2, BRAM_PORT_BE#(Bit#(wordAddrSz), Bit#(dataSz), writeEnSz)) bramVec = vec(bram.a, bram.b);
    Vector#(2, Ehr#(2, Maybe#(GenericAtomicBRAMPendingReq#(writeEnSz, atomicMemOpT)))) pendingReq <- replicateM(mkEhr(tagged Invalid));
    Vector#(2, FIFOG#(GenericAtomicMemResp#(dataSz))) pendingResp <- replicateM(mkBypassFIFOG);
    Vector#(2, Reg#(Bit#(wordAddrSz))) atomicOpWordAddr <- replicateM(mkReg(0));
    Vector#(2, Reg#(Bit#(dataSz))) atomicOpData <- replicateM(mkReg(0));

    Vector#(2, GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)) ifc;

    for (Integer i = 0 ; i < 2 ; i = i+1) begin
        rule performAtomicMemoryOp( pendingReq[i][0] matches tagged Valid .req
                                    &&& isAtomicMemOp(req.atomic_op));
            let writeData = atomicMemOpFunc(req.atomic_op, bramVec[i].read, atomicOpData[i], req.write_en);
            bramVec[i].put(req.write_en, atomicOpWordAddr[i], writeData);
            pendingReq[i][0] <= tagged Valid GenericAtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: nonAtomicMemOp, rmw_write: True };
            atomicOpData[i] <= bramVec[i].read;
        endrule

        rule getRespFromCore( pendingReq[i][0] matches tagged Valid .req
                              &&& !isAtomicMemOp(req.atomic_op));
            pendingResp[i].enq(GenericAtomicMemResp{ write: req.write_en != 0, data: (req.rmw_write ? atomicOpData[i] : bramVec[i].read) });
            pendingReq[i][0] <= tagged Invalid;
        endrule

        ifc[i] = (interface GenericAtomicMemServerPort;
                    interface InputPort request;
                        method Action enq(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req) if (!isValid(pendingReq[i][1]));
                            let atomic_op = (req.write_en == 0) ? nonAtomicMemOp : req.atomic_op;
                            if (isAtomicMemOp(atomic_op)) begin
                                bramVec[i].put(0, req.word_addr, req.data);
                                atomicOpWordAddr[i] <= req.word_addr;
                                atomicOpData[i] <= req.data;
                            end else begin
                                bramVec[i].put(req.write_en, req.word_addr, req.data);
                            end
                            pendingReq[i][1] <= tagged Valid GenericAtomicBRAMPendingReq{ write_en: req.write_en, atomic_op: atomic_op, rmw_write: False };
                        endmethod
                        method Bool canEnq;
                            return !isValid(pendingReq[i][1]);
                        endmethod
                    endinterface
                    interface OutputPort response = toOutputPort(pendingResp[i]);
                endinterface);
    end

    return ifc;
endmodule

/// This function ignores the address of the request
function ActionValue#(GenericAtomicMemResp#(dataSz)) performGenericAtomicMemOpOnReg(Reg#(Bit#(dataSz)) r, GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req)
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz));
    return (actionvalue
            GenericAtomicMemResp#(dataSz) resp = GenericAtomicMemResp{ write: (req.write_en != 0), data: 0 };
            if (req.write_en == 0) begin
                resp.data = r;
            end else if ((req.write_en == '1) && (!isAtomicMemOp(req.atomic_op))) begin
                r <= req.data;
            end else if (!isAtomicMemOp(req.atomic_op)) begin
                r <= emulateWriteEn(r, req.data, req.write_en);
            end else begin
                let write_data = atomicMemOpFunc(req.atomic_op, r, req.data, req.write_en);
                r <= emulateWriteEn(r, write_data, req.write_en);
                resp.data = r;
            end
            return resp;
        endactionvalue);
endfunction

function ActionValue#(GenericAtomicMemResp#(dataSz)) performGenericAtomicMemOpOnRegs(Vector#(numRegs, Reg#(Bit#(dataSz))) regs, GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req)
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Add#(b__, TLog#(numRegs), wordAddrSz));
    return (actionvalue
            Bit#(TLog#(numRegs)) index = truncate(req.word_addr);
            GenericAtomicMemResp#(dataSz) resp = GenericAtomicMemResp{ write: (req.write_en != 0), data: 0 };
            if (index <= fromInteger(valueOf(numRegs) - 1)) begin
                resp <- performGenericAtomicMemOpOnReg(regs[index], req);
            end
            return resp;
        endactionvalue);
endfunction
 
/// This function ignores the address of the request
function ActionValue#(GenericAtomicMemResp#(dataSz)) performGenericAtomicMemOpOnNarrowRegs(Vector#(regsPerWord, Reg#(Bit#(regSz))) regs, GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req)
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Mul#(bytesPerReg, byteSz, regSz),
                  Mul#(regsPerWord, bytesPerReg, writeEnSz));
    return (actionvalue
            GenericAtomicMemResp#(dataSz) resp = GenericAtomicMemResp{ write: (req.write_en != 0), data: 0 };
            Bit#(dataSz) reg_data = pack(readVReg(regs));
            Bit#(dataSz) write_data = 0;
            if (req.write_en == 0) begin
                resp.data = reg_data;
            end else if ((req.write_en == '1) && (!isAtomicMemOp(req.atomic_op))) begin
                write_data = req.data;
            end else if (!isAtomicMemOp(req.atomic_op)) begin
                write_data = emulateWriteEn(reg_data, req.data, req.write_en);
            end else begin
                write_data = atomicMemOpFunc(req.atomic_op, reg_data, req.data, req.write_en);
                write_data = emulateWriteEn(reg_data, write_data, req.write_en);
                resp.data = reg_data;
            end

            Vector#(regsPerWord, Bit#(bytesPerReg)) vector_write_en = unpack(req.write_en);
            Vector#(regsPerWord, Bit#(regSz)) write_data_vec = unpack(write_data);
            for (Integer i = 0 ; i < valueOf(regsPerWord) ; i = i+1) begin
                if (vector_write_en[i] != 0) begin
                    regs[i] <= write_data_vec[i];
                end
            end
            return resp;
        endactionvalue);
endfunction

function ActionValue#(GenericAtomicMemResp#(dataSz)) performGenericAtomicMemOpOnVectorOfNarrowRegs(Vector#(numWords, Vector#(regsPerWord, Reg#(Bit#(regSz)))) regs, GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req)
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Mul#(bytesPerReg, byteSz, regSz),
                  Mul#(regsPerWord, bytesPerReg, writeEnSz),
                  Add#(b__, TLog#(numWords), wordAddrSz));
    return (actionvalue
            Bit#(TLog#(numWords)) index = truncate(req.word_addr);
            GenericAtomicMemResp#(dataSz) resp = GenericAtomicMemResp{ write: (req.write_en != 0), data: 0 };
            if (index <= fromInteger(valueOf(numWords) - 1)) begin
                resp <- performGenericAtomicMemOpOnNarrowRegs(regs[index], req);
            end
            return resp;
        endactionvalue);
endfunction
 
function ActionValue#(GenericAtomicMemResp#(dataSz)) performGenericAtomicMemOpOnRegFile(RegFile#(Bit#(rfWordAddrSz), Bit#(dataSz)) rf, GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) req)
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Add#(b__, rfWordAddrSz, wordAddrSz));
    return (actionvalue
            Bit#(rfWordAddrSz) index = truncate(req.word_addr);
            GenericAtomicMemResp#(dataSz) resp = GenericAtomicMemResp{ write: (req.write_en != 0), data: 0 };
            if (req.write_en == 0) begin
                resp.data = rf.sub(index);
            end else if ((req.write_en == '1) && (!isAtomicMemOp(req.atomic_op))) begin
                rf.upd(index, req.data);
            end else if (!isAtomicMemOp(req.atomic_op)) begin
                let new_data = emulateWriteEn(rf.sub(index), req.data, req.write_en);
                rf.upd(index, new_data);
            end else begin
                let old_data = rf.sub(index);
                let write_data = atomicMemOpFunc(req.atomic_op, old_data, req.data, req.write_en);
                let new_data = emulateWriteEn(old_data, write_data, req.write_en);
                rf.upd(index, new_data);
                resp.data = old_data;
            end
            return resp;
        endactionvalue);
endfunction

module mkGenericAtomicMemFromRegs#(Vector#(numRegs, Reg#(Bit#(dataSz))) regs)(GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Add#(b__, TLog#(numRegs), wordAddrSz),
                  Bits#(atomicMemOpT, atomicMemOpSz));
    FIFOG#(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)) reqFIFO <- mkLFIFOG;
    FIFOG#(GenericAtomicMemResp#(dataSz)) respFIFO <- mkBypassFIFOG;
    rule performMemReq;
        let req = reqFIFO.first;
        reqFIFO.deq;
        let resp <- performGenericAtomicMemOpOnRegs(regs, req);
        respFIFO.enq(resp);
    endrule
    interface InputPort request = toInputPort(reqFIFO);
    interface OutputPort response = toOutputPort(respFIFO);
endmodule

module mkGenericAtomicMemFromNarrowRegs#(Vector#(numWords, Vector#(regsPerWord, Reg#(Bit#(regSz)))) regs)(GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Mul#(bytesPerReg, byteSz, regSz),
                  Mul#(regsPerWord, bytesPerReg, writeEnSz),
                  Add#(b__, TLog#(numWords), wordAddrSz),
                  Bits#(atomicMemOpT, atomicMemOpSz));
    FIFOG#(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)) reqFIFO <- mkLFIFOG;
    FIFOG#(GenericAtomicMemResp#(dataSz)) respFIFO <- mkBypassFIFOG;
    rule performMemReq;
        let req = reqFIFO.first;
        reqFIFO.deq;
        let resp <- performGenericAtomicMemOpOnVectorOfNarrowRegs(regs, req);
        respFIFO.enq(resp);
    endrule
    interface InputPort request = toInputPort(reqFIFO);
    interface OutputPort response = toOutputPort(respFIFO);
endmodule

module mkGenericAtomicMemFromRegFile#(RegFile#(Bit#(rfWordAddrSz), Bit#(dataSz)) rf)(GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz))
        provisos (HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                  Mul#(writeEnSz, byteSz, dataSz),
                  Add#(a__, 1, byteSz),
                  Add#(b__, rfWordAddrSz, wordAddrSz),
                  Bits#(atomicMemOpT, atomicMemOpSz));
    FIFOG#(GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)) reqFIFO <- mkLFIFOG;
    FIFOG#(GenericAtomicMemResp#(dataSz)) respFIFO <- mkBypassFIFOG;
    rule performMemReq;
        let req = reqFIFO.first;
        reqFIFO.deq;
        let resp <- performGenericAtomicMemOpOnRegFile(rf, req);
        respFIFO.enq(resp);
    endrule
    interface InputPort request = toInputPort(reqFIFO);
    interface OutputPort response = toOutputPort(respFIFO);
endmodule

endpackage
