
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

module mkCSRReg(Reg#(Bit#(asz)));
   Reg#(Bit#(asz)) r <- mkReg(0);
   method Bit#(asz) _read();
      return r;
   endmethod
   method Action _write(Bit#(asz) v);
      r <= v;
   endmethod
endmodule

`ifdef BSVTOKAMI
(* nogen *)
`endif
module mkCSRRegFromReg#(Reg#(a) r)(Reg#(a))
   provisos (Bits#(a,asz));
   method a _read();
      return r;
   endmethod
   method Action _write(a v);
      r <= v;
   endmethod
endmodule

module truncateReg#(Reg#(Bit#(k)) r)(Reg#(Bit#(n)))
   provisos (Add#(n,m,k));
	    method Bit#(n) _read();
	       Bit#(n) v = truncate(r);
	       return v;
	    endmethod
            method Action _write(Bit#(n) x);
	       Bit#(m) vmsb = truncateLSB(r);
	       Bit#(TAdd#(n,m)) v = {vmsb, x};
	       r <= v;
	    endmethod
endmodule

module truncateRegLSB#(Reg#(Bit#(m)) r)(Reg#(Bit#(n))) provisos (Add#(a__,n,m));
	    method Bit#(n) _read();
	       Bit#(n) v = truncateLSB(r);
	       return v;
	    endmethod
            method Action _write(Bit#(n) x);
	       Bit#(m) v = ({x, truncate(r)});
	       r <= v;
	    endmethod
endmodule

module zeroExtendReg#(Reg#(Bit#(m)) r)(Reg#(Bit#(n))) provisos (Add#(a__,m,n));
	    method Bit#(n) _read();
	       Bit#(n) v = zeroExtend(r);
	       return v;
	    endmethod
            method Action _write(Bit#(n) x);
	       Bit#(m) v = (truncate(x));
	       r <= v;
	    endmethod
endmodule

module addReg#(Reg#(Bit#(sz)) areg, Reg#(Bit#(sz)) breg)(Reg#(Bit#(sz)));
   method Bit#(sz) _read();
      return areg + breg;
   endmethod
   method Action _write(Bit#(sz) v);
   endmethod
endmodule

/**
 * This module takes a `Reg#(Maybe#(t))` and converts it to a `Reg#(t)`.
 *
 * Writes always store a valid value in the register, and _reads either return
 * the valid value, or default_value if the register if invalid.
 */
module fromMaybeReg#(t default_value, Reg#(Maybe#(t)) r)(Reg#(t));
                method t _read;
                   t v = fromMaybe(default_value, r);
		   return v;
                endmethod
                method Action _write(t x);
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
module packReg#(Reg#(t) r)(Reg#(Bit#(tsz))) provisos (Bits#(t, tsz));
                method Bit#(tsz) _read;
                    Bit#(tsz) v = pack(r);
		   return v;
                endmethod
                method Action _write(Bit#(tsz) x);
		    t v = unpack(x);
                    r <= v;
                endmethod
endmodule

/**
 * This function takes a `Reg#(Bit#(tsz))` and converts it to a `Reg#(t)`.
 *
 * This function parallels the standard `unpack` function that converts
 * `Bit#(tsz)` to `t` provided there is an instance of `Bits#(t, tsz)`.
 */
module unpackReg#(Reg#(Bit#(tsz)) r)(Reg#(t)) provisos (Bits#(t, tsz));
                method t _read;
                    t v = unpack(r);
		   return v;
                endmethod
                method Action _write(t x);
		   Bit#(tsz) v = pack(x);
                   r <= v;
                endmethod
endmodule

`ifdef BSVTOKAMI
(* nogen *)
`endif
function Reg#(t) readOnlyReg(t r);
   return (interface Reg#(t);
      method t _read();
	 return r;
      endmethod
      method Action _write(t x);
      endmethod
   endinterface);
endfunction

module mkReadOnlyReg#(t r)(Reg#(t));
	    method t _read();
	       return r;
	    endmethod
   method Action _write(t x);
   endmethod
endmodule

module mkReadOnlyRegWarn#(t r, String msg)(Reg#(t));
	    method t _read();
	       return r;
	    endmethod
            method Action _write(t x);
                $fdisplay(stderr, "[WARNING] _readOnlyReg: %s", msg);
            endmethod
endmodule

module mkReadOnlyRegError#(t r, String msg)(Reg#(t));
	    method t _read();
	       return r;
	    endmethod
            method Action _write(t x);
                $fdisplay(stderr, "[ERROR] _readOnlyReg: %s", msg);
                $finish(1);
            endmethod
endmodule


module addWriteSideEffect#(Reg#(t) r, function Action a())(Reg#(t));
   method t _read();
      return r;
   endmethod
   method Action _write(t x);
      r <= (x);
      a();
   endmethod
endmodule

endpackage
