#!/usr/bin/env python3

# Copyright (c) 2016-2019 Massachusetts Institute of Technology
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
from mako.template import Template

max_num_ports = 8

verilog_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'v')
bsv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'bsv')
mako_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'mako')

verilog_template_filename =  os.path.join(mako_path, 'VerilogEHR.mako')
verilog_template = Template(filename = verilog_template_filename)
bluespec_template_filename = os.path.join(mako_path, 'VerilogEHRWrapper.mako')
bluespec_template = Template(filename = bluespec_template_filename)

for i in range(1, max_num_ports+1):
    with open(os.path.join(verilog_path, 'EHR_%d.v' % i), 'w') as f:
        f.write('// generated by %s using %s\n' % (os.path.basename(__file__), os.path.basename(verilog_template_filename)))
        f.write(verilog_template.render( num_ports = i, has_reset = True ))
    with open(os.path.join(verilog_path, 'EHRU_%d.v' % i), 'w') as f:
        f.write('// generated by %s using %s\n' % (os.path.basename(__file__), os.path.basename(verilog_template_filename)))
        f.write(verilog_template.render( num_ports = i, has_reset = False ))

with open(os.path.join(bsv_path, 'VerilogEHR.bsv'), 'w') as f:
    f.write('// generated by %s using %s\n' % (os.path.basename(__file__), os.path.basename(bluespec_template_filename)))
    f.write(bluespec_template.render(max_num_ports = max_num_ports))

# def get_verilog_for_ehr(n, has_reset = True):
#     if has_reset:
#         verilog = "module EHR_{n} (\n".format(n = n)
#     else:
#         verilog = "module EHRU_{n} (\n".format(n = n)
# 
#     verilog += "    CLK,\n"
#     if has_reset:
#         verilog += "    RST_N,\n"
#     for i in range(n):
#         verilog += "    read_{i},\n    write_{i},\n    EN_write_{i}".format(i = i)
#         if i != n-1:
#             verilog += ","
#         verilog += "\n"
# 
#     verilog += ");\n"
# 
#     verilog += "    parameter            DATA_SZ = 1;\n"
#     verilog += "    parameter            RESET_VAL = 0;\n"
#     verilog += "\n"
# 
#     verilog += "    input                CLK;\n"
#     if has_reset:
#         verilog += "    input                RST_N;\n"
#     for i in range(n):
#         verilog += "    output [DATA_SZ-1:0] read_{i};\n".format(i = i)
#         verilog += "    input  [DATA_SZ-1:0] write_{i};\n".format(i = i)
#         verilog += "    input                EN_write_{i};\n".format(i = i)
#     verilog += "\n"
# 
#     verilog += "    reg    [DATA_SZ-1:0] r;\n"
#     for i in range(n+1):
#         verilog += "    wire   [DATA_SZ-1:0] wire_{i};\n".format(i = i)
#     verilog += "\n"
# 
#     verilog += "    assign wire_0 = r;\n"
#     for i in range(1,n+1):
#         verilog += "    assign wire_{i} = EN_write_{prev_i} ? write_{prev_i} : wire_{prev_i};\n".format(i = i, prev_i = i-1)
#     verilog += "\n"
# 
#     for i in range(n):
#         verilog += "    assign read_{i} = wire_{i};\n".format(i = i)
#     verilog += "\n"
# 
#     verilog += "    always @(posedge CLK) begin\n"
#     if has_reset:
#         verilog += "        if (RST_N == 0) begin\n"
#         verilog += "            r <= RESET_VAL;\n"
#         verilog += "        end else begin\n"
#         verilog += "            r <= wire_{n};\n".format(n = n)
#         verilog += "        end\n"
#     else:
#         verilog += "        r <= wire_{n};\n".format(n = n)
#     verilog += "    end\n"
#     verilog += "endmodule\n"
# 
#     return verilog
# 
# if __name__ == '__main__':
#     import sys
#     import os
# 
#     max_num_ports = 8
# 
#     if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
#         print('ERROR: %s expects an output directory as an argument' % sys.argv[0])
#         exit(1)
# 
#     for i in range(1,max_num_ports+1):
#         with open(os.path.join(sys.argv[1], "EHR_%d.v" % i), "w") as f:
#             f.write(get_verilog_for_ehr(i, has_reset = True))
#         with open(os.path.join(sys.argv[1], "EHRU_%d.v" % i), "w") as f:
#             f.write(get_verilog_for_ehr(i, has_reset = False))