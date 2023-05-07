`include "types.sv"

module reg_file (
    input clk,
    input write_enable,
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

    always_ff @(posedge clk) begin
        if (write_enable) begin
            if(rd_addr != 0) data[rd_addr] <= rd_data;
        end
    end
endmodule