`include "types.sv"

module core (
    input clk,
    input rst,
    input word_t dout,
    output word_t din,
    output word_t addr,
    output logic write_en
);
    unit_sel_t unit_sel;
    ctrl_t unit_ctrl;
    word_t unit_in [1:0];
    word_t unit_out;
    logic unit_ready;

    alu_ctrl_t alu_ctrl;
    word_t alu_out;

    logic mem_ready;

    thread thread_0 (
        .clk (clk),
        .rst (rst),
        .unit_sel (unit_sel),
        .unit_ctrl (unit_ctrl),
        .unit_in (unit_in),
        .unit_out (unit_out),
        .unit_ready (unit_ready)
    );

    alu alu_0 (
        .ctrl (alu_ctrl),
        .in (unit_in),
        .out (alu_out) 
    );  

    assign alu_ctrl = unit_ctrl.alu;

    assign addr = unit_in[0];
    assign din = unit_in[1];

    always_comb begin
        case(unit_sel)
            UNIT_SEL_ALU: begin
                write_en = 0;
                unit_out = alu_out;
                unit_ready = 1;
            end

            UNIT_SEL_MEM: begin
                write_en = unit_ctrl[0];
                unit_out = dout;
                unit_ready = mem_ready;
            end

            default: begin
                write_en = 0;
                unit_out = 0;
                unit_ready = 1;
            end
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst | unit_sel != UNIT_SEL_MEM) begin
            mem_ready <= 0;
        end
        else begin
            mem_ready <= 1;
        end
    end

endmodule