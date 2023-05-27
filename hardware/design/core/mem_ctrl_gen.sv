`include "types.sv"

/* verilator lint_off UNUSED */

module mem_ctrl_gen(
    input word_t inst,
    output mem_ctrl_t mem_ctrl
);
    always_comb begin
        case (inst[6:0])
            ISA_OPCODE_LOAD: begin
                case (inst[14:12])
                    ISA_MEM_F3_BYTE: begin
                        mem_ctrl = MEM_CTRL_READ_BYTE;
                    end
                    ISA_MEM_F3_HALF: begin
                        mem_ctrl = MEM_CTRL_READ_HALF;
                    end
                    ISA_MEM_F3_WORD: begin
                        mem_ctrl = MEM_CTRL_READ_WORD;
                    end
                    ISA_MEM_F3_BYTE_U: begin
                        mem_ctrl = MEM_CTRL_READ_BYTE;
                    end
                    ISA_MEM_F3_HALF_U: begin
                        mem_ctrl = MEM_CTRL_READ_HALF;
                    end
                    default: begin
                        mem_ctrl = MEM_CTRL_NONE;
                    end
                endcase
            end
            ISA_OPCODE_STORE: begin
                case (inst[14:12])      
                    ISA_MEM_F3_BYTE: begin
                        mem_ctrl = MEM_CTRL_STORE_BYTE;
                    end
                    ISA_MEM_F3_HALF: begin
                        mem_ctrl = MEM_CTRL_STORE_HALF;
                    end
                    ISA_MEM_F3_WORD: begin
                        mem_ctrl = MEM_CTRL_STORE_WORD;
                    end
                    ISA_MEM_F3_BYTE_U: begin
                        mem_ctrl = MEM_CTRL_STORE_BYTE;
                    end
                    ISA_MEM_F3_HALF_U: begin
                        mem_ctrl = MEM_CTRL_STORE_HALF;
                    end
                    default: begin
                        mem_ctrl = MEM_CTRL_NONE;
                    end
                endcase
            end
            default: begin
                mem_ctrl = MEM_CTRL_NONE;
            end
        endcase
    end;
endmodule