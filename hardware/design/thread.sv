`include "types.sv"

module thread (
    input clk,
    input rst,
    input logic unit_ready,
    input unit_out_t unit_out,
    output unit_in_t unit_in,
    output unit_sel_t unit_sel
);

    typedef struct packed {
        logic [4:0] ic;
        word_t pc;
        word_t inst;
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
        STEP_BREAK
    } step_t;

    state_t curr;
    state_t next;
    step_t step;

    reg_addr_t isa_rd;
    reg_addr_t isa_rs1;   
    reg_addr_t isa_rs2; 
    logic [2:0] isa_f3;

    logic write_en;
    reg_addr_t rd_addr;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t rd_data;

    word_t alu_ctrl;
    word_t mem_ctrl;
    word_t immed;

    assign isa_rd = curr.inst[11:7];
    assign isa_rs1 = curr.inst[19:15];
    assign isa_rs2 = curr.inst[24:20]; 
    assign isa_f3 = curr.inst[14:12];

    reg_file reg_file_0 (
        .clk (clk),
        .write_en (write_en),
        .rd_addr (rd_addr),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_data (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
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
            curr <= '{ic: 0, pc: 0, inst: 0, tmp: 0};
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
        next.tmp = 0;

        unit_sel = UNIT_SEL_NONE;
        unit_in = '{0, 0, 0};

        write_en = 0;
        rd_addr = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_data = 0;

        /* Now, make changes as required on a case-by-case basis. */

        case (step)
            STEP_FETCH: begin
                next.ic = 1; 
                next.inst = unit_out;

                unit_sel = UNIT_SEL_MEM;
                unit_in[0] = MEM_CTRL_READ_WORD;
                unit_in[1] = curr.pc;
                unit_in[2] = 0;
            end

            STEP_LUI: begin
                write_en = 1;
                rd_addr = isa_rd;
                rd_data = immed;
            end

            STEP_AUIPC: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = immed;

                write_en = 1;
                rd_addr = isa_rd;
                rd_data = unit_out;
            end

            STEP_JAL: begin
                unit_sel = UNIT_SEL_ALU;
                unit_in[0] = ALU_CTRL_ADD;
                unit_in[1] = curr.pc;
                unit_in[2] = 4;

                write_en = 1;
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

                write_en = 1;
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

                write_en = 1;
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

                write_en = 1;
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
        endcase
    end

    always_comb begin
        case (curr.inst[6:0])
            ISA_OPCODE_LUI: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_LUI                                 ;
                    2: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_AUIPC: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_AUIPC                               ;
                    2: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_JAL: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_JAL                                 ;
                    2: step         = STEP_JUMP                                ;
                    3: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_JALR: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_JAL                                 ;
                    2: step         = STEP_JUMP_REG                            ;
                    3: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_BRANCH: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_BRANCH                              ;
                    2: step         = STEP_JUMP                                ;
                    3: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_LOAD: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_CALC_ADDR                           ;
                    2: step         = STEP_LOAD                                ;
                    3: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_STORE: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_CALC_ADDR                           ;
                    2: step         = STEP_STORE                               ;
                    3: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_OP: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_OP                                  ;
                    2: step         = STEP_INC_PC                              ;
                endcase
            end
            ISA_OPCODE_OP_IMMED: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_OP_IMMED                            ;
                    2: step         = STEP_INC_PC                              ;
                endcase
            end
            default: begin
                case(curr.ic)
                    default: step   = STEP_FETCH                               ;
                    1: step         = STEP_BREAK                               ;
                endcase
            end
        endcase
    end
endmodule