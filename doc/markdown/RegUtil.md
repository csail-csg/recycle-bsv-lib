# RegUtil


Utility functions for registers


### [truncateReg](../../src/bsv/RegUtil.bsv#L29)
```bluespec
function Reg#(Bit#(n)) truncateReg(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncate(r._read);
            method Action _write(Bit#(n) x) = r._write({truncateLSB(r._read), x});
        endinterface);
endfunction


```

### [truncateRegLSB](../../src/bsv/RegUtil.bsv#L36)
```bluespec
function Reg#(Bit#(n)) truncateRegLSB(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncateLSB(r._read);
            method Action _write(Bit#(n) x) = r._write({x, truncate(r._read)});
        endinterface);
endfunction


```

### [zeroExtendReg](../../src/bsv/RegUtil.bsv#L43)
```bluespec
function Reg#(Bit#(n)) zeroExtendReg(Reg#(Bit#(m)) r) provisos (Add#(a__,m,n));
    return (interface Reg;
            method Bit#(n) _read = zeroExtend(r._read);
            method Action _write(Bit#(n) x) = r._write(truncate(x));
        endinterface);
endfunction


```

### [fromMaybeReg](../../src/bsv/RegUtil.bsv#L56)


This function takes a `Reg#(Maybe#(t))` and converts it to a `Reg#(t)`.

Writes always store a valid value in the register, and reads either return
the valid value, or default_value if the register if invalid.

```bluespec
function Reg#(t) fromMaybeReg(t default_value, Reg#(Maybe#(t)) r);
    return (interface Reg;
                method t _read;
                    return fromMaybe(default_value, r);
                endmethod
                method Action _write(t x);
                    r <= tagged Valid x;
                endmethod
            endinterface);
endfunction


```

### [packReg](../../src/bsv/RegUtil.bsv#L73)


This function takes a `Reg#(t)` and converts it to a `Reg#(Bit#(tsz))`.

This function parallels the standard `pack` function that converts `t` to
`Bit#(tsz)` provided there is an instance of `Bits#(t, tsz)`.

```bluespec
function Reg#(Bit#(tsz)) packReg(Reg#(t) r) provisos (Bits#(t, tsz));
    return (interface Reg;
                method Bit#(tsz) _read;
                    return pack(r);
                endmethod
                method Action _write(Bit#(tsz) x);
                    r <= unpack(x);
                endmethod
            endinterface);
endfunction


```

### [unpackReg](../../src/bsv/RegUtil.bsv#L90)


This function takes a `Reg#(Bit#(tsz))` and converts it to a `Reg#(t)`.

This function parallels the standard `unpack` function that converts
`Bit#(tsz)` to `t` provided there is an instance of `Bits#(t, tsz)`.

```bluespec
function Reg#(t) unpackReg(Reg#(Bit#(tsz)) r) provisos (Bits#(t, tsz));
    return (interface Reg;
                method t _read;
                    return unpack(r);
                endmethod
                method Action _write(t x);
                    r <= pack(x);
                endmethod
            endinterface);
endfunction


```

### [readOnlyReg](../../src/bsv/RegUtil.bsv#L101)
```bluespec
function Reg#(t) readOnlyReg(t r);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x) = noAction;
        endinterface);
endfunction


```

### [readOnlyRegWarn](../../src/bsv/RegUtil.bsv#L108)
```bluespec
function Reg#(t) readOnlyRegWarn(t r, String msg);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x);
                $fdisplay(stderr, "[WARNING] readOnlyReg: %s", msg);
            endmethod
        endinterface);
endfunction


```

### [readOnlyRegError](../../src/bsv/RegUtil.bsv#L117)
```bluespec
function Reg#(t) readOnlyRegError(t r, String msg);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x);
                $fdisplay(stderr, "[ERROR] readOnlyReg: %s", msg);
                $finish(1);
            endmethod
        endinterface);
endfunction


```

### [mkReadOnlyReg](../../src/bsv/RegUtil.bsv#L127)
```bluespec
module mkReadOnlyReg#(t x)(Reg#(t));
    return readOnlyReg(x);
endmodule


```

### [mkReadOnlyRegWarn](../../src/bsv/RegUtil.bsv#L131)
```bluespec
module mkReadOnlyRegWarn#(t x, String msg)(Reg#(t));
    return readOnlyRegWarn(x, msg);
endmodule


```

### [mkReadOnlyRegError](../../src/bsv/RegUtil.bsv#L135)
```bluespec
module mkReadOnlyRegError#(t x, String msg)(Reg#(t));
    return readOnlyRegError(x, msg);
endmodule


```

### [addWriteSideEffect](../../src/bsv/RegUtil.bsv#L139)
```bluespec
function Reg#(t) addWriteSideEffect(Reg#(t) r, Action a);
    return (interface Reg;
            method t _read = r._read;
            method Action _write(t x);
                r._write(x);
                a;
            endmethod
        endinterface);
endfunction


```

