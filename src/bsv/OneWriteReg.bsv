
// Copyright (c) 2016 Massachusetts Institute of Technology

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

package OneWriteReg;

// This package reimplements  mkReg, mkRegU, and mkRegA (untested) so that
// writes to the same register conflict with each other. When a design imports
// this package, all instances of mkReg, mkRegU, and mkRegA will get their
// implementation from this package unless the prelude package is specified
// (i.e. prelude::mkReg, prelude::mkRegU, prelude::mkRegA)

// Exports modules that shadow Prelude's implementation.
export mkReg;
export mkRegU;
export mkRegA;

// Conflict Matrix for mkReg, mkRegU, and mkRegA:
//
//          _read _write
//        +------+------+
//  _read |  CF  |  SB  |
//        +------+------+
// _write |  SA  |  C   |
//        +------+------+
//
// This is different from Prelude::mkReg due to the conflicting _write method.
// Prelude::mkReg has _write SBR _write meaning two writes can be scheduled
// concurrently as long as they are not in the same rule.

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

module mkRegU(Reg#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    Reg#(t) _m <- OneWriteReg::mkReg(?);
    return _m;
endmodule

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

endpackage
