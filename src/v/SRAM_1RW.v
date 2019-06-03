// 1 port SRAM
module SRAM_1RW (
    input clk,
    input en,
    input write,
    input [ADDR_SZ-1:0] addr,
    input [DATA_SZ-1:0] write_data,
    output [DATA_SZ-1:0] read_data
);

    parameter ADDR_SZ = 6;
    parameter DATA_SZ = 23;
    parameter MEM_SZ = 64;

    reg [DATA_SZ-1:0] ram_block [MEM_SZ-1:0];
    reg [DATA_SZ-1:0] read_data_reg;

    always @ (posedge clk) begin
        if (en == 1) begin
            if (write == 1) begin
                ram_block[addr] <= write_data;
            end else begin
                read_data_reg <= ram_block[addr];
            end
        end
    end

    assign read_data = read_data_reg;
endmodule
