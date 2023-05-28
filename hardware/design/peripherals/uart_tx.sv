module uart_tx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
) (
    input  logic                 clk,
    input  logic                 rst,
    input  logic [DATA_BITS-1:0] data,
    input  logic                 data_valid,
    output logic                 data_ready,
    output logic                 tx
);
    parameter PERIOD = CLK_FREQ/BAUD_RATE;

    integer unsigned clk_count;
    integer unsigned bit_count;
    logic [DATA_BITS-1:0] curr;

    always_ff @(posedge clk) begin
        if (rst | (!data_valid)) begin
            clk_count <= 0;
            bit_count <= 0;
            curr <= 0;
            data_ready <= 0;
        end
        else begin
            if (clk_count == 0 & bit_count == 0) begin
                // start
                clk_count <= 1;
                bit_count <= 0;
                curr <= data;
            end
            else if (bit_count >= (1 + DATA_BITS + STOP_BITS)) begin
                // end
                data_ready <= 1;
            end
            else if (clk_count >= PERIOD) begin
                // increment bit_count
                clk_count <= 0;
                bit_count <= bit_count + 1;
            end
            else begin
                // increment clk_count
                clk_count <= clk_count + 1;
            end
        end
    end

    always_comb begin
        if (bit_count == 0) begin
            // stop bit or idle
            tx = 1;
        end
        else if (bit_count == 1) begin 
            // start
            tx = 0;
        end
        else if (bit_count < (2 + DATA_BITS)) begin
            // send bit
            tx = curr[bit_count-2];
        end
        else begin
            // default
            tx = 1;
        end
    end
endmodule