
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
 * This package implements the following polymorphic memory constructors:
 *     - `mkPolymorphicBRAM`
 *     - `mkPolymorphicMemFromRegs(vector_of_regs)`
 *     - `mkPolymorphicMemFromRegFile(reg_file)`
 * The typeclasses that implement these use GenericAtomicMem modules as the
 * generic memory implementation and uses instances of the following
 * functions to convert requests and responses to exposes the desired memory
 * interface:
 *     - `toGenericAtomicMemReq(req)`
 *     - `toGenericAtomicMemPendingReq(req)`
 *     - `fromGenericAtomicMemResp(resp, pendingReq)`
 */
package PolymorphicMem;

import RegFile::*;
import Vector::*;

import FIFOG::*;
import GenericAtomicMem::*;
import Port::*;

// Typeclasses for converting to/from standard GenericAtomicMem types

typeclass ToGenericAtomicMemReq#(type reqT, numeric type writeEnSz, type atomicMemOpT, numeric type wordAddrSz, numeric type dataSz)
        dependencies (reqT determines (writeEnSz, atomicMemOpT, wordAddrSz, dataSz));
    function GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) toGenericAtomicMemReq(reqT req);
endtypeclass

typeclass ToGenericAtomicMemPendingReq#(type reqT, type pendingReqT)
        dependencies (reqT determines pendingReqT);
    function pendingReqT toGenericAtomicMemPendingReq(reqT req);
endtypeclass

typeclass FromGenericAtomicMemResp#(type respT, type pendingReqT, numeric type dataSz)
        dependencies (respT determines (pendingReqT, dataSz));
    function respT fromGenericAtomicMemResp(GenericAtomicMemResp#(dataSz) resp, pendingReqT pendingReq);
endtypeclass

////////////////////////////////////////////////////////////////////////////////

// `mkMaybeFIFOG` implements an optional FIFO in `mkPolymorphicMem` modules
// for pendinga request types. If the pending request type is void, then there
// is no actual FIFO constructed.

typeclass MkMaybeFIFOG#(type t);
    module mkMaybeFIFOG(FIFOG#(t));
endtypeclass

instance MkMaybeFIFOG#(void);
    module mkMaybeFIFOG(FIFOG#(void));
        method Action enq(void x);
            noAction;
        endmethod
        method void first;
            return ?;
        endmethod
        method Action deq;
            noAction;
        endmethod
        method Bool canEnq;
            return True;
        endmethod
        method Bool canDeq;
            return True;
        endmethod
        method Action clear;
            noAction;
        endmethod
        method Bool notFull;
            return ?;
        endmethod
        method Bool notEmpty;
            return ?;
        endmethod
    endmodule
endinstance

instance MkMaybeFIFOG#(t)
        provisos (Bits#(t, tSz));
    module mkMaybeFIFOG(FIFOG#(t));
        let _m <- mkFIFOG;
        return _m;
    endmodule
endinstance

////////////////////////////////////////////////////////////////////////////////

// Polymorphic memory types

typeclass MkPolymorphicBRAM#(type reqT, type respT)
        dependencies (reqT determines respT);
    module mkPolymorphicBRAMLoad#(Integer numWords, LoadFormat loadfile)(ServerPort#(reqT, respT));
    module mkPolymorphicBRAMLoad2Port#(Integer numWords, LoadFormat loadfile)(Vector#(2, ServerPort#(reqT, respT)));
endtypeclass

typeclass MkPolymorphicMemFromRegs#(type reqT, type respT, numeric type numRegs, numeric type dataSz)
        dependencies ((reqT, numRegs) determines (respT, dataSz));
    module mkPolymorphicMemFromRegs#(Vector#(numRegs, Reg#(Bit#(dataSz))) regs)(ServerPort#(reqT, respT));
endtypeclass

typeclass MkPolymorphicMemFromNarrowRegs#(type reqT, type respT, numeric type numWords, numeric type regsPerWord, numeric type regSz, numeric type dataSz)
        dependencies ((reqT, numWords, regsPerWord) determines (respT, regSz, dataSz));
    module mkPolymorphicMemFromNarrowRegs#(Vector#(numWords, Vector#(regsPerWord, Reg#(Bit#(regSz)))) regs)(ServerPort#(reqT, respT));
endtypeclass

typeclass MkPolymorphicMemFromRegFile#(type reqT, type respT, numeric type rfAddrSz, numeric type dataSz)
        dependencies ((reqT, rfAddrSz) determines (respT, dataSz));
    module mkPolymorphicMemFromRegFile#(RegFile#(Bit#(rfAddrSz), Bit#(dataSz)) rf)(ServerPort#(reqT, respT));
endtypeclass

module mkPolymorphicBRAM#(Integer numWords)(ServerPort#(reqT, respT))
        provisos (MkPolymorphicBRAM#(reqT, respT));
    let _m <- mkPolymorphicBRAMLoad(numWords, tagged None);
    return _m;
endmodule

module mkPolymorphicBRAM2Port#(Integer numWords)(Vector#(2, ServerPort#(reqT, respT)))
        provisos (MkPolymorphicBRAM#(reqT, respT));
    let _m <- mkPolymorphicBRAMLoad2Port(numWords, tagged None);
    return _m;
endmodule

instance MkPolymorphicBRAM#(reqT, respT)
        provisos(ToGenericAtomicMemReq#(reqT, writeEnSz, atomicMemOpT, wordAddrSz, dataSz),
                 ToGenericAtomicMemPendingReq#(reqT, pendingReqT),
                 FromGenericAtomicMemResp#(respT, pendingReqT, dataSz),
                 HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                 MkMaybeFIFOG#(pendingReqT),
                 Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz),
                 Bits#(atomicMemOpT, a__),
                 Bits#(pendingReqT, b__));
    module mkPolymorphicBRAMLoad#(Integer numWords, LoadFormat loadFile)(ServerPort#(reqT, respT));
        GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) mem <- mkGenericAtomicBRAMLoad(numWords, loadFile);
        FIFOG#(pendingReqT) pendingReq <- mkMaybeFIFOG;
        interface InputPort request;
            method Action enq(reqT req);
                mem.request.enq(toGenericAtomicMemReq(req));
                pendingReq.enq(toGenericAtomicMemPendingReq(req));
            endmethod
            method Bool canEnq;
                return mem.request.canEnq && pendingReq.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method respT first;
                return fromGenericAtomicMemResp(mem.response.first, pendingReq.first);
            endmethod
            method Action deq;
                mem.response.deq;
                pendingReq.deq;
            endmethod
            method Bool canDeq;
                return mem.response.canDeq && pendingReq.canDeq;
            endmethod
        endinterface
    endmodule
    module mkPolymorphicBRAMLoad2Port#(Integer numWords, LoadFormat loadFile)(Vector#(2, ServerPort#(reqT, respT)));
        Vector#(2, GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz)) mem <- mkGenericAtomicBRAMLoad2Port(numWords, loadFile);
        Vector#(2, FIFOG#(pendingReqT)) pendingReq <- replicateM(mkMaybeFIFOG);

        function ServerPort#(reqT, respT) genPortIfc(Integer i);
            return (interface ServerPort;
                        interface InputPort request;
                            method Action enq(reqT req);
                                mem[i].request.enq(toGenericAtomicMemReq(req));
                                pendingReq[i].enq(toGenericAtomicMemPendingReq(req));
                            endmethod
                            method Bool canEnq;
                                return mem[i].request.canEnq && pendingReq[i].canEnq;
                            endmethod
                        endinterface
                        interface OutputPort response;
                            method respT first;
                                return fromGenericAtomicMemResp(mem[i].response.first, pendingReq[i].first);
                            endmethod
                            method Action deq;
                                mem[i].response.deq;
                                pendingReq[i].deq;
                            endmethod
                            method Bool canDeq;
                                return mem[i].response.canDeq && pendingReq[i].canDeq;
                            endmethod
                        endinterface
                    endinterface);
        endfunction

        Vector#(2, ServerPort#(reqT, respT)) ifc = genWith(genPortIfc);

        return ifc;
    endmodule
endinstance

instance MkPolymorphicMemFromRegs#(reqT, respT, numRegs, dataSz)
        provisos(ToGenericAtomicMemReq#(reqT, writeEnSz, atomicMemOpT, wordAddrSz, dataSz),
                 ToGenericAtomicMemPendingReq#(reqT, pendingReqT),
                 FromGenericAtomicMemResp#(respT, pendingReqT, dataSz),
                 HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                 MkMaybeFIFOG#(pendingReqT),
                 Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz),
                 Bits#(atomicMemOpT, a__),
                 Bits#(pendingReqT, b__),
                 Add#(c__, TLog#(numRegs), wordAddrSz),
                 Add#(d__, 1, TDiv#(dataSz, writeEnSz)));

    module mkPolymorphicMemFromRegs#(Vector#(numRegs, Reg#(Bit#(dataSz))) regs)(ServerPort#(reqT, respT));
        GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) gam <- mkGenericAtomicMemFromRegs(regs);
        FIFOG#(pendingReqT) pendingReq <- mkMaybeFIFOG;
        interface InputPort request;
            method Action enq(reqT req);
                gam.request.enq(toGenericAtomicMemReq(req));
                pendingReq.enq(toGenericAtomicMemPendingReq(req));
            endmethod
            method Bool canEnq;
                return gam.request.canEnq && pendingReq.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method respT first;
                return fromGenericAtomicMemResp(gam.response.first, pendingReq.first);
            endmethod
            method Action deq;
                gam.response.deq;
                pendingReq.deq;
            endmethod
            method Bool canDeq;
                return gam.response.canDeq && pendingReq.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

instance MkPolymorphicMemFromNarrowRegs#(reqT, respT, numWords, regsPerWord, regSz, dataSz)
        provisos(ToGenericAtomicMemReq#(reqT, writeEnSz, atomicMemOpT, wordAddrSz, dataSz),
                 ToGenericAtomicMemPendingReq#(reqT, pendingReqT),
                 FromGenericAtomicMemResp#(respT, pendingReqT, dataSz),
                 HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                 MkMaybeFIFOG#(pendingReqT),
                 Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz),
                 Bits#(atomicMemOpT, a__),
                 Bits#(pendingReqT, b__),
                 Add#(c__, TLog#(numWords), wordAddrSz),
                 Add#(d__, 1, TDiv#(dataSz, writeEnSz)),
                 Mul#(regsPerWord, bytesPerReg, writeEnSz),
                 Mul#(bytesPerReg, TDiv#(dataSz, writeEnSz), regSz)
             );
    module mkPolymorphicMemFromNarrowRegs#(Vector#(numWords, Vector#(regsPerWord, Reg#(Bit#(regSz)))) regs)(ServerPort#(reqT, respT));
        GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) gam <- mkGenericAtomicMemFromNarrowRegs(regs);
        FIFOG#(pendingReqT) pendingReq <- mkMaybeFIFOG;
        interface InputPort request;
            method Action enq(reqT req);
                gam.request.enq(toGenericAtomicMemReq(req));
                pendingReq.enq(toGenericAtomicMemPendingReq(req));
            endmethod
            method Bool canEnq;
                return gam.request.canEnq && pendingReq.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method respT first;
                return fromGenericAtomicMemResp(gam.response.first, pendingReq.first);
            endmethod
            method Action deq;
                gam.response.deq;
                pendingReq.deq;
            endmethod
            method Bool canDeq;
                return gam.response.canDeq && pendingReq.canDeq;
            endmethod
        endinterface
    endmodule
endinstance


instance MkPolymorphicMemFromRegFile#(reqT, respT, rfAddrSz, dataSz)
        provisos(ToGenericAtomicMemReq#(reqT, writeEnSz, atomicMemOpT, wordAddrSz, dataSz),
                 ToGenericAtomicMemPendingReq#(reqT, pendingReqT),
                 FromGenericAtomicMemResp#(respT, pendingReqT, dataSz),
                 HasAtomicMemOpFunc#(atomicMemOpT, dataSz, writeEnSz),
                 MkMaybeFIFOG#(pendingReqT),
                 Mul#(TDiv#(dataSz, writeEnSz), writeEnSz, dataSz),
                 Bits#(atomicMemOpT, a__),
                 Bits#(pendingReqT, b__),
                 Add#(c__, rfAddrSz, wordAddrSz),
                 Add#(d__, 1, TDiv#(dataSz, writeEnSz)));

    module mkPolymorphicMemFromRegFile#(RegFile#(Bit#(rfAddrSz), Bit#(dataSz)) rf)(ServerPort#(reqT, respT));
        GenericAtomicMemServerPort#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) gam <- mkGenericAtomicMemFromRegFile(rf);
        FIFOG#(pendingReqT) pendingReq <- mkMaybeFIFOG;
        interface InputPort request;
            method Action enq(reqT req);
                gam.request.enq(toGenericAtomicMemReq(req));
                pendingReq.enq(toGenericAtomicMemPendingReq(req));
            endmethod
            method Bool canEnq;
                return gam.request.canEnq && pendingReq.canEnq;
            endmethod
        endinterface
        interface OutputPort response;
            method respT first;
                return fromGenericAtomicMemResp(gam.response.first, pendingReq.first);
            endmethod
            method Action deq;
                gam.response.deq;
                pendingReq.deq;
            endmethod
            method Bool canDeq;
                return gam.response.canDeq && pendingReq.canDeq;
            endmethod
        endinterface
    endmodule
endinstance

endpackage
