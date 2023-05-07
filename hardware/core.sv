`include "types.sv"

module core (
    input clk,
    input rst,
    input word_t dout,
    output word_t din,
    output word_t addr,
    output write_en
);
    unit_sel_t unit_sel;
    word_t unit_ctrl;
    word_t unit_in [1:0];
    word_t unit_out;

    word_t alu_ctrl;
    word_t alu_out;

    thread thread_0 (
        .clk (clk),
        .rst (rst),
        .unit_sel (unit_sel),
        .unit_ctrl (unit_ctrl),
        .unit_in (unit_in),
        .unit_out (unit_out)
    );

    alu alu_0 (
        .ctrl (alu_ctrl),
        .in (unit_in),
        .out (alu_out) 
    );

    assign addr = unit_in[0];
    assign din = unit_in[1];

    always_comb begin
        case(unit_sel)
            UNIT_SEL_ALU: begin
                alu_ctrl = unit_ctrl;
                write_en = 0;

                unit_out = alu_out;
            end

            UNIT_SEL_MEM: begin
                alu_ctrl = 0;
                write_en = unit_ctrl[0];

                unit_out = dout;
            end

            default: begin
                alu_ctrl = 0;
                write_en = 0;

                unit_out = 0;
            end
        endcase
    end    
endmodule