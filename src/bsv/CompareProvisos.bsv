
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

// CompareProvisos.bsv
// These are human readable provisos for comparing sizes of numberic types

// a > b
typeclass GT#(numeric type a, numeric type b);
endtypeclass
instance GT#(a, b) provisos (Add#(_n, TAdd#(b,1), a));
endinstance

// a >= b
typeclass GTE#(numeric type a, numeric type b);
endtypeclass
instance GTE#(a, b) provisos (Add#(_n, b, a));
endinstance

// a < b
typeclass LT#(numeric type a, numeric type b);
endtypeclass
instance LT#(a, b) provisos (Add#(_n, TAdd#(a,1), b));
endinstance

// a <= b
typeclass LTE#(numeric type a, numeric type b);
endtypeclass
instance LTE#(a, b) provisos (Add#(_n, a, b));
endinstance

// a == b
typeclass EQ#(numeric type a, numeric type b);
endtypeclass
instance EQ#(a, b) provisos (Add#(0, a, b));
endinstance
