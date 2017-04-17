
// Copyright (c) 2016, 2017 Massachusetts Institute of Technology

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
 * This package contains constructors for a group of FIFOs with a `FIFOG`
 * interface. `FIFOG` is like `FIFOF`, but instead of adding information
 * about the fullness of the FIFO, it adds information about the guards
 * of the FIFO.
 *
 * In a correct `FIFOF` implementation, `notFull` and `notEmpty` must be
 * scheduled before both `enq` and `deq` for correct one-rule-at-a-time
 * semantics. In this case, the following two rules conflict and are unable to
 * be scheduled in the same cycle.
 *
 * ```
 * rule enqIntoFIFOF;
 *     if (fifo.notFull) fifo.enq(x);
 * endrule
 *
 * rule deqFromFIFOF;
 *     if (fifo.notEmpty) fifo.deq();
 * endrule
 * ```
 *
 * Semantically, the interface method `canEnq` does not have to come before
 * `deq`, and `canDeq` do not have to come before `enq`, so by using `FIFOG`
 * you can write the two rules below which will not conflict.
 *
 * ```
 * rule enqIntoFIFOG;
 *     if (fifo.canEnq) fifo.enq(x);
 * endrule
 *
 * rule deqFromFIFOG;
 *     if (fifo.canDeq) fifo.deq();
 * endrule
 * ```
 * 
 */
package FIFOG;

import FIFOF::*;
import GetPut::*;
import SpecialFIFOs::*;
import RevertingVirtualReg::*;

export FIFOG(..);
export mkFIFOG;
export mkSizedFIFOG;
export mkFIFOG1;
export mkLFIFOG;
export mkBypassFIFOG;
export mkPipelineFIFOG;

/// Like FIFOF, but instead of adding information about the full-ness of the
/// FIFO, it adds information about the guard of the FIFO.
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

// toGet and toPut functions for FIFOG interface
instance ToGet#(FIFOG#(t), t);
    function Get#(t) toGet(FIFOG#(t) m);
        return (interface Get;
                    method ActionValue#(t) get();
                        m.deq;
                        return m.first();
                    endmethod
                endinterface);
    endfunction
endinstance

instance ToPut#(FIFOG#(t), t);
    function Put#(t) toPut(FIFOG#(t) m);
        return (interface Put;
                    method Action put(t x);
                        m.enq(x);
                    endmethod
                endinterface);
    endfunction
endinstance

// FIFOG versions of FIFOF package

/// 2-element conflict-free `FIFOG`
module mkFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF);
    return _m;
endmodule

/// Sized conflict-free `FIFOG`
module mkSizedFIFOG#(Integer n)(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkSizedFIFOF(n));
    return _m;
endmodule

/// 1-element conflicting `FIFOG`
module mkFIFOG1(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkFIFOF1);
    return _m;
endmodule

/// Pipeline `FIFOG`
module mkLFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkLFIFOF);
    return _m;
endmodule

// not included: mkGFIFO*, mkUGFIFO*, and mkDepthParamFIFOG

/////////////////////////////////////
// FIFOG versions of FIFOF package //
/////////////////////////////////////

/// Bypass `FIFOG`
///
/// Note: `mkSizedBypassFIFOF` isn't correct, so we don't expose a
/// `mkSizedBypassFIFOG` (its `notEmpty` and `notFull` methods are CF with
/// `enq` and `deq`, but semantically that is not possible with
/// one-rule-at-a-time semantics.)
module mkBypassFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkBypassFIFOF);
    return _m;
endmodule

/// Pipeline `FIFOG`
///
/// This FIFO has a scheduling constraint that requires `deq` to come before
/// `enq`.
module mkPipelineFIFOG(FIFOG#(t)) provisos (Bits#(t,tSz));
    (* hide *)
    let _m <- mkFIFOGfromFIFOF(mkPipelineFIFOF);
    return _m;
endmodule

/// Module to make `FIFOG` from a `FIFOF` module.
///
/// This module construct a `FIFOG` from a `FIFOF` by using wires to delay the
/// the `notEmpty` and `notFull` signals so they can be used as `canDeq` and `canEnq`.
module [m] mkFIFOGfromFIFOF#(m#(FIFOF#(t)) mkM)(FIFOG#(t)) provisos (Bits#(t,tSz), IsModule#(m, a__));
    (* hide *)
    FIFOF#(t) _m <- mkM;

    Wire#(Bool) canEnq_wire <- mkBypassWire;
    Wire#(Bool) canDeq_wire <- mkBypassWire;
    // virtual regs are only used to force SB ordering between methods
    Reg#(Bool) virtualEnqReg <- mkRevertingVirtualReg(True);
    Reg#(Bool) virtualDeqReg <- mkRevertingVirtualReg(True);

    (* fire_when_enabled *)
    rule setCanEnqWire;
        canEnq_wire <= _m.notFull;
    endrule
    (* fire_when_enabled *)
    rule setCanDeqWire;
        canDeq_wire <= _m.notEmpty;
    endrule

    // These rules can help with debugging when using this module on a new
    // FIFOF module, but they are commented out in normal use because
    // impCondOf() is not fully supported by the bluespec compiler yet and
    // causes compilation warnings.
    // rule doAssert1;
    //     if (canEnq_wire != impCondOf(_m.enq)) begin
    //         $fdisplay(stderr, "[ERROR] mkFIFOGfromFIFOF: canEnq_wire != impCondOf(_m.enq)");
    //     end
    // endrule
    // rule doAssert2;
    //     if (canDeq_wire != impCondOf(_m.deq)) begin
    //         $fdisplay(stderr, "[ERROR] mkFIFOGfromFIFOF: canDeq_wire != impCondOf(_m.deq)");
    //     end
    // endrule

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
