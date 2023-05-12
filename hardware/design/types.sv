
`ifndef TYPES_SV
`define TYPES_SV

/* ISA Typedefs */

typedef logic [31:0] word_t;
typedef logic [4:0] reg_addr_t;
typedef logic [2:0] f3_t;
typedef logic [11:0] csr_addr_t;

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
    ISA_OPCODE_MISC     = 7'b1110011
} isa_opcode_t;    

typedef enum word_t {
    ISA_NULLARY_BREAK   = 32'h00100073,
    ISA_NULLARY_MRET    = 32'h30200073
} isa_nullary_t;

typedef enum f3_t {
    ISA_BRANCH_F3_BEQ   = 3'b000,
    ISA_BRANCH_F3_BNE   = 3'b001,
    ISA_BRANCH_F3_BLT   = 3'b100,
    ISA_BRANCH_F3_BGE   = 3'b101,
    ISA_BRANCH_F3_BLTU  = 3'b110,
    ISA_BRANCH_F3_BGEU  = 3'b111
} isa_branch_f3_t;

typedef enum f3_t {
    ISA_ALU_F3_ADD  = 3'b000,
    ISA_ALU_F3_SL   = 3'b001, // shift left
    ISA_ALU_F3_SLT  = 3'b010, // set less than
    ISA_ALU_F3_SLTU = 3'b011, // set less than unsigned
    ISA_ALU_F3_XOR  = 3'b100,
    ISA_ALU_F3_SR   = 3'b101, // shift right
    ISA_ALU_F3_OR   = 3'b110,
    ISA_ALU_F3_AND  = 3'b111
} isa_alu_f3_t;

typedef enum f3_t {
    ISA_MEM_F3_BYTE     = 3'b000, // byte
    ISA_MEM_F3_HALF     = 3'b001, // half word
    ISA_MEM_F3_WORD     = 3'b010, // word
    ISA_MEM_F3_BYTE_U   = 3'b100, // unsigned byte
    ISA_MEM_F3_HALF_U   = 3'b101  // unsigned half word
} isa_mem_f3_t;

typedef enum f3_t {
    ISA_MISC_F3_CSRRW   = 3'b001,
    ISA_MISC_F3_CSRRS   = 3'b010,
    ISA_MISC_F3_CSRRC   = 3'b011,
    ISA_MISC_F3_CSRRWI  = 3'b101,
    ISA_MISC_F3_CSRRSI  = 3'b110,
    ISA_MISC_F3_CSRRCI  = 3'b111 
} isa_misc_f3_t;

typedef enum csr_addr_t {
    ISA_CSR_ADDR_MSTATUS    = 12'h0300,
    ISA_CSR_ADDR_MIE        = 12'h0304,
    ISA_CSR_ADDR_MTVEC      = 12'h0305,     
    ISA_CSR_ADDR_MSCRATCH   = 12'h0340,
    ISA_CSR_ADDR_MEPC       = 12'h0341,  
    ISA_CSR_ADDR_MCAUSE     = 12'h0342,
    ISA_CSR_ADDR_MHARTID    = 12'h0F14
} isa_csr_addr_t;

typedef enum logic[1:0] {
    ISA_LEVEL_M = 2'b11 // machine
} isa_level_t;

typedef enum word_t {
    ISA_MCAUSE_M_EXT_INT  = 32'h8000000b // machine external interrupt
} isa_mcause_t;

/* Implementation Specifc Typedefs */

typedef word_t [2:0] unit_in_t;
typedef word_t unit_out_t;

typedef enum word_t {
    ALU_CTRL_PASS,      // passthrough
    ALU_CTRL_ADD,       // addition
    ALU_CTRL_SUB,       // subration
    ALU_CTRL_SLL,       // shift left logical
    ALU_CTRL_SRL,       // shift right logical
    ALU_CTRL_SRA,       // shift right arithmetical
    ALU_CTRL_SEQ,       // set equal
    ALU_CTRL_SNE,       // set not equal
    ALU_CTRL_SLT,       // set less than
    ALU_CTRL_SGE,       // set greater than
    ALU_CTRL_SLTU,      // set less than unsigned
    ALU_CTRL_SGEU,      // set greater than unsigned
    ALU_CTRL_XOR,       // xor
    ALU_CTRL_OR,        // or
    ALU_CTRL_AND,       // and
    ALU_CTRL_CLR        // clear       
} alu_ctrl_t;

typedef enum word_t {
    MEM_CTRL_READ_BYTE,
    MEM_CTRL_READ_HALF,
    MEM_CTRL_READ_WORD,
    MEM_CTRL_STORE_BYTE,
    MEM_CTRL_STORE_HALF,
    MEM_CTRL_STORE_WORD
} mem_ctrl_t;

typedef enum {
    UNIT_SEL_NONE,
    UNIT_SEL_ALU,
    UNIT_SEL_MEM
} unit_sel_t;

`endif
