
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

/**
 * This package contains items that are useful in clock gating. Currently
 * it only contains `exposeCurrentClockGate`.
 */
package ClockGate;

/**
 * This module returns the value of the current clock's enable signal.
 *
 * Clock gating in BSV behaves as if the clock enable signal is added to the
 * guard of every register write, but not to the guard of register reads. To
 * expose the current value of the clock gate, the `exposeCurrentClockGate`
 * module tries to write to a register and a wire in the same rule every clock
 * cycle. If the clock enable signal is false, then the rule will not fire and
 * the register and the wire will not be written. The value of the wire is
 * used to encode the current value of the clock enable signal through the use
 * of a `mkDWire` so the wire has a default value of False if it is not
 * written.
 *
 * This module is named to match `exposeCurrentClock`.
 */
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

endpackage
