module debouncer #(
    parameter N = 255
) (
    input  logic clk,
    input  logic rst,
    input  logic in,
    output logic out
);
    logic [$clog2(N)-1:0] count;
    logic in_reg;

    always_ff @(posedge clk) begin
        if(rst) begin
            count <= 0;
            in_reg <= in;
            out <= in;
        end
        if (in == in_reg) begin
            if (count >= N) begin
                out <= in;
            end
            else begin
                count <= count + 1;
            end
        end else begin
            count <= 0;
            in_reg <= in;
        end
    end
endmodule