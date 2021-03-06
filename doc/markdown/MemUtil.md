# MemUtil


This package contains interfaces, typeclasses, functions, and modules that
are essential for dealing with general purpose memory and memory mapped
interfaces.

This package adopts two main design choices that simplifies working with
general purpose memory:

1. All addresses are byte addresses.
2. Data lines are always word aligned.

As a result of these two design choices, we have adopted some conventions:

- Data widths are always a power of 2 bytes (`logNumBytes`).
- The bottom `logNumBytes` bits of each address is ignored.

### Future Improvements

- Write a custom `Bits` instance so pack and unpack can ignore the bottom
  `logNumBytes` of a memory request's address.


### [['ReadOnlyMemReq', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L62)
```bluespec
typedef struct {
    Bit#(addrSz) addr;
} ReadOnlyMemReq#(numeric type addrSz, numeric type logNumBytes) deriving (Bits, Eq, FShow);
```

### [['ReadOnlyMemResp', ['numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L66)
```bluespec
typedef struct {
    Bit#(TMul#(8,TExp#(logNumBytes))) data;
} ReadOnlyMemResp#(numeric type logNumBytes) deriving (Bits, Eq, FShow);
```

### [['ByteEnMemResp', ['numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L91)
```bluespec
typedef CoarseMemResp#(logNumBytes) ByteEnMemResp#(numeric type logNumBytes);
```

### [['AtomicMemOp']](../../src/bsv/MemUtil.bsv#L96)
```bluespec
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
```

### [['AtomicMemResp', ['numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L116)
```bluespec
typedef CoarseMemResp#(logNumBytes) AtomicMemResp#(numeric type logNumBytes);
```

### [['ReadOnlyMemServerPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L122)
```bluespec
typedef ServerPort#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes)) ReadOnlyMemServerPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['ReadOnlyMemClientPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L123)
```bluespec
typedef ClientPort#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes)) ReadOnlyMemClientPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['CoarseMemServerPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L125)
```bluespec
typedef ServerPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemServerPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['CoarseMemClientPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L126)
```bluespec
typedef ClientPort#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes)) CoarseMemClientPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['ByteEnMemServerPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L128)
```bluespec
typedef ServerPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemServerPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['ByteEnMemClientPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L129)
```bluespec
typedef ClientPort#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes)) ByteEnMemClientPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['AtomicMemServerPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L131)
```bluespec
typedef ServerPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemServerPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['AtomicMemClientPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L132)
```bluespec
typedef ClientPort#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes)) AtomicMemClientPort#(numeric type addrSz, numeric type logNumBytes);
```

### [['ReadOnlyMem32Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L138)
```bluespec
typedef ReadOnlyMemReq#(addrSz, 2)        ReadOnlyMem32Req#(numeric type addrSz);
```

### [['ReadOnlyMem32Resp']](../../src/bsv/MemUtil.bsv#L139)
```bluespec
typedef ReadOnlyMemResp#(2)               ReadOnlyMem32Resp;
```

### [['ReadOnlyMem32ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L140)
```bluespec
typedef ReadOnlyMemServerPort#(addrSz, 2) ReadOnlyMem32ServerPort#(numeric type addrSz);
```

### [['ReadOnlyMem32ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L141)
```bluespec
typedef ReadOnlyMemClientPort#(addrSz, 2) ReadOnlyMem32ClientPort#(numeric type addrSz);
```

### [['CoarseMem32Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L143)
```bluespec
typedef CoarseMemReq#(addrSz, 2)        CoarseMem32Req#(numeric type addrSz);
```

### [['CoarseMem32Resp']](../../src/bsv/MemUtil.bsv#L144)
```bluespec
typedef CoarseMemResp#(2)               CoarseMem32Resp;
```

### [['CoarseMem32ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L145)
```bluespec
typedef CoarseMemServerPort#(addrSz, 2) CoarseMem32ServerPort#(numeric type addrSz);
```

### [['CoarseMem32ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L146)
```bluespec
typedef CoarseMemClientPort#(addrSz, 2) CoarseMem32ClientPort#(numeric type addrSz);
```

### [['ByteEnMem32Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L148)
```bluespec
typedef ByteEnMemReq#(addrSz, 2)        ByteEnMem32Req#(numeric type addrSz);
```

### [['ByteEnMem32Resp']](../../src/bsv/MemUtil.bsv#L149)
```bluespec
typedef ByteEnMemResp#(2)               ByteEnMem32Resp;
```

### [['ByteEnMem32ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L150)
```bluespec
typedef ByteEnMemServerPort#(addrSz, 2) ByteEnMem32ServerPort#(numeric type addrSz);
```

### [['ByteEnMem32ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L151)
```bluespec
typedef ByteEnMemClientPort#(addrSz, 2) ByteEnMem32ClientPort#(numeric type addrSz);
```

### [['AtomicMem32Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L153)
```bluespec
typedef AtomicMemReq#(addrSz, 2)        AtomicMem32Req#(numeric type addrSz);
```

### [['AtomicMem32Resp']](../../src/bsv/MemUtil.bsv#L154)
```bluespec
typedef AtomicMemResp#(2)               AtomicMem32Resp;
```

### [['AtomicMem32ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L155)
```bluespec
typedef AtomicMemServerPort#(addrSz, 2) AtomicMem32ServerPort#(numeric type addrSz);
```

### [['AtomicMem32ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L156)
```bluespec
typedef AtomicMemClientPort#(addrSz, 2) AtomicMem32ClientPort#(numeric type addrSz);
```

### [['ReadOnlyMem64Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L160)
```bluespec
typedef ReadOnlyMemReq#(addrSz, 3)        ReadOnlyMem64Req#(numeric type addrSz);
```

### [['ReadOnlyMem64Resp']](../../src/bsv/MemUtil.bsv#L161)
```bluespec
typedef ReadOnlyMemResp#(3)               ReadOnlyMem64Resp;
```

### [['ReadOnlyMem64ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L162)
```bluespec
typedef ReadOnlyMemServerPort#(addrSz, 3) ReadOnlyMem64ServerPort#(numeric type addrSz);
```

### [['ReadOnlyMem64ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L163)
```bluespec
typedef ReadOnlyMemClientPort#(addrSz, 3) ReadOnlyMem64ClientPort#(numeric type addrSz);
```

### [['CoarseMem64Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L165)
```bluespec
typedef CoarseMemReq#(addrSz, 3)        CoarseMem64Req#(numeric type addrSz);
```

### [['CoarseMem64Resp']](../../src/bsv/MemUtil.bsv#L166)
```bluespec
typedef CoarseMemResp#(3)               CoarseMem64Resp;
```

### [['CoarseMem64ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L167)
```bluespec
typedef CoarseMemServerPort#(addrSz, 3) CoarseMem64ServerPort#(numeric type addrSz);
```

### [['CoarseMem64ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L168)
```bluespec
typedef CoarseMemClientPort#(addrSz, 3) CoarseMem64ClientPort#(numeric type addrSz);
```

### [['ByteEnMem64Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L170)
```bluespec
typedef ByteEnMemReq#(addrSz, 3)        ByteEnMem64Req#(numeric type addrSz);
```

### [['ByteEnMem64Resp']](../../src/bsv/MemUtil.bsv#L171)
```bluespec
typedef ByteEnMemResp#(3)               ByteEnMem64Resp;
```

### [['ByteEnMem64ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L172)
```bluespec
typedef ByteEnMemServerPort#(addrSz, 3) ByteEnMem64ServerPort#(numeric type addrSz);
```

### [['ByteEnMem64ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L173)
```bluespec
typedef ByteEnMemClientPort#(addrSz, 3) ByteEnMem64ClientPort#(numeric type addrSz);
```

### [['AtomicMem64Req', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L175)
```bluespec
typedef AtomicMemReq#(addrSz, 3)        AtomicMem64Req#(numeric type addrSz);
```

### [['AtomicMem64Resp']](../../src/bsv/MemUtil.bsv#L176)
```bluespec
typedef AtomicMemResp#(3)               AtomicMem64Resp;
```

### [['AtomicMem64ServerPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L177)
```bluespec
typedef AtomicMemServerPort#(addrSz, 3) AtomicMem64ServerPort#(numeric type addrSz);
```

### [['AtomicMem64ClientPort', ['numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L178)
```bluespec
typedef AtomicMemClientPort#(addrSz, 3) AtomicMem64ClientPort#(numeric type addrSz);
```

### [['MemType']](../../src/bsv/MemUtil.bsv#L184)
```bluespec
typedef enum {
    ReadOnly,
    Coarse,
    ByteEn,
    Atomic
} MemType deriving (Bits, Eq, FShow, Bounded);
```

### [['TaggedMemServerPort', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L191)
```bluespec
typedef union tagged {
    ReadOnlyMemServerPort#(addrSz, logNumBytes) ReadOnly;
    CoarseMemServerPort#(addrSz, logNumBytes)   Coarse;
    ByteEnMemServerPort#(addrSz, logNumBytes)   ByteEn;
    AtomicMemServerPort#(addrSz, logNumBytes)   Atomic;
} TaggedMemServerPort#(numeric type addrSz, numeric type logNumBytes);
```

### [IsMemReq](../../src/bsv/MemUtil.bsv#L198)
```bluespec
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


```

### [IsMemReq](../../src/bsv/MemUtil.bsv#L209)
```bluespec
instance IsMemReq#(ReadOnlyMemReq#(addrSz, logNumBytes), ReadOnlyMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(ReadOnlyMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(ReadOnlyMemReq#(addrSz, logNumBytes) req) = 0;
    function Bool isWrite(ReadOnlyMemReq#(addrSz, logNumBytes) req) = False;
    function Bit#(TExp#(logNumBytes)) getWriteEn(ReadOnlyMemReq#(addrSz, logNumBytes) req) = 0;
    function AtomicMemOp getAtomicOp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = False;
    function ReadOnlyMemResp#(logNumBytes) getDefaultResp(ReadOnlyMemReq#(addrSz, logNumBytes) req) = ReadOnlyMemResp{ data: 0 };
endinstance


```

### [IsMemReq](../../src/bsv/MemUtil.bsv#L219)
```bluespec
instance IsMemReq#(CoarseMemReq#(addrSz, logNumBytes), CoarseMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(CoarseMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(CoarseMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(CoarseMemReq#(addrSz, logNumBytes) req) = req.write;
    function Bit#(TExp#(logNumBytes)) getWriteEn(CoarseMemReq#(addrSz, logNumBytes) req) = req.write ? '1 : 0;
    function AtomicMemOp getAtomicOp(CoarseMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(CoarseMemReq#(addrSz, logNumBytes) req) = False;
    function CoarseMemResp#(logNumBytes) getDefaultResp(CoarseMemReq#(addrSz, logNumBytes) req) = CoarseMemResp{ write: req.write, data: 0 };
endinstance


```

### [IsMemReq](../../src/bsv/MemUtil.bsv#L229)
```bluespec
instance IsMemReq#(ByteEnMemReq#(addrSz, logNumBytes), ByteEnMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(ByteEnMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(ByteEnMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(ByteEnMemReq#(addrSz, logNumBytes) req) = req.write_en != 0;
    function Bit#(TExp#(logNumBytes)) getWriteEn(ByteEnMemReq#(addrSz, logNumBytes) req) = req.write_en;
    function AtomicMemOp getAtomicOp(ByteEnMemReq#(addrSz, logNumBytes) req) = None;
    function Bool isAtomicOp(ByteEnMemReq#(addrSz, logNumBytes) req) = False;
    function ByteEnMemResp#(logNumBytes) getDefaultResp(ByteEnMemReq#(addrSz, logNumBytes) req) = ByteEnMemResp{ write: req.write_en != 0, data: 0 };
endinstance


```

### [IsMemReq](../../src/bsv/MemUtil.bsv#L239)
```bluespec
instance IsMemReq#(AtomicMemReq#(addrSz, logNumBytes), AtomicMemResp#(logNumBytes), addrSz, logNumBytes);
    function Bit#(addrSz) getAddr(AtomicMemReq#(addrSz, logNumBytes) req) = req.addr;
    function Bit#(TMul#(8,TExp#(logNumBytes))) getData(AtomicMemReq#(addrSz, logNumBytes) req) = req.data;
    function Bool isWrite(AtomicMemReq#(addrSz, logNumBytes) req) = req.write_en != 0;
    function Bit#(TExp#(logNumBytes)) getWriteEn(AtomicMemReq#(addrSz, logNumBytes) req) = req.write_en;
    function AtomicMemOp getAtomicOp(AtomicMemReq#(addrSz, logNumBytes) req) = req.atomic_op;
    function Bool isAtomicOp(AtomicMemReq#(addrSz, logNumBytes) req) = req.atomic_op != None;
    function AtomicMemResp#(logNumBytes) getDefaultResp(AtomicMemReq#(addrSz, logNumBytes) req) = AtomicMemResp{ write: req.write_en != 0, data: 0 };
endinstance


```

### [toReadOnlyMemReq](../../src/bsv/MemUtil.bsv#L249)
```bluespec
function ReadOnlyMemReq#(addrSz, logNumBytes) toReadOnlyMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return ReadOnlyMemReq { addr: getAddr(req) };
endfunction

```

### [isReadOnlyMemReq](../../src/bsv/MemUtil.bsv#L252)
```bluespec
function Bool isReadOnlyMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req);
endfunction


```

### [toCoarseMemReq](../../src/bsv/MemUtil.bsv#L256)
```bluespec
function CoarseMemReq#(addrSz, logNumBytes) toCoarseMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return CoarseMemReq { write: isWrite(req), addr: getAddr(req), data: getData(req) };
endfunction

```

### [isCoarseMemReq](../../src/bsv/MemUtil.bsv#L259)
```bluespec
function Bool isCoarseMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req) || ((getWriteEn(req) == '1) && (getAtomicOp(req) == None));
endfunction


```

### [toByteEnMemReq](../../src/bsv/MemUtil.bsv#L263)
```bluespec
function ByteEnMemReq#(addrSz, logNumBytes) toByteEnMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return ByteEnMemReq { write_en: getWriteEn(req), addr: getAddr(req), data: getData(req) };
endfunction

```

### [isByteEnMemReq](../../src/bsv/MemUtil.bsv#L266)
```bluespec
function Bool isByteEnMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return !isWrite(req) || (getAtomicOp(req) == None);
endfunction


```

### [toAtomicMemReq](../../src/bsv/MemUtil.bsv#L270)
```bluespec
function AtomicMemReq#(addrSz, logNumBytes) toAtomicMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return AtomicMemReq { write_en: getWriteEn(req), atomic_op: getAtomicOp(req), addr: getAddr(req), data: getData(req) };
endfunction

```

### [isAtomicMemReq](../../src/bsv/MemUtil.bsv#L273)
```bluespec
function Bool isAtomicMemReq(memReqT req) provisos (IsMemReq#(memReqT, memRespT, addrSz, logNumBytes));
    return True;
endfunction


```

### [IsMemResp](../../src/bsv/MemUtil.bsv#L279)
```bluespec
typeclass IsMemResp#(type memRespT, numeric type logNumBytes) dependencies (memRespT determines logNumBytes);
    function memRespT fromReadOnlyMemResp(ReadOnlyMemResp#(logNumBytes) resp);
    function memRespT fromCoarseMemResp(CoarseMemResp#(logNumBytes) resp);
    function memRespT fromByteEnMemResp(CoarseMemResp#(logNumBytes) resp) = fromCoarseMemResp(resp);
    function memRespT fromAtomicMemResp(CoarseMemResp#(logNumBytes) resp) = fromCoarseMemResp(resp);
    function ReadOnlyMemResp#(logNumBytes) toReadOnlyMemResp(memRespT resp);
    function CoarseMemResp#(logNumBytes) toCoarseMemResp(memRespT resp);
    function ByteEnMemResp#(logNumBytes) toByteEnMemResp(memRespT resp) = toCoarseMemResp(resp);
    function AtomicMemResp#(logNumBytes) toAtomicMemResp(memRespT resp) = toCoarseMemResp(resp);
endtypeclass


```

### [IsMemResp](../../src/bsv/MemUtil.bsv#L290)
```bluespec
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


```

### [IsMemResp](../../src/bsv/MemUtil.bsv#L305)
```bluespec
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


```

### [atomicMemOpAlu](../../src/bsv/MemUtil.bsv#L330)


This function performs the specified atomic memory operation on the
provided memory data and operand data. The byte enable is only used for
min and max operations. The output of this function is only valid for the
enabled bytes.

```bluespec
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


```

### [atomicMemOpAlu32](../../src/bsv/MemUtil.bsv#L402)
```bluespec
function Bit#(32) atomicMemOpAlu32(AtomicMemOp op, Bit#(32) memData, Bit#(32) operandData, Bit#(4) byteEn);
    return atomicMemOpAlu(op, memData, operandData, byteEn);
endfunction

```

### [atomicMemOpAlu64](../../src/bsv/MemUtil.bsv#L406)
```bluespec
function Bit#(64) atomicMemOpAlu64(AtomicMemOp op, Bit#(64) memData, Bit#(64) operandData, Bit#(8) byteEn);
    return atomicMemOpAlu(op, memData, operandData, byteEn);
endfunction


```

### [MkAtomicMemEmulationBridge](../../src/bsv/MemUtil.bsv#L414)

This bridge attempts to emulate atomic memory operations across a memory
interface that does not support atomic memory operations.
```bluespec
typeclass MkAtomicMemEmulationBridge#(type memIfc, numeric type addrSz, numeric type logNumBytes)
        dependencies (memIfc determines (addrSz, logNumBytes));
    module mkAtomicMemEmulationBridge#(memIfc mem)(AtomicMemServerPort#(addrSz, logNumBytes));
endtypeclass


```

### [MkAtomicMemEmulationBridge](../../src/bsv/MemUtil.bsv#L426)
```bluespec
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


```

### [mkNarrowAtomicMemBridge](../../src/bsv/MemUtil.bsv#L504)
```bluespec
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


```

### [CoarseBRAM](../../src/bsv/MemUtil.bsv#L552)
```bluespec
interface CoarseBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface CoarseMemServerPort#(addrSz, logNumBytes) portA;
endinterface


```

### [mkPipelineCoarseBRAM](../../src/bsv/MemUtil.bsv#L557)
```bluespec
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


```

### [mkCoarseBRAM](../../src/bsv/MemUtil.bsv#L590)
```bluespec
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


```

### [ByteEnBRAM](../../src/bsv/MemUtil.bsv#L633)
```bluespec
interface ByteEnBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface ByteEnMemServerPort#(addrSz, logNumBytes) portA;
endinterface


```

### [mkByteEnBRAM](../../src/bsv/MemUtil.bsv#L638)
```bluespec
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


```

### [AtomicBRAM](../../src/bsv/MemUtil.bsv#L682)
```bluespec
interface AtomicBRAM#(numeric type addrSz, numeric type logNumBytes, numeric type numBytes);
    interface AtomicMemServerPort#(addrSz, logNumBytes) portA;
endinterface


```

### [mkAtomicBRAM](../../src/bsv/MemUtil.bsv#L702)


This module creates an AtomicMemServerPort from a BRAMCore.

This module supports narrow atomic memory operations through the use of the
`write_en` field in the `AtomicMemReq` struct. In normal operation, the
`write_en` field should only have contiguous bits set. If non-contiguous
bytes are enabled, they will behave as separate atomic memory operations
except for the minmax atomic memory operations. Those will behave as if
all the enabled bytes are concatenated.

```bluespec
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


```

### [performMemReqOnRegs](../../src/bsv/MemUtil.bsv#L772)
```bluespec
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


```

### [mkMemServerPortFromRegs](../../src/bsv/MemUtil.bsv#L815)

This module can create a `ServerPort` of various memory types given a
vector of registers.
```bluespec
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


```

### [performMemReqOnRegFile](../../src/bsv/MemUtil.bsv#L836)
```bluespec
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


```

### [mkMemServerPortFromRegFile](../../src/bsv/MemUtil.bsv#L878)

This module can create a `ServerPort` of various memory types given a
`RegFile`.
```bluespec
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


```

### [['MemBusItem', ['type', 'memReqT', 'type', 'memRespT', 'numeric', 'type', 'addrSz']]](../../src/bsv/MemUtil.bsv#L903)
```bluespec
typedef struct {
    Bit#(addrSz) addr_mask;
    Bit#(addrSz) addr_match;
    ServerPort#(memReqT, memRespT) ifc;
} MemBusItem#(type memReqT, type memRespT, numeric type addrSz);
```

### [busItemFromAddrRange](../../src/bsv/MemUtil.bsv#L915)


This function produces a `MemBusItem` from an address range.

This function will return an error at compile time if the address range
cannot be exptessed with an address mask and a match value.

```bluespec
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


```

### [mkMemBus](../../src/bsv/MemUtil.bsv#L950)


This module makes a memory bus from a provided address map.

This module takes in an address map as a vector of `MemBusItem`. Each item
consists of a `ServerPort` interface and an address mask and match. This
module produces a vector of `ServerPort` memory interfaces for clients to
attach to to.

The internal implementation consists of many bypass FIFOs for decoupling
to avoid adding unnecessary scheduling constraints between the independent
memory servers. This implementation also consists of many internal rules to
easily support concurrent access between independent clients and servers.
There are better ways to get this concurrency, but they require more
implementation effort and are harder to verify.

```bluespec
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


```

### [['MixedMemBusItem', ['numeric', 'type', 'addrSz', 'numeric', 'type', 'logNumBytes']]](../../src/bsv/MemUtil.bsv#L1054)
```bluespec
typedef struct {
    Bit#(addrSz) addr_mask;
    Bit#(addrSz) addr_match;
    TaggedMemServerPort#(addrSz, logNumBytes) ifc;
} MixedMemBusItem#(numeric type addrSz, numeric type logNumBytes);
```

### [mixedMemBusItemFromAddrRange](../../src/bsv/MemUtil.bsv#L1066)


This function produces a `MixedMemBusItem` from an address range.

This function will return an error at compile time if the address range
cannot be exptessed with an address mask and a match value.

```bluespec
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


```

### [MixedAtomicMemBus](../../src/bsv/MemUtil.bsv#L1086)
```bluespec
interface MixedAtomicMemBus#(numeric type nClients, numeric type addrSz, numeric type logNumBytes);
    interface Vector#(nClients, AtomicMemServerPort#(addrSz, logNumBytes)) clients;
    method Maybe#(MemType) getMemType(Bit#(addrSz) addr);
endinterface


```

### [mkMixedAtomicMemBus](../../src/bsv/MemUtil.bsv#L1106)


This module makes a memory bus from a provided address map.

This module takes in an address map as a vector of `MemBusItem`. Each item
consists of a `ServerPort` interface and an address mask and match. This
module produces a vector of `ServerPort` memory interfaces for clients to
attach to to.

The internal implementation consists of many bypass FIFOs for decoupling
to avoid adding unnecessary scheduling constraints between the independent
memory servers. This implementation also consists of many internal rules to
easily support concurrent access between independent clients and servers.
There are better ways to get this concurrency, but they require more
implementation effort and are harder to verify.

```bluespec
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


```

### [ToGenericAtomicMemReq](../../src/bsv/MemUtil.bsv#L1270)
```bluespec
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

```

### [ToGenericAtomicMemPendingReq](../../src/bsv/MemUtil.bsv#L1280)
```bluespec
instance ToGenericAtomicMemPendingReq#(ReadOnlyMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(ReadOnlyMemReq#(addrSz, logNumBytes) req) = ?;
endinstance

```

### [FromGenericAtomicMemResp](../../src/bsv/MemUtil.bsv#L1283)
```bluespec
instance FromGenericAtomicMemResp#(ReadOnlyMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
    function ReadOnlyMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
        return ReadOnlyMemResp {
                data: resp.data
            };
    endfunction
endinstance


```

### [ToGenericAtomicMemReq](../../src/bsv/MemUtil.bsv#L1291)
```bluespec
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

```

### [ToGenericAtomicMemPendingReq](../../src/bsv/MemUtil.bsv#L1301)
```bluespec
instance ToGenericAtomicMemPendingReq#(CoarseMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(CoarseMemReq#(addrSz, logNumBytes) req) = ?;
endinstance

```

### [FromGenericAtomicMemResp](../../src/bsv/MemUtil.bsv#L1304)
```bluespec
instance FromGenericAtomicMemResp#(CoarseMemResp#(logNumBytes), void, TMul#(8,TExp#(logNumBytes)));
    function CoarseMemResp#(logNumBytes) fromGenericAtomicMemResp(GenericAtomicMemResp#(TMul#(8,TExp#(logNumBytes))) resp, void pending);
        return CoarseMemResp {
                write: resp.write,
                data: resp.data
            };
    endfunction
endinstance


```

### [ToGenericAtomicMemReq](../../src/bsv/MemUtil.bsv#L1313)
```bluespec
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

```

### [ToGenericAtomicMemPendingReq](../../src/bsv/MemUtil.bsv#L1323)
```bluespec
instance ToGenericAtomicMemPendingReq#(ByteEnMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(ByteEnMemReq#(addrSz, logNumBytes) req) = ?;
endinstance

```

### [ToGenericAtomicMemReq](../../src/bsv/MemUtil.bsv#L1336)
```bluespec
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

```

### [ToGenericAtomicMemPendingReq](../../src/bsv/MemUtil.bsv#L1346)
```bluespec
instance ToGenericAtomicMemPendingReq#(AtomicMemReq#(addrSz, logNumBytes), void);
    function void toGenericAtomicMemPendingReq(AtomicMemReq#(addrSz, logNumBytes) req) = ?;
endinstance

```

### [IsAtomicMemOp](../../src/bsv/MemUtil.bsv#L1359)
```bluespec
instance IsAtomicMemOp#(AtomicMemOp);
    function AtomicMemOp nonAtomicMemOp = None;
    function Bool isAtomicMemOp(AtomicMemOp op);
        return op != None;
    endfunction
endinstance

```

### [HasAtomicMemOpFunc](../../src/bsv/MemUtil.bsv#L1365)
```bluespec
instance HasAtomicMemOpFunc#(AtomicMemOp, dataSz, writeEnSz)
        provisos (Mul#(writeEnSz, 8, dataSz));
    function Bit#(dataSz) atomicMemOpFunc(AtomicMemOp op, Bit#(dataSz) memData, Bit#(dataSz) operandData, Bit#(writeEnSz) writeEn);
        return atomicMemOpAlu(op, memData, operandData, writeEn);
    endfunction
endinstance


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1376)
```bluespec
typeclass SimplifyMemServerPort#(type inMemServerT, type outMemServerT);
    function outMemServerT simplifyMemServerPort(inMemServerT mem);
endtypeclass


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1380)
```bluespec
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


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1400)
```bluespec
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


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1420)
```bluespec
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


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1450)
```bluespec
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


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1469)
```bluespec
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


```

### [SimplifyMemServerPort](../../src/bsv/MemUtil.bsv#L1498)
```bluespec
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


```

### [MkEmulateMemServerPort](../../src/bsv/MemUtil.bsv#L1529)
```bluespec
typeclass MkEmulateMemServerPort#(type inMemServerT, type outMemServerT);
    module mkEmulateMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass


```

### [MkEmulateMemServerPort](../../src/bsv/MemUtil.bsv#L1533)
```bluespec
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


```

### [MkEmulateMemServerPort](../../src/bsv/MemUtil.bsv#L1608)
```bluespec
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


```

### [MkEmulateMemServerPort](../../src/bsv/MemUtil.bsv#L1678)
```bluespec
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


```

### [MkNarrowerMemServerPort](../../src/bsv/MemUtil.bsv#L1745)
```bluespec
typeclass MkNarrowerMemServerPort#(type inMemServerT, type outMemServerT);
    module mkNarrowerMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass


```

### [MkNarrowerMemServerPort](../../src/bsv/MemUtil.bsv#L1749)
```bluespec
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


```

### [MkNarrowerMemServerPort](../../src/bsv/MemUtil.bsv#L1801)
```bluespec
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


```

### [MkNarrowerMemServerPort](../../src/bsv/MemUtil.bsv#L1841)
```bluespec
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


```

### [MkNarrowerMemServerPort](../../src/bsv/MemUtil.bsv#L1880)
```bluespec
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


```

### [WiderMemServerPort](../../src/bsv/MemUtil.bsv#L1914)
```bluespec
typeclass WiderMemServerPort#(type inMemServerT, type outMemServerT);
    module mkWiderMemServerPort#(inMemServerT mem)(outMemServerT);
endtypeclass


```

