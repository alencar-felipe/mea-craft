`include "types.sv"

module sext (
    input sext_width_t width,
    input word_t in,
    output word_t out
);
    always_comb begin
        case (width)
            SEXT_WIDTH_8:
                out = {{24{in[7]}}, in[7:0]};
            SEXT_WIDTH_12:
                out = {{20{in[7]}}, in[11:0]};
            SEXT_WIDTH_16:
                out = {{16{in[7]}}, in[15:0]};
            SEXT_WIDTH_20:
                out = {{12{in[7]}}, in[19:0]};
            SEXT_WIDTH_32:
                out = in;
            default:
                out = 0;
        endcase
    end
endmodule
