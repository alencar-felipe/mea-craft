`include "types.sv"

module thread (
    input clk,
    input rst,

    output unit_sel_t unit_sel,
    output word_t unit_contr,
    output word_t unit_in [1:0],
    input word_t unit_out
);
    thread_state_t state;
    logic [7:0] ic; // instruction counter
    word_t pc;
    word_t inst;

    thread_state_t next_state;
    word_t next_ic;
    word_t next_pc;
    word_t next_inst;

    logic write_enable;
    reg_addr_t rd_addr;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    word_t rs1_data;
    word_t rs2_data;
    word_t rd_data;

    reg_file reg_file_0 (
        .clk (clk),
        .write_enable (write_enable),
        .rd_addr (rd_addr),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .rd_data (rd_data)
    );

    always @(rst) begin
        if(rst) begin
            ic = 0;
            pc = 0;
            current = THREAD_STATE_FETCH; 
        end
    end

    always @(posedge clk) begin
        state = next_state;
        ic = next_ic;
        pc = next_pc;
        inst = next_inst;
    end

    always_comb begin
        case (current)
            THREAD_STATE_FETCH: begin
                next_ic = 1; 
                
                unit_sel = UNIT_SEL_RAM;
                unit_contr = RAM_CTRL_READ;
                unit_in[0] = pc;
                unit_in[1] = 0;
                next_inst = unit_out;
            end

            THREAD_STATE_OP: begin
                next_ic = ic + 1;

                unit_sel = UNIT_SEL_ALU;
                unit_contr = 
                unit_in[0] = rs1_data;
                unit_in[1] = rs2_data;
                rd_data = unit_out;

            end

            THREAD_STATE_OP_IMMED: begin

            end

            THREAD_STATE_INC_PC: begin

            end

            default: begin

            end
        endcase
    end

    always_comb begin
        case (inst[6:0])
            ISA_OPCODE_OP: begin
                case(next_ic)
                    1: next_state       = THREAD_STATE_OP                      ;
                    2: next_state       = THREAD_STATE_INC_PC                  ;
                    default: next_state = THREAD_STATE_FETCH                   ;
                endcase
            end
        endcase
    end

endmodule