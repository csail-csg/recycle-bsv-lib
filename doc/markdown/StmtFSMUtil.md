# StmtFSMUtil

### [FlexFSM](../../src/bsv/StmtFSMUtil.bsv#L31)
```bluespec
interface FlexFSM;
    method Action start;
    method Bool running_schedBeforeStart;
    method Bool running_schedAfterStart;
endinterface


```

### [mkFlexFSM](../../src/bsv/StmtFSMUtil.bsv#L37)
```bluespec
module mkFlexFSM#(Stmt seq_stmt)(FlexFSM);
    Reg#(Bool) running_config_reg <- mkConfigReg(False);
    Ehr#(2, Bool) running <- mkEhr(False);
    FSM _fsm <- mkFSMWithPred(seq seq_stmt; action running[0] <= False; running_config_reg <= False; endaction endseq, running_config_reg);

    method Action start if (!running[0]);
        running[0] <= True;
        running_config_reg <= True;
        _fsm.start;
    endmethod
    method Bool running_schedBeforeStart;
        return running[0] || running_config_reg;
    endmethod
    method Bool running_schedAfterStart;
        return running[1] || running_config_reg;
    endmethod
endmodule


```

### [mkSafeFSM](../../src/bsv/StmtFSMUtil.bsv#L55)
```bluespec
module mkSafeFSM#(Stmt seq_stmt)(FSM);
    Reg#(Bool) fsmRunning <- mkReg(False);
    FSM _fsm <- mkFSMWithPred(seq seq_stmt; fsmRunning <= False; endseq, fsmRunning);

    method Action start if (!fsmRunning);
        fsmRunning <= True;
        _fsm.start;
    endmethod

    method Action waitTillDone;
        _fsm.waitTillDone;
    endmethod

    method Bool done;
        return !fsmRunning;
    endmethod

    method Action abort if (False);
        noAction;
    endmethod
endmodule


```

### [mkBypassFSM](../../src/bsv/StmtFSMUtil.bsv#L77)
```bluespec
module mkBypassFSM#(Stmt seq_stmt)(FSM);
    Ehr#(2, Bool) fsmRunning <- mkEhr(False);
    FSM _fsm <- mkFSMWithPred(seq seq_stmt; fsmRunning[0] <= False; endseq, fsmRunning[0]);

    method Action start if (!fsmRunning[0]);
        fsmRunning[0] <= True;
        _fsm.start;
    endmethod

    method Action waitTillDone;
        _fsm.waitTillDone;
    endmethod

    method Bool done;
        return !fsmRunning[1];
    endmethod

    method Action abort if (False);
        noAction;
    endmethod
endmodule


```

