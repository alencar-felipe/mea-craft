`include "types.sv"

module thread (
    input clk,
    input rst,

    output unit_sel_t unit_sel,
    output ctrl_t unit_ctrl,
    output word_t unit_in [1:0],
    input word_t unit_out,
    input logic unit_ready
);

    typedef struct packed {
        logic [4:0] ic;
        word_t pc;
        word_t inst;
    } state_t;

    typedef enum {
        STEP_FETCH,
        STEP_LUI,
        STEP_AUIPC,
        STEP_JAL,
        STEP_BRANCH,
        STEP_JUMP,
        STEP_JUMP_REG,
        STEP_OP,
        STEP_OP_IMMED,
        STEP_INC_PC,
        STEP_BREAK
    } step_t;

    state_t curr;
    state_t next;
    step_t step;

    logic write_en;
    reg_addr_t rd_addr;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t rd_data;

    word_t alu_ctrl;

    word_t immed;

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

    immed_gen immed_gen_0 (
        .inst (curr.inst),
        .immed (immed)
    );

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            curr <= '{ic: 0, pc: 0, inst: 0};
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
        
        unit_sel = UNIT_SEL_NONE;
        unit_ctrl = 0;
        unit_in = '{0, 0};

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
                unit_ctrl = MEM_CTRL_READ;
                unit_in[0] = curr.pc;
                unit_in[1] = 0;
            end

            STEP_LUI: begin
                write_en = 1;
                rd_addr = curr.inst[11:7];
                rd_data = immed;
            end

            STEP_AUIPC: begin
                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = curr.pc;
                unit_in[1] = immed;

                write_en = 1;
                rd_addr = curr.inst[11:7];
                rd_data = unit_out;
            end

            STEP_JAL: begin
                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = curr.pc;
                unit_in[1] = 4;

                write_en = 1;
                rd_addr = curr.inst[11:7];
                rd_data = unit_out;
            end

            STEP_BRANCH: begin
                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = alu_ctrl;
                unit_in[0] = rs1_data;
                unit_in[1] = rs2_data;

                rs1_addr = curr.inst[19:15];
                rs2_addr = curr.inst[24:20];

                if (unit_out[0] == 0) begin
                    next.ic = curr.ic + 2; // skip jump
                end
            end

            STEP_JUMP: begin
                next.ic = 0; 
                next.pc = unit_out;

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = curr.pc;
                unit_in[1] = immed;
            end

            STEP_JUMP_REG: begin
                next.ic = 0; 
                next.pc = {unit_out[31:1], 1'b0};

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = rs1_data;
                unit_in[1] = immed;

                rs1_addr = curr.inst[19:15];
            end
            
            STEP_OP: begin
                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = alu_ctrl;
                unit_in[0] = rs1_data;
                unit_in[1] = rs2_data;

                write_en = 1;
                rd_addr = curr.inst[11:7];
                rs1_addr = curr.inst[19:15];
                rs2_addr = curr.inst[24:20];
                rd_data = unit_out;
            end

            STEP_OP_IMMED: begin
                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = alu_ctrl;
                unit_in[0] = rs1_data;
                unit_in[1] = immed;

                write_en = 1;
                rd_addr = curr.inst[11:7];
                rs1_addr = curr.inst[19:15];
                rd_data = unit_out;
            end

            STEP_INC_PC: begin
                next.pc = unit_out;

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = curr.pc;
                unit_in[1] = 4;
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