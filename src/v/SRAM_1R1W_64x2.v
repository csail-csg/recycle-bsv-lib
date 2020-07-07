module SRAM_1R1W_64x2 (
    input clk,
    input write_en,
    input [5:0] write_addr,
    input [1:0] write_data,
    input read_en,
    input [5:0] read_addr,
    output [1:0] read_data
);
    wire [3:0]read_data_sram;
    MBHA_NSNL_IN22FDX_R2PV_NFKG_W00064B004M02C128 generated_sram_64x4(
        .clkA(clk),
        .clkB(clk),
        .cenA(1'b0),
        .cenB(1'b0),
        .deepsleep(1'b0),
        .powergate(1'b0),
        .aA(read_addr),
        .aB(write_addr),
        .d({2'b0,write_data}),
        .bw({4{write_en}}),
        .q(read_data_sram),
        .pqEn(1'b0)
        );
    assign read_data = read_data_sram[1:0];
endmodule
