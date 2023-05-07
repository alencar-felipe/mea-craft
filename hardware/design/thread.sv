`include "types.sv"

module thread (
    input clk,
    input rst,

    output unit_sel_t unit_sel,
    output word_t unit_ctrl,
    output word_t unit_in [1:0],
    input word_t unit_out
);
    thread_state_t state;
    logic [7:0] ic; // instruction counter
    word_t pc;
    word_t inst;

    thread_state_t next_state;
    logic [7:0] next_ic;
    word_t next_pc;
    word_t next_inst;

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
        .inst (inst),
        .alu_ctrl (alu_ctrl)
    );

    immed_gen immed_gen_0 (
        .inst (inst),
        .immed (immed)
    );

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            ic <= 0;
            pc <= 0;
            inst <= 0;
            state <= THREAD_STATE_FETCH;
        end
        else begin
            ic <= next_ic;
            pc <= next_pc;
            state <= next_state;
            inst <= next_inst;
        end
    end

    always_comb begin
        case (state)
            THREAD_STATE_FETCH: begin
                next_ic = 1; 
                next_pc = pc;
                next_inst = unit_out;

                unit_sel = UNIT_SEL_MEM;
                unit_ctrl = MEM_CTRL_READ;
                unit_in[0] = pc;
                unit_in[1] = 0;

                write_en = 0;
                rd_addr = 0;
                rs1_addr = 0;
                rs2_addr = 0;
                rd_data = 0;
            end

            THREAD_STATE_OP: begin
                next_ic = ic + 1;
                next_pc = pc;
                next_inst = inst;

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = alu_ctrl;
                unit_in[0] = rs1_data;
                unit_in[1] = rs2_data;

                write_en = 1;
                rd_addr = inst[11:7];
                rs1_addr = inst[19:15];
                rs2_addr = inst[24:20];
                rd_data = unit_out;
            end

            THREAD_STATE_OP_IMMED: begin
                next_ic = ic + 1;
                next_pc = pc;
                next_inst = inst;

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = alu_ctrl;
                unit_in[0] = rs1_data;
                unit_in[1] = immed;

                write_en = 1;
                rd_addr = inst[11:7];
                rs1_addr = inst[19:15];
                rs2_addr = 0;
                rd_data = unit_out;
            end

            THREAD_STATE_INC_PC: begin
                next_ic = ic + 1;
                next_pc = unit_out;
                next_inst = inst;

                unit_sel = UNIT_SEL_ALU;
                unit_ctrl = ALU_CTRL_ADD;
                unit_in[0] = pc;
                unit_in[1] = 4;

                write_en = 0;
                rd_addr = 0;
                rs1_addr = 0;
                rs2_addr = 0;
                rd_data = 0; 
            end

            default: begin
                next_ic = ic;
                next_pc = pc;
                next_inst = inst;

                unit_sel = UNIT_SEL_NONE;
                unit_ctrl = 0;
                unit_in[0] = 0;
                unit_in[1] = 0;

                write_en = 0;
                rd_addr = 0;
                rs1_addr = 0;
                rs2_addr = 0;
                rd_data = 0; 
            end
        endcase
    end

    always_comb begin
        case (inst[6:0])
            ISA_OPCODE_OP: begin
                case(next_ic)
                    default: next_state = THREAD_STATE_FETCH                   ;
                    1: next_state       = THREAD_STATE_OP                      ;
                    2: next_state       = THREAD_STATE_INC_PC                  ;
                endcase
            end
            ISA_OPCODE_OP_IMMED: begin
                case(next_ic)
                    default: next_state = THREAD_STATE_FETCH                   ;
                    1: next_state       = THREAD_STATE_OP_IMMED                ;
                    2: next_state       = THREAD_STATE_INC_PC                  ;
                endcase
            end
            default: begin
                case(next_ic)
                    default: next_state = THREAD_STATE_FETCH                   ;
                endcase
            end
        endcase
    end
endmodule