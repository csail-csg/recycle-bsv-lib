// generated by gen_VerilogEHR.py using VerilogEHR.mako

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


module EHR_3 (
    CLK,
    RST_N,
    read_0,
    write_0,
    EN_write_0,
    read_1,
    write_1,
    EN_write_1,
    read_2,
    write_2,
    EN_write_2
);
    parameter            DATA_SZ = 1;
    parameter            RESET_VAL = 0;

    input                CLK;
    input                RST_N;
    output [DATA_SZ-1:0] read_0;
    input  [DATA_SZ-1:0] write_0;
    input                EN_write_0;
    output [DATA_SZ-1:0] read_1;
    input  [DATA_SZ-1:0] write_1;
    input                EN_write_1;
    output [DATA_SZ-1:0] read_2;
    input  [DATA_SZ-1:0] write_2;
    input                EN_write_2;

    reg    [DATA_SZ-1:0] r;
    wire   [DATA_SZ-1:0] wire_0;
    wire   [DATA_SZ-1:0] wire_1;
    wire   [DATA_SZ-1:0] wire_2;
    wire   [DATA_SZ-1:0] wire_3;

    assign wire_0 = r;
    assign wire_1 = EN_write_0 ? write_0 : wire_0;
    assign wire_2 = EN_write_1 ? write_1 : wire_1;
    assign wire_3 = EN_write_2 ? write_2 : wire_2;

    assign read_0 = wire_0;
    assign read_1 = wire_1;
    assign read_2 = wire_2;

    always @(posedge CLK) begin
        if (RST_N == 0) begin
            r <= RESET_VAL;
        end else begin
            r <= wire_3;
        end
    end
endmodule