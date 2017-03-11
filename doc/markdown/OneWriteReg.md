# OneWriteReg


This package reimplements  mkReg, mkRegU, and mkRegA (untested) so that
writes to the same register conflict with each other. When a design imports
this package, all instances of mkReg, mkRegU, and mkRegA will get their
implementation from this package unless the prelude package is specified
(i.e. prelude::mkReg, prelude::mkRegU, prelude::mkRegA)

Conflict Matrix for mkReg, mkRegU, and mkRegA:

             _read _write
           +------+------+
     _read |  CF  |  SB  |
           +------+------+
    _write |  SA  |  C   |
           +------+------+

This is different from Prelude::mkReg due to the conflicting _write method.
Prelude::mkReg has _write SBR _write meaning two writes can be scheduled
concurrently as long as they are not in the same rule.


### [mkReg](../../src/bsv/OneWriteReg.bsv#L52)
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

### [mkRegU](../../src/bsv/OneWriteReg.bsv#L70)
```bluespec
module mkRegU(Reg#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    Reg#(t) _m <- OneWriteReg::mkReg(?);
    return _m;
endmodule


```

### [mkRegA](../../src/bsv/OneWriteReg.bsv#L76)
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

