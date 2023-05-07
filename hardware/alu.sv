`include "types.sv"

module alu (
    input alu_ctrl_t ctrl,
    input word_t [1:0] in,
    output word_t out
);
    always_comb begin
        word_t a = in[0];
        word_t b = in[1];
        logic signed [31:0] sa = $signed(in[0]);
        logic signed [31:0] sb = $signed(in[1]);
 
        case (ctrl)
            ALU_CTRL_ADD:
                out = sa + sb;
            ALU_CTRL_SUB:
                out = sa - sb;
            ALU_CTRL_SLL:
                out = a << b[4:0];
            ALU_CTRL_SRL:
                out = a >> b[4:0];
            ALU_CTRL_SRA:
                out = sa >>> sb[4:0];
            ALU_CTRL_SEQ:
                out = {31'b0, a == b};
            ALU_CTRL_SLT:
                out = {31'b0, sa < sb};
            ALU_CTRL_SGE:
                out = {31'b0, sa >= sb};
            ALU_CTRL_SLTU:
                out = {31'b0, a < b};
            ALU_CTRL_SGEU:
                out = {31'b0, a >= b};
            ALU_CTRL_XOR:
                out = a ^ b;
            ALU_CTRL_OR:
                out = a | b;
            ALU_CTRL_AND:
                out = a & b;
            default:
                out = 0;
        endcase        
    end
endmodule