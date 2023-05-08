`include "types.sv"

module immed_gen (
    input word_t inst,
    output word_t immed
);
    sext_width_t width;
    word_t sext_in;

    sext sext_0 (
        .width (width),
        .in (sext_in),
        .out (immed)
    );

    always_comb begin
        case (inst[6:0])
            // I-type
            ISA_OPCODE_LOAD, ISA_OPCODE_OP_IMMED, ISA_OPCODE_JALR: begin
                width = SEXT_WIDTH_12;
                sext_in = {20'b0, inst[31:20]};
            end

            // S-type
            ISA_OPCODE_STORE: begin
                width = SEXT_WIDTH_12;
                sext_in = {20'b0, inst[31:25], inst[11:7]};
            end

            // B-type
            ISA_OPCODE_BRANCH: begin
                width = SEXT_WIDTH_12;
                sext_in = {19'b0, inst[31], inst[7], inst[30:25],
                    inst[11:8], 1'b0};
            end

            // U-type
            ISA_OPCODE_LUI, ISA_OPCODE_AUIPC: begin
                width = SEXT_WIDTH_32;
                sext_in = {inst[31:12], 12'b0};
            end

            // J-type
            ISA_OPCODE_JAL: begin
                width = SEXT_WIDTH_20;
                sext_in = {12'b0, inst[31], inst[30:21], inst[20], inst[19:12]};
            end

            default: begin
                width = SEXT_WIDTH_32;
                sext_in = 0;
            end
        endcase
    end
endmodule