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
            ALU_OP_ADD:
                out = sa + sb;
            ALU_OP_SUB:
                out = sa - sb;
            ALU_OP_SLL:
                out = a << b[4:0];
            ALU_OP_SRL:
                out = a >> b[4:0];
            ALU_OP_SRA:
                out = sa >>> sb[4:0];
            ALU_OP_SEQ:
                out = {31'b0, a == b};
            ALU_OP_SLT:
                out = {31'b0, sa < sb};
            ALU_OP_SLTU:
                out = {31'b0, a < b};
            ALU_OP_XOR:
                out = a ^ b;
            ALU_OP_OR:
                out = a | b;
            ALU_OP_AND:
                out = a & b;
            default:
                out = 0;
        endcase        
    end
endmodule