`include "types.sv"

/* verilator lint_off UNUSED */

module alu_ctrl_gen(
    input word_t inst,
    output word_t alu_ctrl
);
    always_comb begin
        case (inst[6:0])
            ISA_OPCODE_BRANCH: begin
                case (inst[14:12])
                    ISA_BRANCH_F3_BEQ: begin
                        alu_ctrl = ALU_CTRL_SEQ;
                    end
                    ISA_BRANCH_F3_BNE: begin
                        alu_ctrl = ALU_CTRL_SNE;
                    end
                    ISA_BRANCH_F3_BLT: begin
                        alu_ctrl = ALU_CTRL_SLT;
                    end
                    ISA_BRANCH_F3_BGE: begin
                        alu_ctrl = ALU_CTRL_SGE;
                    end
                    ISA_BRANCH_F3_BLTU: begin
                        alu_ctrl = ALU_CTRL_SLTU;
                    end
                    ISA_BRANCH_F3_BGEU: begin
                        alu_ctrl = ALU_CTRL_SGEU;
                    end
                    default: begin
                        alu_ctrl = 0;
                    end
                endcase
            end
            ISA_OPCODE_OP, ISA_OPCODE_OP_IMMED: begin
                case (inst[14:12])      
                    ISA_ALU_F3_ADD: begin
                        if (
                            (inst[6:0] == ISA_OPCODE_OP_IMMED) |
                            (inst[30] == 0)
                        ) begin
                            alu_ctrl = ALU_CTRL_ADD;
                        end
                        else begin
                            alu_ctrl = ALU_CTRL_SUB;
                        end
                    end
                    ISA_ALU_F3_SL: begin
                        alu_ctrl = ALU_CTRL_SLL;
                    end
                    ISA_ALU_F3_SLT: begin
                        alu_ctrl = ALU_CTRL_SLT;
                    end
                    ISA_ALU_F3_SLTU: begin
                        alu_ctrl = ALU_CTRL_SLTU;
                    end
                    ISA_ALU_F3_XOR: begin
                        alu_ctrl = ALU_CTRL_XOR;
                    end
                    ISA_ALU_F3_SR: begin
                        if(inst[30]) alu_ctrl = ALU_CTRL_SRA;
                        alu_ctrl = ALU_CTRL_SRL;
                    end
                    ISA_ALU_F3_OR: begin
                        alu_ctrl = ALU_CTRL_OR;
                    end
                    ISA_ALU_F3_AND: begin
                        alu_ctrl = ALU_CTRL_AND;
                    end
                    default: begin
                        alu_ctrl = 0;
                    end
                endcase
            end
            default: begin
                alu_ctrl = 0;
            end
        endcase
    end;
endmodule