# PolymorphicMem


This package implements the following polymorphic memory constructors:
    - `mkPolymorphicBRAM`
    - `mkPolymorphicMemFromRegs(vector_of_regs)`
    - `mkPolymorphicMemFromRegFile(reg_file)`
The typeclasses that implement these use GenericAtomicMem modules as the
generic memory implementation and uses instances of the following
functions to convert requests and responses to exposes the desired memory
interface:
    - `toGenericAtomicMemReq(req)`
    - `toGenericAtomicMemPendingReq(req)`
    - `fromGenericAtomicMemResp(resp, pendingReq)`


### [ToGenericAtomicMemReq](../../src/bsv/PolymorphicMem.bsv#L48)
```bluespec
typeclass ToGenericAtomicMemReq#(type reqT, numeric type writeEnSz, type atomicMemOpT, numeric type wordAddrSz, numeric type dataSz)
        dependencies (reqT determines (writeEnSz, atomicMemOpT, wordAddrSz, dataSz));
    function GenericAtomicMemReq#(writeEnSz, atomicMemOpT, wordAddrSz, dataSz) toGenericAtomicMemReq(reqT req);
endtypeclass


```

### [ToGenericAtomicMemPendingReq](../../src/bsv/PolymorphicMem.bsv#L53)
```bluespec
typeclass ToGenericAtomicMemPendingReq#(type reqT, type pendingReqT)
        dependencies (reqT determines pendingReqT);
    function pendingReqT toGenericAtomicMemPendingReq(reqT req);
endtypeclass


```

### [FromGenericAtomicMemResp](../../src/bsv/PolymorphicMem.bsv#L58)
```bluespec
typeclass FromGenericAtomicMemResp#(type respT, type pendingReqT, numeric type dataSz)
        dependencies (respT determines (pendingReqT, dataSz));
    function respT fromGenericAtomicMemResp(GenericAtomicMemResp#(dataSz) resp, pendingReqT pendingReq);
endtypeclass


```

### [MkMaybeFIFOG](../../src/bsv/PolymorphicMem.bsv#L69)
```bluespec
typeclass MkMaybeFIFOG#(type t);
    module mkMaybeFIFOG(FIFOG#(t));
endtypeclass


```

### [MkMaybeFIFOG](../../src/bsv/PolymorphicMem.bsv#L73)
```bluespec
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


```

### [MkMaybeFIFOG](../../src/bsv/PolymorphicMem.bsv#L102)
```bluespec
instance MkMaybeFIFOG#(t)
        provisos (Bits#(t, tSz));
    module mkMaybeFIFOG(FIFOG#(t));
        let _m <- mkFIFOG;
        return _m;
    endmodule
endinstance


```

### [MkPolymorphicBRAM](../../src/bsv/PolymorphicMem.bsv#L114)
```bluespec
typeclass MkPolymorphicBRAM#(type reqT, type respT)
        dependencies (reqT determines respT);
    module mkPolymorphicBRAMLoad#(Integer numWords, LoadFormat loadfile)(ServerPort#(reqT, respT));
endtypeclass


```

### [MkPolymorphicMemFromRegs](../../src/bsv/PolymorphicMem.bsv#L119)
```bluespec
typeclass MkPolymorphicMemFromRegs#(type reqT, type respT, numeric type numRegs, numeric type dataSz)
        dependencies ((reqT, numRegs) determines (respT, dataSz));
    module mkPolymorphicMemFromRegs#(Vector#(numRegs, Reg#(Bit#(dataSz))) regs)(ServerPort#(reqT, respT));
endtypeclass


```

### [MkPolymorphicMemFromRegFile](../../src/bsv/PolymorphicMem.bsv#L124)
```bluespec
typeclass MkPolymorphicMemFromRegFile#(type reqT, type respT, numeric type rfAddrSz, numeric type dataSz)
        dependencies ((reqT, rfAddrSz) determines (respT, dataSz));
    module mkPolymorphicMemFromRegFile#(RegFile#(Bit#(rfAddrSz), Bit#(dataSz)) rf)(ServerPort#(reqT, respT));
endtypeclass


```

### [mkPolymorphicBRAM](../../src/bsv/PolymorphicMem.bsv#L129)
```bluespec
module mkPolymorphicBRAM#(Integer numWords)(ServerPort#(reqT, respT))
        provisos (MkPolymorphicBRAM#(reqT, respT));
    let _m <- mkPolymorphicBRAMLoad(numWords, tagged None);
    return _m;
endmodule


```

### [MkPolymorphicBRAM](../../src/bsv/PolymorphicMem.bsv#L135)
```bluespec
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
endinstance


```

### [MkPolymorphicMemFromRegs](../../src/bsv/PolymorphicMem.bsv#L171)
```bluespec
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


```

### [MkPolymorphicMemFromRegFile](../../src/bsv/PolymorphicMem.bsv#L210)
```bluespec
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


```

