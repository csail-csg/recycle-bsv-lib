
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
 * This package contains a generic shift register `mkShiftRegister` that can
 * be used as serial-in-parallel-out or parallel-in-serial-out.
 */
package ShiftRegister;

import Vector::*;

import Port::*;

/// This interface is for a generic shift register with serial and parallel
/// inputs and outputs.
interface ShiftRegister#(numeric type size, numeric type bitWidth);
    interface ServerPort#(Bit#(bitWidth), Bit#(bitWidth)) serial;
    interface ServerPort#(Vector#(size, Bit#(bitWidth)), Vector#(size, Bit#(bitWidth))) parallel;
    method Bool isEmpty;
endinterface

/// This module creates a generic shift register that supports parallel and
/// serial inputs and outputs.
///
/// This module is designed to be used as serial-in-parallel-out or
/// parallel-in-serial-out. Any other combinations may result in unexpected
/// behaviors. Switching between these two modes when the shift register is
/// not empty results in un
///
/// This module does not support parallel enqueues immediately after serial
/// enqueues, and it does not support parallel dequeues immediately after
/// serial dequeues.
module mkShiftRegister(ShiftRegister#(size, bitWidth));
    Vector#(size, Reg#(Bool)) valid_vector <- replicateM(mkReg(False));
    Vector#(size, Reg#(Bit#(bitWidth))) data_vector <- replicateM(mkReg(0));

    interface ServerPort serial;
        interface InputPort request;
            method Action enq(Bit#(bitWidth) x) if (!valid_vector[0]);
                writeVReg(data_vector, shiftInAtN(readVReg(data_vector), x));
                writeVReg(valid_vector, shiftInAtN(readVReg(valid_vector), True));
            endmethod
            method Bool canEnq;
                return !valid_vector[0];
            endmethod
        endinterface
        interface OutputPort response;
            method Bit#(bitWidth) first if (valid_vector[0]);
                return data_vector[0];
            endmethod
            method Action deq if (valid_vector[0]);
                writeVReg(data_vector, shiftInAtN(readVReg(data_vector), 0));
                writeVReg(valid_vector, shiftInAtN(readVReg(valid_vector), False));
            endmethod
            method Bool canDeq;
                return valid_vector[0];
            endmethod
        endinterface
    endinterface
    interface ServerPort parallel;
        interface InputPort request;
            method Action enq(Vector#(size, Bit#(bitWidth)) x) if (!valid_vector[0] && !valid_vector[valueOf(size)-1]);
                writeVReg(valid_vector, replicate(True));
                writeVReg(data_vector, x);
            endmethod
            method Bool canEnq;
                return !valid_vector[0] && !valid_vector[valueOf(size)-1];
            endmethod
        endinterface
        interface OutputPort response;
            method Vector#(size, Bit#(bitWidth)) first if (valid_vector[0] && valid_vector[valueOf(size)-1]);
                return readVReg(data_vector);
            endmethod
            method Action deq if (valid_vector[0] && valid_vector[valueOf(size)-1]);
                writeVReg(valid_vector, replicate(False));
            endmethod
            method Bool canDeq;
                return valid_vector[0] && valid_vector[valueOf(size)-1];
            endmethod
        endinterface
    endinterface
    method Bool isEmpty;
        return !valid_vector[0] && !valid_vector[valueOf(size)-1];
    endmethod
endmodule

endpackage
