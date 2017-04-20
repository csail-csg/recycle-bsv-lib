# ClockGate


This package contains items that are useful in clock gating. Currently
it only contains `exposeCurrentClockGate`.


### [exposeCurrentClockGate](../../src/bsv/ClockGate.bsv#L45)


This module returns the value of the current clock's enable signal.

Clock gating in BSV behaves as if the clock enable signal is added to the
guard of every register write, but not to the guard of register reads. To
expose the current value of the clock gate, the `exposeCurrentClockGate`
module tries to write to a register and a wire in the same rule every clock
cycle. If the clock enable signal is false, then the rule will not fire and
the register and the wire will not be written. The value of the wire is
used to encode the current value of the clock enable signal through the use
of a `mkDWire` so the wire has a default value of False if it is not
written.

This module is named to match `exposeCurrentClock`.

```bluespec
module exposeCurrentClockGate(Bool);
    Reg#(Bool) clock_gate_test_reg <- mkReg(True);
    Wire#(Bool) clock_gate <- mkDWire(False);
    // implicit conditions = input clock gate
    (* fire_when_enabled *)
    rule checkClockGate;
        clock_gate_test_reg <= True;
        clock_gate <= True;
    endrule
    return clock_gate;
endmodule


```

