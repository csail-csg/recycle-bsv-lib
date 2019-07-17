
// Copyright (c) 2019 Massachusetts Institute of Technology

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

<%
    # This template expects num_ports and has_reset
    module_name = 'EHR'
    if not has_reset:
        module_name += 'U'
    module_name += '_' + str(num_ports)
%>
module ${module_name} (
    CLK,
% if has_reset:
    RST_N,
% endif
% for i in range(num_ports):
    read_${i},
    write_${i},
 % if i == num_ports-1:
    EN_write_${i}
 % else:
    EN_write_${i},
 % endif
% endfor
);
    parameter            DATA_SZ = 1;
    parameter            RESET_VAL = 0;

    input                CLK;
% if has_reset:
    input                RST_N;
% endif
% for i in range(num_ports):
    output [DATA_SZ-1:0] read_${i};
    input  [DATA_SZ-1:0] write_${i};
    input                EN_write_${i};
% endfor

    reg    [DATA_SZ-1:0] r;
% for i in range(num_ports+1):
    wire   [DATA_SZ-1:0] wire_${i};
% endfor

    assign wire_0 = r;
% for i in range(num_ports):
    assign wire_${i+1} = EN_write_${i} ? write_${i} : wire_${i};
% endfor

% for i in range(num_ports):
    assign read_${i} = wire_${i};
% endfor

    always @(posedge CLK) begin
% if has_reset:
        if (RST_N == 0) begin
            r <= RESET_VAL;
        end else begin
            r <= wire_${num_ports};
        end
% else:
        r <= wire_${num_ports};
% endif
    end
endmodule
