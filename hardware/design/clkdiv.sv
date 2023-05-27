module clkdiv #(
    parameter DIV = 2
) (
    input logic clk_in,
    input logic rst_in,
    output logic clk_out,
    output logic rst_out
);
    logic [$clog2(DIV-1)-1:0] counter;

    initial begin
        if (DIV < 2) begin
            $error("Error: DIV < 2");
            $finish;
        end
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            clk_out <= 0;
            rst_out <= 1;
            counter <= 0;
        end
        else if (counter >= DIV-2) begin
            clk_out <= !clk_out;
            counter <= 0;

            if (clk_out) begin
                rst_out <= 0;
            end
        end
        else begin
            counter <= counter + 1;
        end
    end

endmodule
