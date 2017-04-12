# ShiftRegister


This package contains a generic shift register `mkShiftRegister` that can
be used as serial-in-parallel-out or parallel-in-serial-out.


### [ShiftRegister](../../src/bsv/ShiftRegister.bsv#L36)

This interface is for a generic shift register with serial and parallel
inputs and outputs.
```bluespec
interface ShiftRegister#(numeric type size, numeric type bitWidth);
    interface ServerPort#(Bit#(bitWidth), Bit#(bitWidth)) serial;
    interface ServerPort#(Vector#(size, Bit#(bitWidth)), Vector#(size, Bit#(bitWidth))) parallel;
    method Bool isEmpty;
    method Bool isLastSerialChunk;
endinterface


```

### [mkShiftRegister](../../src/bsv/ShiftRegister.bsv#L54)

This module creates a generic shift register that supports parallel and
serial inputs and outputs.


This module is designed to be used as serial-in-parallel-out or
parallel-in-serial-out. Any other combinations may result in unexpected
behaviors. Switching between these two modes when the shift register is
not empty results in un


This module does not support parallel enqueues immediately after serial
enqueues, and it does not support parallel dequeues immediately after
serial dequeues.
```bluespec
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
    method Bool isLastSerialChunk;
        // use this instead of valid_vector[1] in case size==1
        let valid_vector_1 = shiftInAtN(readVReg(valid_vector), False)[0];
        return valid_vector[0] && !valid_vector_1;
    endmethod
endmodule


```

