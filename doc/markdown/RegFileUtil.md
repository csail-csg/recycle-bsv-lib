# RegFileUtil


This package contains some useful variations on `RegFile`.


### [mkRegFileFullGenWith](../../src/bsv/RegFileUtil.bsv#L36)

Creates a `RegFile` that is initialized using the generating function `initF`.


`initF` takes in an address, and it should return the initial value for
that address. The interface methods of this module block until the
initialization is done.
```bluespec
module mkRegFileFullGenWith#(function t initF(a i))(RegFile#(a, t)) provisos (Bounded#(a), Bits#(a, aSz), Bits#(t, tSz));
    (* hide *)
    RegFile#(a, t) _m <- mkRegFileFull;
    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(aSz)) initIndex <- mkReg(0);
    Bit#(aSz) nextInitIndex = initIndex + 1;
    rule doRegFileInit(!init);
        _m.upd(unpack(initIndex), initF(unpack(initIndex)));
        initIndex <= initIndex + 1;
        if (initIndex == '1) init <= True;
    endrule
    method t sub(a i) if (init);
        return _m.sub(i);
    endmethod
    method Action upd(a i, t d) if (init);
        _m.upd(i,d);
    endmethod
endmodule


```

### [mkRegFileFullReplicate](../../src/bsv/RegFileUtil.bsv#L59)

Creates a `RegFile` that is initialized using the value `initVal`


The interface methods of this module block until the initialization is
done.
```bluespec
module mkRegFileFullReplicate#(t initVal)(RegFile#(a, t)) provisos (Bounded#(a), Bits#(a, aSz), Bits#(t, tSz));
    function t initF(a x);
        return initVal;
    endfunction
    (* hide *)
    let _m <- mkRegFileFullGenWith(initF);
    return _m;
endmodule


```

