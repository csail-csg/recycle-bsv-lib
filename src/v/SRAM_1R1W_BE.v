// 2 port SRAM (1R1W) with byte enables
module SRAM_1R1W_BE (
    input clk,
    input write_en,
    input [DATA_SZ_BYTES-1:0] write_bytes,
    input [ADDR_SZ-1:0] write_addr,
    input [(DATA_SZ_BYTES*8)-1:0] write_data,
    input read_en,
    input [ADDR_SZ-1:0] read_addr,
    output [(DATA_SZ_BYTES*8)-1:0] read_data
);

    parameter ADDR_SZ = 9;
    parameter DATA_SZ_BYTES = 8;
    parameter MEM_SZ = 512;

    reg [(DATA_SZ_BYTES*8)-1:0] ram_block [MEM_SZ-1:0];
    reg [(DATA_SZ_BYTES*8)-1:0] read_data_reg;

    generate
        genvar i;
        for (i = 0 ; i < DATA_SZ_BYTES ; i = i+1) begin
            always @ (posedge clk) begin
                if (write_en == 1) begin
                    if (write_bytes[i] == 1) begin
                        ram_block[write_addr][(i+1)*8-1:i*8] <= write_data[(i+1)*8-1:i*8];
                    end
                end
                if (read_en == 1) begin
                    read_data_reg[(i+1)*8-1:i*8] <= ram_block[read_addr][(i+1)*8-1:i*8];
                end
            end
        end
    endgenerate

    assign read_data = read_data_reg;
endmodule
