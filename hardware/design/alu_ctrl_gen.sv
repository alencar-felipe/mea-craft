`include "types.sv"

/* verilator lint_off UNUSED */

module alu_ctrl_gen(
    input word_t inst,
    output word_t alu_ctrl
);

    always_comb begin
        case (inst[6:0])
            ISA_OPCODE_BRANCH: case (inst[14:12])
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
            
            ISA_OPCODE_OP,
            ISA_OPCODE_OP_IMMED: case (inst[14:12])      
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
                    if(inst[30]) begin
                        alu_ctrl = ALU_CTRL_SRA;
                    end
                    else begin
                        alu_ctrl = ALU_CTRL_SRL;
                    end
                end
                
                ISA_ALU_F3_OR: begin
                    alu_ctrl = ALU_CTRL_OR;
                end
                
                ISA_ALU_F3_AND: begin
                    alu_ctrl = ALU_CTRL_AND;
                end

                default: begin
                    alu_ctrl = ALU_CTRL_PASS;
                end
            endcase

            ISA_OPCODE_MISC: case(inst[14:12])
                ISA_MISC_F3_CSRRW,
                ISA_MISC_F3_CSRRWI: begin
                    alu_ctrl = ALU_CTRL_PASS;
                end

                ISA_MISC_F3_CSRRS,
                ISA_MISC_F3_CSRRSI: begin
                    alu_ctrl = ALU_CTRL_OR;
                end

                ISA_MISC_F3_CSRRC,
                ISA_MISC_F3_CSRRCI: begin
                    alu_ctrl = ALU_CTRL_CLR;
                end

                default: begin
                    alu_ctrl = ALU_CTRL_PASS;
                end
            endcase

            default: begin
                alu_ctrl = ALU_CTRL_PASS;
            end
        endcase
    end;

endmodule