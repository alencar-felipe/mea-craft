module clkdiv #(
    parameter DIV = 2
) (
    input  logic clk,
    input  logic rst,
    output logic out
);
    logic [$clog2(DIV-1)-1:0] counter;

    initial begin
        if (DIV < 2) begin
            $error("Error: DIV < 2");
            $finish;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= 0;
            counter <= 0;
        end
        else begin
            if (counter >= DIV-2) begin
                out <= !out;
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
