
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

// FIFOG.bsv
package FIFOG;

import FIFOF::*;
import SpecialFIFOs::*;
import RevertingVirtualReg::*;

export FIFOG;
export mkFIFOG;
export mkSizedFIFOG;
export mkFIFOG1;
export mkLFIFOG;
export mkBypassFIFOG;
export mkPipelineFIFOG;

// like FIFOF, but instead of adding information about the full-ness of the
// FIFO, it adds information about the guard of the FIFO
interface FIFOG#(type t);
    method Action enq(t x);
    method Action deq;
    method t first;
    method Action clear;
    method Bool notFull;
    method Bool notEmpty;
    method Bool canEnq;
    method Bool canDeq;
endinterface

// FIFOG versions of FIFOF package

// Conflict-free FIFOs
module mkFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF);
    return _m;
endmodule
module mkSizedFIFOG#(Integer n)(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkSizedFIFOF(n));
    return _m;
endmodule

// 1-element conflicting FIFO
module mkFIFOG1(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF1);
    return _m;
endmodule

// Pipeline FIFOs
module mkLFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkLFIFOF);
    return _m;
endmodule

// not included: mkGFIFO*, mkUGFIFO*, and mkDepthParamFIFOG

/////////////////////////////////////
// FIFOG versions of FIFOF package //
/////////////////////////////////////

// Bypass FIFOs
module mkBypassFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkBypassFIFOF);
    return _m;
endmodule

// mkSizedBypassFIFOF isn't correct, so we don't expose a mkSizedBypassFIFOG
// (its notEmpty and notFull methods are CF with enq and deq, but semantically
// that is not possible with one-rule-at-a-time semantics.)

// Pipeline FIFOs
module mkPipelineFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkPipelineFIFOF);
    return _m;
endmodule

///////////////////////////////////////////////
// module used to construct FIFOG from FIFOF //
///////////////////////////////////////////////
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

endpackage
