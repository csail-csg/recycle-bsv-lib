
// Copyright (c) 2017 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// This is a copy of StmtFSMUtil to avoid a name conflict with the
/// StmtFSMUtil package that is part of the open-sourced Bluespec
/// compiler.
package StmtFSMExtra;

import ConfigReg::*;
import StmtFSM::*;

import Ehr::*;

interface FlexFSM;
    method Action start;
    method Bool running_schedBeforeStart;
    method Bool running_schedAfterStart;
endinterface

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

endpackage
