## mkFIFOG
```bluespec
module mkFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF);
    return _m;
endmodule

```

## mkSizedFIFOG
```bluespec
module mkSizedFIFOG#(Integer n)(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkSizedFIFOF(n));
    return _m;
endmodule


```

## mkFIFOG1
```bluespec
module mkFIFOG1(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF1);
    return _m;
endmodule


```

## mkLFIFOG
```bluespec
module mkLFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkLFIFOF);
    return _m;
endmodule


```

## mkBypassFIFOG
```bluespec
module mkBypassFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkBypassFIFOF);
    return _m;
endmodule


```

## mkPipelineFIFOG
```bluespec
module mkPipelineFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkPipelineFIFOF);
    return _m;
endmodule


```

## mkFIFOGfromFIFOF
```bluespec
module [m] mkFIFOGfromFIFOF#(m#(FIFOF#(t)) mkM)(FIFOG#(t)) provisos (Bits#(t,tSz), IsModule#(m, a__));
    (* hide *)
    FIFOF#(t) _m <- mkM;

    Wire#(Bool) canEnq_wire <- mkBypassWire;
    Wire#(Bool) canDeq_wire <- mkBypassWire;
    // virtual regs are only used to force SB ordering between methods
    Reg#(Bool) virtualEnqReg <- mkRevertingVirtualReg(True);
    Reg#(Bool) virtualDeqReg <- mkRevertingVirtualReg(True);

    (* no_implicit_conditions, fire_when_enabled *)
    rule setCanEnqWire;
        canEnq_wire <= _m.notFull;
    endrule
    (* no_implicit_conditions, fire_when_enabled *)
    rule setCanDeqWire;
        canDeq_wire <= _m.notEmpty;
    endrule

    rule doAssert1;
        if (canEnq_wire != impCondOf(_m.enq)) begin
            $fdisplay(stderr, "[ERROR] mkFIFOGfromFIFOF: canEnq_wire != impCondOf(_m.enq)");
        end
    endrule
    rule doAssert2;
        if (canDeq_wire != impCondOf(_m.deq)) begin
            $fdisplay(stderr, "[ERROR] mkFIFOGfromFIFOF: canDeq_wire != impCondOf(_m.deq)");
        end
    endrule

    method Action enq(t x);
        _m.enq(x);
        virtualEnqReg <= False;
    endmethod
    method Action deq;
        _m.deq;
        virtualDeqReg <= False;
    endmethod
    method t first = _m.first;
    method Action clear = _m.clear;
    method Bool notFull = _m.notFull;
    method Bool notEmpty = _m.notEmpty;
    method Bool canEnq if (virtualEnqReg) = canEnq_wire;
    method Bool canDeq if (virtualDeqReg) = canDeq_wire;
endmodule


```

