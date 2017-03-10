### mkSafeCounter
```bluespec
module mkSafeCounter#(t initVal)(SafeCounter#(t)) provisos(Alias#(t, Bit#(w)));
    Ehr#(2, t) cnt <- mkEhr(initVal);
    Ehr#(3, t) incr_req <- mkEhr(0);
    Ehr#(3, t) decr_req <- mkEhr(0);

    // reverting virtual registers for forcing scheduling
    Reg#(t) rvr_readBeforeIncr <- mkRevertingVirtualReg(0);
    Reg#(t) rvr_readBeforeDecr <- mkRevertingVirtualReg(0);

    (* fire_when_enabled, no_implicit_conditions *)
    rule updateCounter;
        cnt[1] <= cnt[1] + incr_req[2] - decr_req[2];
        incr_req[2] <= 0;
        decr_req[2] <= 0;
    endrule

    method Action incr(t v) if (incr_req[0] == 0);
        // This when statement is required to add a guard that depends on the
        // input value of the method
        when(cnt[0] <= maxBound - v,
            action
                incr_req[0] <= v;
                rvr_readBeforeIncr <= 0;
            endaction);
    endmethod

    method Action decr(t v) if (decr_req[0] == 0);
        // This when statement is required to add a guard that depends on the
        // input value of the method
        when(cnt[0] >= minBound + v,
            action
                decr_req[0] <= v;
                rvr_readBeforeDecr <= 0;
            endaction);
    endmethod

    method t _read = cnt[0] | rvr_readBeforeIncr | rvr_readBeforeDecr;

    method Action _write(t v);
        incr_req[1] <= 0;
        decr_req[1] <= 0;
        cnt[0] <= v;
    endmethod
endmodule

```

