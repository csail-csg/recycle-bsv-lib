
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

function Reg#(Bit#(n)) truncateReg(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncate(r._read);
            method Action _write(Bit#(n) x) = r._write({truncateLSB(r._read), x});
        endinterface);
endfunction

function Reg#(Bit#(n)) truncateRegLSB(Reg#(Bit#(m)) r) provisos (Add#(a__,n,m));
    return (interface Reg;
            method Bit#(n) _read = truncateLSB(r._read);
            method Action _write(Bit#(n) x) = r._write({x, truncate(r._read)});
        endinterface);
endfunction

function Reg#(Bit#(n)) zeroExtendReg(Reg#(Bit#(m)) r) provisos (Add#(a__,m,n));
    return (interface Reg;
            method Bit#(n) _read = zeroExtend(r._read);
            method Action _write(Bit#(n) x) = r._write(truncate(x));
        endinterface);
endfunction

/**
 * This function takes a `Reg#(Maybe#(t))` and converts it to a `Reg#(t)`.
 *
 * Writes always store a valid value in the register, and reads either return
 * the valid value, or default_value if the register if invalid.
 */
function Reg#(t) fromMaybeReg(t default_value, Reg#(Maybe#(t)) r);
    return (interface Reg;
                method t _read;
                    return fromMaybe(default_value, r);
                endmethod
                method Action _write(t x);
                    r <= tagged Valid x;
                endmethod
            endinterface);
endfunction

/**
 * This function takes a `Reg#(t)` and converts it to a `Reg#(Bit#(tsz))`.
 *
 * This function parallels the standard `pack` function that converts `t` to
 * `Bit#(tsz)` provided there is an instance of `Bits#(t, tsz)`.
 */
function Reg#(Bit#(tsz)) packReg(Reg#(t) r) provisos (Bits#(t, tsz));
    return (interface Reg;
                method Bit#(tsz) _read;
                    return pack(r);
                endmethod
                method Action _write(Bit#(tsz) x);
                    r <= unpack(x);
                endmethod
            endinterface);
endfunction

/**
 * This function takes a `Reg#(Bit#(tsz))` and converts it to a `Reg#(t)`.
 *
 * This function parallels the standard `unpack` function that converts
 * `Bit#(tsz)` to `t` provided there is an instance of `Bits#(t, tsz)`.
 */
function Reg#(t) unpackReg(Reg#(Bit#(tsz)) r) provisos (Bits#(t, tsz));
    return (interface Reg;
                method t _read;
                    return unpack(r);
                endmethod
                method Action _write(t x);
                    r <= pack(x);
                endmethod
            endinterface);
endfunction

function Reg#(t) readOnlyReg(t r);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x) = noAction;
        endinterface);
endfunction

function Reg#(t) readOnlyRegWarn(t r, String msg);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x);
                $fdisplay(stderr, "[WARNING] readOnlyReg: %s", msg);
            endmethod
        endinterface);
endfunction

function Reg#(t) readOnlyRegError(t r, String msg);
    return (interface Reg;
            method t _read = r;
            method Action _write(t x);
                $fdisplay(stderr, "[ERROR] readOnlyReg: %s", msg);
                $finish(1);
            endmethod
        endinterface);
endfunction

module mkReadOnlyReg#(t x)(Reg#(t));
    return readOnlyReg(x);
endmodule

module mkReadOnlyRegWarn#(t x, String msg)(Reg#(t));
    return readOnlyRegWarn(x, msg);
endmodule

module mkReadOnlyRegError#(t x, String msg)(Reg#(t));
    return readOnlyRegError(x, msg);
endmodule

function Reg#(t) addWriteSideEffect(Reg#(t) r, Action a);
    return (interface Reg;
            method t _read = r._read;
            method Action _write(t x);
                r._write(x);
                a;
            endmethod
        endinterface);
endfunction

endpackage
