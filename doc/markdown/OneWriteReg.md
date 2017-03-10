# OneWriteReg

### [mkReg](../../src/bsv/OneWriteReg.bsv#L50)
```bluespec
module mkReg#(t initVal)(Reg#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    Reg#(t) _m <- Prelude::mkReg(initVal);

    // This wire forces the scheduling constraint _write C _write. This wire
    // is named so when the compiler emits messages about conflicting writes,
    // the user can recognize which writes caused the conflict.
    Wire#(void) double_write_conflict <- mkWire;

    method t _read;
        return _m._read;
    endmethod
    method Action _write(t x);
        _m._write(x);
        double_write_conflict._write(?);
    endmethod
endmodule


```

### [mkRegU](../../src/bsv/OneWriteReg.bsv#L68)
```bluespec
module mkRegU(Reg#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    Reg#(t) _m <- OneWriteReg::mkReg(?);
    return _m;
endmodule


```

### [mkRegA](../../src/bsv/OneWriteReg.bsv#L74)
```bluespec
module mkRegA#(t initVal)(Reg#(t)) provisos (Bits#(t,tSz));
    // This is the third variant of Reg's included in Prelude, this has not
    // been tested, so we will emit this warning.
    warningM("OneWriteReg::mkRegA has not been tested");

    (* hide *)
    Reg#(t) _m <- Prelude::mkRegA(initVal);

    // This wire forces the scheduling constraint _write C _write. This wire
    // is named so when the compiler emits messages about conflicting writes,
    // the user can recognize which writes caused the conflict.
    Wire#(void) double_write_conflict <- mkWire;

    method t _read;
        return _m._read;
    endmethod
    method Action _write(t x);
        _m._write(x);
        double_write_conflict._write(?);
    endmethod
endmodule


```

