## truncateReg
```bluespec
function Reg#(Bit#(n)) truncateReg(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncate(r._read);
            method Action _write(Bit#(n) x) = r._write({truncateLSB(r._read), x});
        endinterface);
endfunction


```

## truncateRegLSB
```bluespec
function Reg#(Bit#(n)) truncateRegLSB(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncateLSB(r._read);
            method Action _write(Bit#(n) x) = r._write({x, truncate(r._read)});
        endinterface);
endfunction


```

## zeroExtendReg
```bluespec
function Reg#(Bit#(n)) zeroExtendReg(Reg#(Bit#(m)) r) provisos (Add#(a__,m,n));
    return (interface Reg;
            method Bit#(n) _read = zeroExtend(r._read);
            method Action _write(Bit#(n) x) = r._write(truncate(x));
        endinterface);
endfunction


```

## readOnlyReg
```bluespec
function Reg#(t) readOnlyReg(t r);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x) = noAction;
        endinterface);
endfunction


```

## mkReadOnlyReg
```bluespec
module mkReadOnlyReg#(t x)(Reg#(t));
    return readOnlyReg(x);
endmodule


```

## addWriteSideEffect
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

