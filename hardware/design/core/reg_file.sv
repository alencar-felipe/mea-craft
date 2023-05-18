`include "types.sv"

module reg_file (
    input logic clk,
    input logic rst,
    input logic write_en,
    input reg_addr_t rd_addr,
    input reg_addr_t rs1_addr,
    input reg_addr_t rs2_addr,
    input word_t rd_data,
    output word_t rs1_data,
    output word_t rs2_data
);
    word_t data [31:0];

    assign rs1_data = data[rs1_addr];
    assign rs2_data = data[rs2_addr];

    initial data[0] = 0;

    always_ff @(posedge clk, posedge rst) begin
        integer i;

        if (rst) begin
            for(i = 0; i <= 31; i++) begin
                data[i] <= 0;
            end
        end
        else if (write_en) begin
            if(rd_addr != 0) data[rd_addr] <= rd_data;
        end
    end
endmodule