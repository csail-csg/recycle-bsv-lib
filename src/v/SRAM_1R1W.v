// 2 port SRAM (1R1W)
module SRAM_1R1W (
    input clk,
    input write_en,
    input [ADDR_SZ-1:0] write_addr,
    input [DATA_SZ-1:0] write_data,
    input read_en,
    input [ADDR_SZ-1:0] read_addr,
    output [DATA_SZ-1:0] read_data
);

    parameter ADDR_SZ = 9;
    parameter DATA_SZ = 64;
    parameter MEM_SZ = 512;

    reg [DATA_SZ-1:0] ram_block [MEM_SZ-1:0];
    reg [DATA_SZ-1:0] read_data_reg;

    always @ (posedge clk) begin
        if (write_en == 1) begin
            ram_block[write_addr] <= write_data;
        end
        if (read_en == 1) begin
            read_data_reg <= ram_block[read_addr];
        end
    end

    assign read_data = read_data_reg;
endmodule
