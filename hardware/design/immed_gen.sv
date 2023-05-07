`include "types.sv"

module immed_gen (
    input word_t inst,
    output word_t immed
);
    always_comb begin
        case (inst[6:0])
            // I-type
            ISA_OPCODE_LOAD, ISA_OPCODE_OP_IMMED, ISA_OPCODE_JALR:
                immed = {20'b0, inst[31:20]};

            // S-type
            ISA_OPCODE_STORE:
                immed = {20'b0, inst[31:25], inst[11:7]};

            // B-type
            ISA_OPCODE_BRANCH:
                immed = {19'b0, inst[31], inst[7], inst[30:25],
                    inst[11:8], 1'b0};

            // U-type
            ISA_OPCODE_LUI:
                immed = {12'b0, inst[31:12]};

            // J-type
            ISA_OPCODE_JAL:
                immed = {12'b0, inst[31], inst[30:21], inst[20], inst[19:12]};

            default:
                immed = 0;
        endcase
    end
endmodule