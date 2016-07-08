#!/usr/bin/env python

# Copyright (c) 2016 Massachusetts Institute of Technology

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import operator
import os
import subprocess
import sys
import tempfile

# This opens /dev/null for output
fout = open(os.devnull, 'w')

provisos = {
        'GT'  : operator.gt,
        'GTE' : operator.ge,
        'LT'  : operator.lt,
        'LTE' : operator.le,
        'EQ'  : operator.eq
    }
values = [
        (0,0),
        (100, 100),
        (0,1),
        (1,0),
        (25,7),
        (3,10)
    ]

print 'Provisos to test and if they should be satisfied:'
tests = []
for p in provisos:
    for (a, b) in values:
        provisoString = p + '#(%d,%d)' % (a, b)
        isSatisfied = provisos[p](a, b)
        print '\t' + provisoString + '\t' + str(isSatisfied)
        tests = tests + [(provisoString, isSatisfied)]

print "\nRunning tests..."

# Compile CompareProvisos
subprocess.Popen(["bsc", "-bdir", "/tmp", "../src/bsv/CompareProvisos.bsv"], stdout=fout, stderr=fout).wait()

successful = True
for (provisoString, isSatisfied) in tests:
    (fd, filename) = tempfile.mkstemp(suffix='.bsv')
    try:
        tfile = os.fdopen(fd, "w")
        tfile.write("import CompareProvisos::*;\n")
        tfile.write("(* synthesize *)\n")
        tfile.write("module mkTest(Empty);\n")
        tfile.write("    let _x <- mkModuleWithProviso;\n")
        tfile.write("endmodule\n")
        tfile.write("module mkModuleWithProviso(Empty) provisos (\n")
        tfile.write("    " + provisoString + "\n")
        tfile.write(");\n")
        tfile.write("endmodule\n")
        tfile.close()
        try:
            subprocess.check_call(["bsc", "-bdir", "/tmp", filename], stdout=fout, stderr=fout)
            if not isSatisfied:
                print provisoString + "\tFAILED (compilation successful)"
                successful = False
            else:
                print provisoString + "\tPassed (compilation successful)"
        except subprocess.CalledProcessError:
            if isSatisfied:
                print provisoString + "\tFAILED (compilation failed)"
                successful = False
            else:
                print provisoString + "\tPassed (compilation failed)"
    finally:
        os.remove(filename)
if not successful:
    print "\nTEST FAILED"
    sys.exit(-1)
else:
    print "\nAll tests passed!"
