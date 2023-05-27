module uart_rx #(
    parameter CLK_FREQ  = 100000000,
    parameter BAUD_RATE = 9600,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
) (
    input  logic                 clk,
    input  logic                 rst,
    output logic [DATA_BITS-1:0] data,
    output logic                 data_valid,
    input  logic                 data_ready,
    input  logic                 rx
);
    parameter PERIOD = CLK_FREQ/BAUD_RATE;

    integer unsigned clk_count;
    integer unsigned bit_count;
    logic [DATA_BITS-1:0] curr;
    
    assign data = curr;

    always_ff @(posedge clk) begin
        if(rst) begin
            clk_count <= 0;
            bit_count <= 0;
            curr <= 0;
            data_valid <= 0;
        end
        else begin
            if (clk_count == 0 & bit_count == 0) begin
                // idle
                if (rx == 0) begin
                    // start
                    clk_count <= PERIOD/2;
                    bit_count <= 0;
                    curr <= 0;
                    data_valid <= 0;
                end
                else begin
                    // continue idle
                    clk_count <= 0;
                    bit_count <= 0;
                    curr <= 0;
                    data_valid <= 0;
                end
            end
            else if (bit_count >= (1 + DATA_BITS + STOP_BITS)) begin
                // end of transmission
                if (data_valid & data_ready) begin
                    // reset
                    clk_count <= 0;
                    bit_count <= 0;
                    curr <= 0;
                    data_valid <= 0;
                end
                else begin
                    // waiting for data_ready
                    clk_count <= clk_count;
                    bit_count <= bit_count;
                    curr <= curr;
                    data_valid <= 1;
                end
            end
            else if (clk_count >= PERIOD) begin
                // increment bit_count
                clk_count <= 0;
                bit_count <= bit_count + 1;
                data_valid <= 0;

                if (bit_count >= 1 && bit_count < 1 + DATA_BITS) begin
                    // data bit
                    curr <= curr;
                    curr[bit_count-1] <= rx;
                end
                else begin
                    // start/stop/idle bit
                    curr <= curr;
                end
            end
            else begin
                // increment clk_count
                clk_count <= clk_count + 1;
                bit_count <= bit_count;
                curr <= curr;
                data_valid <= 0;
            end
        end
    end
endmodule