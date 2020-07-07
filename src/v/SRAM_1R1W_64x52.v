module SRAM_1R1W_64x52 (
    input clk,
    input write_en,
    input [5:0] write_addr,
    input [51:0] write_data,
    input read_en,
    input [5:0] read_addr,
    output [51:0] read_data
);

    MBHA_NSNL_IN22FDX_R2PV_NFKG_W00064B052M02C128 generated_sram_64x52(
        .clkA(clk),
        .clkB(clk),
        .cenA(1'b0),
        .cenB(1'b0),
        .deepsleep(1'b0),
        .powergate(1'b0),
        .aA(read_addr),
        .aB(write_addr),
        .d(write_data),
        .bw({52{write_en}}),
        .q(read_data),
        .pqEn(1'b0)
        );
endmodule
