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

### [readOnlyReg](../../src/bsv/RegUtil.bsv#L50)
```bluespec
function Reg#(t) readOnlyReg(t r);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x) = noAction;
        endinterface);
endfunction


```

### [mkReadOnlyReg](../../src/bsv/RegUtil.bsv#L57)
```bluespec
module mkReadOnlyReg#(t x)(Reg#(t));
    return readOnlyReg(x);
endmodule


```

### [addWriteSideEffect](../../src/bsv/RegUtil.bsv#L61)
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

