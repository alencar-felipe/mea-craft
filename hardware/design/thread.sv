`include "types.sv"

/* verilator lint_off UNUSED */

module thread (
    input logic clk,
    input logic rst,
    input logic irq,
    input logic unit_ready,
    input unit_out_t unit_out,
    output unit_in_t unit_in,
    output unit_sel_t unit_sel
);

    typedef struct packed {
        logic [4:0] ic;
        word_t pc;
        word_t inst;
        logic irq_now;
        word_t tmp;
    } state_t;

    typedef enum {
        STEP_FETCH,
        STEP_LUI,
        STEP_AUIPC,
        STEP_JAL,
        STEP_BRANCH,
        STEP_JUMP,
        STEP_JUMP_REG,
        STEP_CALC_ADDR,
        STEP_LOAD,
        STEP_STORE,
        STEP_OP,
        STEP_OP_IMMED,
        STEP_INC_PC,
        STEP_BREAK,
        STEP_CSR,
        STEP_CSR_IMMED,
        STEP_IRQ_MSTATUS,
        STEP_IRQ_MCAUSE,
        STEP_IRQ_MEPC,
        STEP_IRQ_JUMP,
        STEP_MRET_MSTATUS,
        STEP_MRET_JUMP
    } step_t;

    state_t curr;
    state_t next;
    step_t step;

    reg_addr_t isa_rd;
    reg_addr_t isa_rs1;   
    reg_addr_t isa_rs2; 
    logic [2:0] isa_f3;
    csr_addr_t isa_csr;
    
    logic reg_wen;
    reg_addr_t rd_addr;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t rd_data;

    logic csr_wen;
    csr_addr_t csr_addr;
    word_t csr_din;
    word_t csr_dout;
    word_t mstatus;

    word_t alu_ctrl;
    word_t mem_ctrl;
    word_t immed;

    assign isa_rd = curr.inst[11:7];
    assign isa_rs1 = curr.inst[19:15];
    assign isa_rs2 = curr.inst[24:20]; 
    assign isa_f3 = curr.inst[14:12];
    assign isa_csr = curr.inst[31:20];

    reg_file reg_file_0 (
        .clk (clk),
        .rst (rst),
        .write_en (reg_wen),
        .rd_addr (rd_addr),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_data (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    csr_file csr_file_0 (
        .clk (clk),
        .rst (rst),
        .write_en (csr_wen),
        .addr (csr_addr),
        .din (csr_din),
        .dout (csr_dout),
        .mstatus (mstatus)
    );

    alu_ctrl_gen alu_ctrl_gen_0 (
        .inst (curr.inst),
        .alu_ctrl (alu_ctrl)
    );

    mem_ctrl_gen mem_ctrl_gen_0 (
        .inst (curr.inst),
        .mem_ctrl (mem_ctrl)
    );

    immed_gen immed_gen_0 (
        .inst (curr.inst),
        .immed (immed)
    );

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            curr.ic <= 0;
            curr.pc <= 0;
            curr.inst <= 0;
            curr.irq_now <= 0;
            curr.tmp <= 0;
        end
        else if (unit_ready) begin
            curr <= next;
        end
    end

    always_comb begin

        /* First, set everything to the default value. */
        
        next.ic = curr.ic + 1;
        next.pc = curr.pc;
        next.inst = curr.inst;
        next.irq_now = curr.irq_now;
        next.tmp = 0;

        unit_sel = UNIT_SEL_NONE;
        unit_in = '{0, 0, 0};

        reg_wen = 0;
        rd_addr = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_data = 0;

        csr_wen = 0;
        csr_addr = 0;
        csr_din = 0;

        /* Now, make changes as required on a case-by-case basis. */

        case (step)
            STEP_FETCH: begin
                unit_sel = UNIT_SEL_MEM;
                unit_in[0] = MEM_CTRL_READ_WORD;
                unit_in[1] = curr.pc;
                unit_in[2] = 0;

                csr_addr = ISA_CSR_ADDR_MIE;

                if (irq & mstatus[3] & csr_dout[11]) begin
                   next.ic = 0;
                   next.irq_now = 1;
                end
                else begin
                    next.ic = 1; 
                    next.inst = unit_out;
                end
            end

            STEP_LUI: begin
                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = immed;
            end

            STEP_AUIPC: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = immed;

                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = unit_out;
            end

            STEP_JAL: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = 4;

                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = unit_out;
            end

            STEP_BRANCH: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = alu_ctrl;
                unit_in[1] = rs1_data;
                unit_in[2] = rs2_data;

                rs1_addr = isa_rs1;
                rs2_addr = isa_rs2;

                if (unit_out[0] == 0) begin
                    next.ic = curr.ic + 2; // skip jump
                end
            end

            STEP_JUMP: begin
                next.ic = 0; 
                next.pc = unit_out;

                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = immed;
            end

            STEP_JUMP_REG: begin
                next.ic = 0; 
                next.pc = {unit_out[31:1], 1'b0};

                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = rs1_data;
                unit_in[2] = immed;

                rs1_addr = isa_rs1;
            end

            STEP_CALC_ADDR: begin
                next.tmp = unit_out;

                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = rs1_data;
                unit_in[2] = immed; 

                rs1_addr = isa_rs1;
            end
            
            STEP_LOAD: begin                
                unit_sel = UNIT_SEL_MEM;
                unit_in[0] = mem_ctrl;
                unit_in[1] = curr.tmp;
                unit_in[2] = 0;

                reg_wen = 1;
                rd_addr = isa_rd;

                case (isa_f3)
                    ISA_MEM_F3_BYTE:
                        rd_data = { {24{unit_out[7]}} , unit_out[7:0] };
                    ISA_MEM_F3_HALF:
                        rd_data = { {16{unit_out[15]}} , unit_out[15:0] };
                    default:
                        rd_data = unit_out;
                endcase                
            end

            STEP_STORE: begin
                unit_sel = UNIT_SEL_MEM;
                unit_in[0] = mem_ctrl;
                unit_in[1] = curr.tmp;
                unit_in[2] = rs2_data;

                rs2_addr = isa_rs2;
            end
            
            STEP_OP: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = alu_ctrl;
                unit_in[1] = rs1_data;
                unit_in[2] = rs2_data;

                reg_wen = 1;
                rd_addr = isa_rd;
                rs1_addr = isa_rs1;
                rs2_addr = isa_rs2;
                rd_data = unit_out;
            end

            STEP_OP_IMMED: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = alu_ctrl;
                unit_in[1] = rs1_data;
                unit_in[2] = immed;

                reg_wen = 1;
                rd_addr = isa_rd;
                rs1_addr = isa_rs1;
                rd_data = unit_out;
            end

            STEP_INC_PC: begin
                next.pc = unit_out;

                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = 4;
            end

            STEP_BREAK: begin
                next.ic = curr.ic;
            end

            STEP_CSR: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = alu_ctrl;
                unit_in[1] = rs1_data;
                unit_in[2] = csr_dout;

                reg_wen = 1;
                rs1_addr = isa_rs1;
                rd_addr = isa_rd;
                rd_data = csr_dout;

                csr_wen = 1;
                csr_addr = isa_csr;
                csr_din = unit_out;
            end

            STEP_CSR_IMMED: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = alu_ctrl;
                unit_in[1] = {27'b0, isa_rs1};
                unit_in[2] = csr_dout;

                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = csr_dout;

                csr_wen = 1;
                csr_addr = isa_csr;
                csr_din = unit_out;
            end
            
            STEP_IRQ_MSTATUS: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MSTATUS;
                csr_din = csr_dout;
                csr_din[3] = 0;                 // MIE <= 0
                csr_din[7] = 1;                 // MPIE <= 1
                csr_din[12:11] = ISA_LEVEL_M;   // MPP <= M
            end

            STEP_IRQ_MCAUSE: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MCAUSE;
                csr_din = ISA_MCAUSE_M_EXT_INT;
            end

            STEP_IRQ_MEPC: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MEPC;
                csr_din = curr.pc;
            end

            STEP_IRQ_JUMP: begin
                next.ic = 0;
                next.pc = {csr_dout[31:4], 4'b0000};
                next.irq_now = 0;

                csr_addr = ISA_CSR_ADDR_MTVEC;
            end

            STEP_MRET_MSTATUS: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MSTATUS;
                csr_din = csr_dout;
                csr_din[3] = csr_dout[7];    // MIE <= MPIE
                csr_din[7] = 1;             // MPIE <= 1
                csr_din[12:11] = ISA_LEVEL_M;   // MPP <= M
            end

            STEP_MRET_JUMP: begin
                next.ic = 0;
                next.pc = csr_dout;

                csr_addr = ISA_CSR_ADDR_MEPC;
            end
        endcase
    end

    always_comb begin
        if (curr.irq_now) case (curr.ic)
            default: step               = STEP_IRQ_MSTATUS                     ;
            1: step                     = STEP_IRQ_MCAUSE                      ;
            2: step                     = STEP_IRQ_MEPC                        ;
            3: step                     = STEP_IRQ_JUMP                        ;
        endcase
        else case (curr.inst)
            ISA_NULLARY_BREAK: case (curr.ic)
                default: step           = STEP_FETCH                           ;
                1: step                 = STEP_BREAK                           ;
            endcase
            
            ISA_NULLARY_MRET: case (curr.ic)
                default: step           = STEP_FETCH                           ;
                1: step                 = STEP_MRET_MSTATUS                    ;
                2: step                 = STEP_MRET_JUMP                       ;
            endcase

            default: case (curr.inst[6:0])
                ISA_OPCODE_LUI: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_LUI                             ;
                    2: step             = STEP_INC_PC                          ;
                endcase
                
                ISA_OPCODE_AUIPC: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_AUIPC                           ;
                    2: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_JAL: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_JAL                             ;
                    2: step             = STEP_JUMP                            ;
                    3: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_JALR: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_JAL                             ;
                    2: step             = STEP_JUMP_REG                        ;
                    3: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_BRANCH: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_BRANCH                          ;
                    2: step             = STEP_JUMP                            ;
                    3: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_LOAD: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_CALC_ADDR                       ;
                    2: step             = STEP_LOAD                            ;
                    3: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_STORE: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_CALC_ADDR                       ;
                    2: step             = STEP_STORE                           ;
                    3: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_OP: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_OP                              ;
                    2: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_OP_IMMED: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_OP_IMMED                        ;
                    2: step             = STEP_INC_PC                          ;
                endcase

                ISA_OPCODE_MISC: case (isa_f3)
                    ISA_MISC_F3_CSRRW,
                    ISA_MISC_F3_CSRRS,
                    ISA_MISC_F3_CSRRC: case (curr.ic)
                        default: step   = STEP_FETCH                           ;
                        1: step         = STEP_CSR                             ;
                        2: step         = STEP_INC_PC                          ;
                    endcase

                    ISA_MISC_F3_CSRRWI,
                    ISA_MISC_F3_CSRRSI,
                    ISA_MISC_F3_CSRRCI: case (curr.ic)
                        default: step   = STEP_FETCH                           ;
                        1: step         = STEP_CSR_IMMED                       ;
                        2: step         = STEP_INC_PC                          ;
                    endcase

                    default: case (curr.ic)
                        default: step   = STEP_FETCH                           ;
                        1: step         = STEP_BREAK                           ;
                    endcase
                endcase 

                default: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_BREAK                           ;
                endcase
            endcase
        endcase   
    end
endmodule