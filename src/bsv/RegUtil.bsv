
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
 * Utility functions for registers
 */
package RegUtil;

interface CSRReg#(type a);
   method a read();
   method Action write(a v);
endinterface

module mkCSRReg(CSRReg#(Bit#(asz)));
   Reg#(Bit#(asz)) r <- mkReg(0);
   method Bit#(asz) read();
      return r;
   endmethod
   method Action write(Bit#(asz) v);
      r <= v;
   endmethod
endmodule

(* nogen *)
module mkCSRRegFromReg#(Reg#(a) r)(CSRReg#(a))
   provisos (Bits#(a));
   method a read();
      return r;
   endmethod
   method Action write(a v);
      r <= v;
   endmethod
endmodule

module truncateReg#(Reg#(Bit#(TAdd#(n,m))) r)(CSRReg#(Bit#(n)));
	    method Bit#(n) read();
	       Bit#(n) v = truncate(r);
	       return v;
	    endmethod
            method Action write(Bit#(n) x);
	       Bit#(m) vmsb = truncateLSB(r);
	       Bit#(TAdd#(n,m)) v = {vmsb, x};
	       r <= v;
	    endmethod
endmodule

module truncateRegLSB#(Reg#(Bit#(m)) r)(CSRReg#(Bit#(n))) provisos (Add#(a__,n,m));
	    method Bit#(n) read();
	       Bit#(n) v = truncateLSB(r);
	       return v;
	    endmethod
            method Action write(Bit#(n) x);
	       Bit#(n) v = ({x, truncate(r)});
	       r <= v;
	    endmethod
endmodule

module zeroExtendReg#(Reg#(Bit#(m)) r)(CSRReg#(Bit#(n))) provisos (Add#(a__,m,n));
	    method Bit#(n) read();
	       Bit#(n) v = zeroExtend(r);
	       return v;
	    endmethod
            method Action write(Bit#(n) x);
	       Bit#(m) v = (truncate(x));
	       r <= v;
	    endmethod
endmodule

/**
 * This module takes a `Reg#(Maybe#(t))` and converts it to a `Reg#(t)`.
 *
 * Writes always store a valid value in the register, and reads either return
 * the valid value, or default_value if the register if invalid.
 */
module fromMaybeReg#(t default_value, Reg#(Maybe#(t)) r)(CSRReg#(t));
                method t read;
                   t v = fromMaybe(default_value, r);
		   return v;
                endmethod
                method Action write(t x);
		   Maybe#(t) v = tagged Valid x;
                   r <= v;
                endmethod
endmodule

/**
 * This function takes a `Reg#(t)` and converts it to a `Reg#(Bit#(tsz))`.
 *
 * This function parallels the standard `pack` function that converts `t` to
 * `Bit#(tsz)` provided there is an instance of `Bits#(t, tsz)`.
 */
module packReg#(Reg#(t) r)(CSRReg#(Bit#(tsz))) provisos (Bits#(t, tsz));
                method Bit#(tsz) read;
                    Bit#(tsz) v = pack(r);
		   return v;
                endmethod
                method Action write(Bit#(tsz) x);
		   Bit#(tsz) v = unpack(x);
                    r <= v;
                endmethod
endmodule

/**
 * This function takes a `Reg#(Bit#(tsz))` and converts it to a `Reg#(t)`.
 *
 * This function parallels the standard `unpack` function that converts
 * `Bit#(tsz)` to `t` provided there is an instance of `Bits#(t, tsz)`.
 */
module unpackReg#(Reg#(Bit#(tsz)) r)(CSRReg#(t)) provisos (Bits#(t, tsz));
                method t read;
                    t v = unpack(r);
		   return v;
                endmethod
                method Action write(t x);
		   Bit#(tsz) v = pack(x);
                   r <= v;
                endmethod
endmodule

module readOnlyReg#(t r)(CSRReg#(t));
	    method t read();
	       return r;
	    endmethod
   method Action write(t x);
   endmethod
endmodule

module readOnlyRegWarn#(t r, String msg)(CSRReg#(t));
	    method t read();
	       return r;
	    endmethod
            method Action write(t x);
                $fdisplay(stderr, "[WARNING] readOnlyReg: %s", msg);
            endmethod
endmodule

module readOnlyRegError#(t r, String msg)(CSRReg#(t));
	    method t read();
	       return r;
	    endmethod
            method Action write(t x);
                $fdisplay(stderr, "[ERROR] readOnlyReg: %s", msg);
                $finish(1);
            endmethod
endmodule

(* nogen *)
module mkReadOnlyReg#(t x)(Reg#(t));
    return readOnlyReg(x);
endmodule

(* nogen *)
module mkReadOnlyRegWarn#(t x, String msg)(Reg#(t));
    return readOnlyRegWarn(x, msg);
endmodule

(* nogen *)
module mkReadOnlyRegError#(t x, String msg)(Reg#(t));
    return readOnlyRegError(x, msg);
endmodule

(* nogen *)
module addWriteSideEffect#(Reg#(t) r, Action a)(CSRReg#(t));
   method t read();
      return r;
   endmethod
   method Action write(t x);
      r <= (x);
      a;
   endmethod
endmodule

endpackage
