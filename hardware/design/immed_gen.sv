`include "types.sv"

module immed_gen (
    input word_t inst,
    output word_t immed
);

    always_comb begin
        case (inst[6:0])
            // I-type
            ISA_OPCODE_LOAD, ISA_OPCODE_OP_IMMED, ISA_OPCODE_JALR: begin
                immed = {{20{inst[31]}}, inst[31:20]};
            end

            // S-type
            ISA_OPCODE_STORE: begin
                immed = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            // B-type
            ISA_OPCODE_BRANCH: begin
                immed = {{19{inst[31]}}, inst[31], inst[7], inst[30:25],
                    inst[11:8], 1'b0};
            end

            // U-type
            ISA_OPCODE_LUI, ISA_OPCODE_AUIPC: begin
                immed = {inst[31:12], 12'b0};
            end

            // J-type
            ISA_OPCODE_JAL: begin
                immed = {{11{inst[31]}}, inst[31], inst[19:12], inst[20],
                    inst[30:21], 1'b0};
            end

            default: begin
                immed = 0;
            end
        endcase
    end
    
endmodule