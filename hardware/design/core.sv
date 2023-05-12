`include "types.sv"

module core (
    input logic clk,
    input logic rst,
    input logic irq,
    input word_t mem_dout,
    output word_t mem_din,
    output word_t mem_addr,
    output mem_ctrl_t mem_ctrl
);

    word_t mhartid = 0;

    unit_sel_t unit_sel;
    unit_in_t unit_in;
    unit_out_t unit_out;
    logic unit_ready;

    unit_in_t alu_in;
    unit_out_t alu_out;
    logic alu_ready;

    unit_in_t mem_in;
    unit_out_t mem_out;
    logic mem_ready;

    thread thread_0 (
        .clk (clk),
        .rst (rst),
        .irq (irq),
        .mhartid (mhartid),
        .unit_ready (unit_ready),
        .unit_out (unit_out),
        .unit_in (unit_in),
        .unit_sel (unit_sel)
    );

    alu alu_0 (
        .ctrl (alu_ctrl_t'(alu_in[0])),
        .in ('{alu_in[2], alu_in[1]}),
        .out (alu_out) 
    );  

    assign mem_ctrl = mem_ctrl_t'(mem_in[0]);
    assign mem_addr = mem_in[1];
    assign mem_din = mem_in[2];
    assign mem_out = mem_dout;

    always_comb begin

        /* First, set everything to the default value. */

        unit_ready = 0;
        alu_in = '{0, 0, 0};
        mem_in = '{0, 0, 0};
        
        /* Now, make changes as required on a case-by-case basis. */

        case(unit_sel)
            UNIT_SEL_NONE: begin
                unit_ready = 1;
                unit_out = 0;
                alu_in = '{0, 0, 0};
            end
            UNIT_SEL_ALU: begin
                unit_ready = alu_ready;
                unit_out = alu_out;
                alu_in = unit_in;
            end
            UNIT_SEL_MEM: begin
                unit_ready = mem_ready;
                unit_out = mem_out;
                mem_in = unit_in;
            end
        endcase
    end

    assign alu_ready = 1;

    always_ff @(posedge clk, posedge rst) begin
        if (rst | unit_sel != UNIT_SEL_MEM) begin
            mem_ready <= 0;
        end
        else begin
            mem_ready <= 1;
        end
    end

endmodule