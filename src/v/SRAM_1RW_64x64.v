// 1 port SRAM
module SRAM_1RW_64x64 (
    input clk,
    input en,
    input write,
    input [5:0] addr,
    input [63:0] write_data,
    output [63:0] read_data
);

    sp_l_64x64 sram_64x64(
        .Q (read_data),
        .ADR (addr),
        .D (write_data),
        .WE (write),
        .ME (en),
        .CLK (clk),
        .TEST1 (1'b0),
        .RME (1'b1),
        .RM (4'b0011),
        .WA (2'b01),
        .WPULSE (3'b000),
        .LS (1'b0),
        .BC0 (1'b0),
        .BC1 (1'b0),
        .BC2 (1'b0)
    );
endmodule
