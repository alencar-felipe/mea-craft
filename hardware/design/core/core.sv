`include "types.sv"

/* verilator lint_off UNUSED */

module core #(
    parameter word_t MHARTID = 0
) (
    input logic clk,
    input logic rst,
    input logic irq,

    /* AXIL Interface */

    output logic [31: 0] awaddr,
    output logic [ 2: 0] awprot,
    output logic         awvalid,
    input  logic         awready,
    output logic [31: 0] wdata,
    output logic [ 3: 0] wstrb,
    output logic         wvalid,
    input  logic         wready,
    input  logic [ 1: 0] bresp,
    input  logic         bvalid,
    output logic         bready,
    output logic [31: 0] araddr,
    output logic [ 2: 0] arprot,
    output logic         arvalid,
    input  logic         arready,
    input  logic [31: 0] rdata,
    input  logic [ 1: 0] rresp,
    input  logic         rvalid,
    output logic         rready
);
    typedef struct packed {
        logic [3:0] ic;
        word_t pc;
        word_t inst;
        logic irq_now;
        word_t tmp;

        logic mem_addr_ok;
        logic mem_data_ok;
    } state_t;

    typedef enum {
        STEP_FETCH,
        STEP_LUI,
        STEP_AUIPC,
        STEP_JAL,
        STEP_BRANCH,
        STEP_JUMP,
        STEP_JARL_JUMP,
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

    alu_ctrl_t inst_alu_ctrl;
    mem_ctrl_t inst_mem_ctrl;
    word_t immed;

    alu_ctrl_t alu_ctrl;
    word_t alu_in [1:0];
    word_t alu_out;

    logic reg_wen;
    reg_addr_t rd_addr;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t rd_data;

    logic csr_wen;
    csr_addr_t csr_addr;
    word_t csr_in;
    word_t csr_out;
    word_t mstatus;

    mem_ctrl_t mem_ctrl;
    word_t mem_addr;
    word_t mem_in;
    word_t mem_out;
    logic mem_done;

    assign isa_rd = curr.inst[11:7];
    assign isa_rs1 = curr.inst[19:15];
    assign isa_rs2 = curr.inst[24:20]; 
    assign isa_f3 = curr.inst[14:12];
    assign isa_csr = curr.inst[31:20];

    alu alu (
        .ctrl (alu_ctrl),
        .in (alu_in),
        .out (alu_out)
    );

    reg_file reg_file (
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

    csr_file #(
        .MHARTID (MHARTID)
    ) csr_file (
        .clk (clk),
        .rst (rst),
        .write_en (csr_wen),
        .addr (csr_addr),
        .in (csr_in),
        .out (csr_out),
        .mstatus (mstatus)
    );

    mem_ctrl_gen mem_ctrl_gen (
        .inst (curr.inst),
        .mem_ctrl (inst_mem_ctrl)
    );

    alu_ctrl_gen alu_ctrl_gen (
        .inst (curr.inst),
        .alu_ctrl (inst_alu_ctrl)
    );

    immed_gen immed_gen (
        .inst (curr.inst),
        .immed (immed)
    );

    always_ff @(posedge clk) begin
        if(rst) begin
            curr.ic <= 0;
            curr.pc <= 0;
            curr.inst <= 0;
            curr.irq_now <= 0;
            curr.tmp <= 0;

            curr.mem_addr_ok <= 0;
            curr.mem_data_ok <= 0;
        end
        else if (
            (mem_ctrl == MEM_CTRL_NONE) |
            (mem_done)
        ) begin
            curr <= next;
        end
        else begin
            curr.mem_addr_ok <= next.mem_addr_ok;
            curr.mem_data_ok <= next.mem_data_ok;
        end
    end

    always_comb begin

        /* First, set everything to the default value. */
        
        next.ic = curr.ic + 1;
        next.pc = curr.pc;
        next.inst = curr.inst;
        next.irq_now = curr.irq_now;
        next.tmp = 0;
        
        mem_ctrl = MEM_CTRL_NONE;
        mem_addr = 0;
        mem_in = 0;

        alu_ctrl = ALU_CTRL_PASS;
        alu_in[0] = 0;
        alu_in[1] = 0;

        reg_wen = 0;
        rd_addr = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_data = 0;

        csr_wen = 0;
        csr_addr = 0;
        csr_in = 0;

        /* Now, make changes as required on a case-by-case basis. */

        case (step)
            STEP_FETCH: begin
                mem_ctrl = MEM_CTRL_READ_WORD;
                mem_addr = curr.pc;

                csr_addr = ISA_CSR_ADDR_MIE;

                if (irq & mstatus[3] & csr_out[11]) begin
                   next.ic = 0;
                   next.irq_now = 1;
                end
                else begin
                    next.ic = 1; 
                    next.inst = mem_out;
                end
            end

            STEP_LUI: begin
                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = immed;
            end

            STEP_AUIPC: begin
                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = curr.pc;
                alu_in[1] = immed;

                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = alu_out;
            end

            STEP_JAL: begin
                next.tmp = rs1_data;

                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = curr.pc;
                alu_in[1] = 4;

                reg_wen = 1;
                rd_addr = isa_rd;
                rs1_addr = isa_rs1;
                rd_data = alu_out;
            end

            STEP_BRANCH: begin
                alu_ctrl = inst_alu_ctrl;
                alu_in[0] = rs1_data;
                alu_in[1] = rs2_data;

                rs1_addr = isa_rs1;
                rs2_addr = isa_rs2;

                if (alu_out[0] == 0) begin
                    next.ic = curr.ic + 2; // skip jump
                end
            end

            STEP_JUMP: begin
                next.ic = 0; 
                next.pc = alu_out;

                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = curr.pc;
                alu_in[1] = immed;
            end

            STEP_JARL_JUMP: begin
                next.ic = 0; 
                next.pc = {alu_out[31:1], 1'b0};

                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = curr.tmp;
                alu_in[1] = immed;
            end

            STEP_CALC_ADDR: begin
                next.tmp = alu_out;

                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = rs1_data;
                alu_in[1] = immed; 

                rs1_addr = isa_rs1;
            end
            
            STEP_LOAD: begin             
                mem_ctrl = inst_mem_ctrl;
                mem_addr = curr.tmp;

                reg_wen = 1;
                rd_addr = isa_rd;

                case (isa_f3)
                    ISA_MEM_F3_BYTE:
                        rd_data = { {24{mem_out[7]}} , mem_out[7:0] };
                    ISA_MEM_F3_HALF:
                        rd_data = { {16{mem_out[15]}} , mem_out[15:0] };
                    default:
                        rd_data = mem_out;
                endcase                
            end

            STEP_STORE: begin
                mem_ctrl = inst_mem_ctrl;
                mem_addr = curr.tmp;
                mem_in = rs2_data;

                rs2_addr = isa_rs2;
            end
            
            STEP_OP: begin
                alu_ctrl = inst_alu_ctrl;
                alu_in[0] = rs1_data;
                alu_in[1] = rs2_data;

                reg_wen = 1;
                rd_addr = isa_rd;
                rs1_addr = isa_rs1;
                rs2_addr = isa_rs2;
                rd_data = alu_out;
            end

            STEP_OP_IMMED: begin
                alu_ctrl = inst_alu_ctrl;
                alu_in[0] = rs1_data;
                alu_in[1] = immed;

                reg_wen = 1;
                rd_addr = isa_rd;
                rs1_addr = isa_rs1;
                rd_data = alu_out;
            end

            STEP_INC_PC: begin
                next.pc = alu_out;

                alu_ctrl = ALU_CTRL_ADD;
                alu_in[0] = curr.pc;
                alu_in[1] = 4;
            end

            STEP_BREAK: begin
                next.ic = curr.ic;
            end

            STEP_CSR: begin
                alu_ctrl = inst_alu_ctrl;
                alu_in[0] = rs1_data;
                alu_in[1] = csr_out;

                reg_wen = 1;
                rs1_addr = isa_rs1;
                rd_addr = isa_rd;
                rd_data = csr_out;

                csr_wen = 1;
                csr_addr = isa_csr;
                csr_in = alu_out;
            end

            STEP_CSR_IMMED: begin
                alu_ctrl = inst_alu_ctrl;
                alu_in[0] = {27'b0, isa_rs1};
                alu_in[1] = csr_out;

                reg_wen = 1;
                rd_addr = isa_rd;
                rd_data = csr_out;

                csr_wen = 1;
                csr_addr = isa_csr;
                csr_in = alu_out;
            end
            
            STEP_IRQ_MSTATUS: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MSTATUS;
                csr_in = csr_out;
                csr_in[3] = 0;                 // MIE <= 0
                csr_in[7] = 1;                 // MPIE <= 1
                csr_in[12:11] = ISA_LEVEL_M;   // MPP <= M
            end

            STEP_IRQ_MCAUSE: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MCAUSE;
                csr_in = ISA_MCAUSE_M_EXT_INT;
            end

            STEP_IRQ_MEPC: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MEPC;
                csr_in = curr.pc;
            end

            STEP_IRQ_JUMP: begin
                next.ic = 0;
                next.pc = {csr_out[31:4], 4'b0000};
                next.irq_now = 0;

                csr_addr = ISA_CSR_ADDR_MTVEC;
            end

            STEP_MRET_MSTATUS: begin
                csr_wen = 1;
                csr_addr = ISA_CSR_ADDR_MSTATUS;
                csr_in = csr_out;
                csr_in[3] = csr_out[7];         // MIE <= MPIE
                csr_in[7] = 1;                  // MPIE <= 1
                csr_in[12:11] = ISA_LEVEL_M;    // MPP <= M
            end

            STEP_MRET_JUMP: begin
                next.ic = 0;
                next.pc = csr_out;

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
                endcase

                ISA_OPCODE_JALR: case (curr.ic)
                    default: step       = STEP_FETCH                           ;
                    1: step             = STEP_JAL                             ;
                    2: step             = STEP_JARL_JUMP                       ;
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

    assign awaddr = mem_addr;
    assign awprot = 0;
    assign wdata = mem_in;
    assign bready = 1;
    assign araddr = mem_addr;
    assign arprot = 0;

    always_comb begin
        case (mem_ctrl)
            MEM_CTRL_READ_BYTE: begin                
                mem_out = {24'b0, rdata[7:0]};
            end
                
            MEM_CTRL_READ_HALF: begin
                mem_out = {16'b0, rdata[15:0]};
            end

            MEM_CTRL_READ_WORD: begin
                mem_out = rdata;
            end

            MEM_CTRL_STORE_BYTE: begin
                wstrb = 4'b0001;
            end

            MEM_CTRL_STORE_HALF: begin
                wstrb = 4'b0011;
            end

            MEM_CTRL_STORE_WORD: begin
                wstrb = 4'b1111;
            end

            default: begin
                mem_out = 0;
                wstrb = 0;
            end
        endcase
    end

    always_comb begin
        case (mem_ctrl)
            MEM_CTRL_READ_BYTE,
            MEM_CTRL_READ_HALF,
            MEM_CTRL_READ_WORD: begin
                if (!curr.mem_addr_ok) begin
                    mem_done = 0;

                    next.mem_addr_ok = arready;
                    next.mem_data_ok = 0;

                    arvalid = 1;
                    rready = 0;
                end
                else if (!curr.mem_data_ok) begin
                    mem_done = 0;

                    next.mem_addr_ok = 1;
                    next.mem_data_ok = rvalid;

                    arvalid = 0;
                    rready = 0;
                end
                else begin
                    mem_done = 1;

                    next.mem_addr_ok = 0;
                    next.mem_data_ok = 0;

                    arvalid = 0;
                    rready = 1;
                end

                awvalid = 0;
                wvalid = 0;
            end
            
            MEM_CTRL_STORE_BYTE,
            MEM_CTRL_STORE_HALF,
            MEM_CTRL_STORE_WORD: begin
                if (curr.mem_addr_ok & curr.mem_data_ok) begin
                    mem_done = 1;

                    awvalid = 0;
                    wvalid = 0;

                    next.mem_addr_ok = 0;
                    next.mem_data_ok = 0;
                end
                else begin
                    mem_done = 0;
                    
                    awvalid = !curr.mem_addr_ok;
                    wvalid = (!curr.mem_data_ok);

                    next.mem_addr_ok = curr.mem_addr_ok | awready;
                    next.mem_data_ok = curr.mem_data_ok | wready;
                end

                arvalid = 0;
                rready = 0;
            end

            default: begin
                mem_done = 1;

                next.mem_addr_ok = 0;
                next.mem_data_ok = 0;

                awvalid = 0;
                wvalid = 0;
                arvalid = 0;
                rready = 0;
            end
        endcase 
    end

endmodule