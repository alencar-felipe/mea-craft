
`ifndef TYPES_SV
`define TYPES_SV

typedef logic [31:0] word_t;
typedef logic [4:0] reg_addr_t;

typedef enum logic [6:0] {
    ISA_OPCODE_LUI      = 7'b0110111,
    ISA_OPCODE_AUIPC    = 7'b0010111,
    ISA_OPCODE_JAL      = 7'b1101111,
    ISA_OPCODE_JALR     = 7'b1100111,
    ISA_OPCODE_BRANCH   = 7'b1100011,
    ISA_OPCODE_LOAD     = 7'b0000011,
    ISA_OPCODE_STORE    = 7'b0100011,
    ISA_OPCODE_OP_IMMED = 7'b0010011,
    ISA_OPCODE_OP       = 7'b0110011,
    ISA_OPCODE_FENCE    = 7'b0001111,
    ISA_OPCODE_ENV      = 7'b1110011
} isa_opcode_t;    

typedef enum logic [2:0] {
    ISA_ALU_F3_ADD  = 3'b000,
    ISA_ALU_F3_SL   = 3'b001, // shift left
    ISA_ALU_F3_SLT  = 3'b010, // set less than
    ISA_ALU_F3_SLTU = 3'b011, // set less than unsigned
    ISA_ALU_F3_XOR  = 3'b100,
    ISA_ALU_F3_SR   = 3'b101, // shift right
    ISA_ALU_F3_OR   = 3'b110,
    ISA_ALU_F3_AND  = 3'b111
} isa_alu_f3_t;

typedef enum word_t {
    ALU_CTRL_ADD,
    ALU_CTRL_SUB,
    ALU_CTRL_SLL,
    ALU_CTRL_SRL,
    ALU_CTRL_SRA,
    ALU_CTRL_SEQ,
    ALU_CTRL_SLT,
    ALU_CTRL_SLTU,
    ALU_CTRL_XOR,
    ALU_CTRL_OR,
    ALU_CTRL_AND
} alu_ctrl_t;

typedef enum word_t {
    RAM_CTRL_READ,
    RAM_CTRL_WRITE
}

typedef enum logic [4:0] {
    SEXT_WIDTH_8 = 7,
    SEXT_WIDTH_12 = 11,
    SEXT_WIDTH_16 = 15,
    SEXT_WIDTH_20 = 19,
    SEXT_WIDTH_32 = 31 
} sext_width_t;

typedef enum {
    THREAD_STATE_FETCH,
    THREAD_STATE_OP,
    THREAD_STATE_OP_IMMED,
    THREAD_STATE_INC_PC
} thread_state_t;

typedef enum {
    UNIT_SEL_ALU,
    UNIT_SEL_RAM
} unit_sel_t;

`endif
