module uart #(
    parameter CLK_FREQ  = 100000000,
    parameter BAUD_RATE = 1000000,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
) (
    input  logic                 clk,
    input  logic                 rst,

    input  logic [DATA_BITS-1:0] din,
    input  logic                 din_valid,
    output logic                 din_ready,

    output logic [DATA_BITS-1:0] dout,
    output logic                 dout_valid,
    input  logic                 dout_ready,

    output logic                 tx,
    input  logic                 rx
);

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) uart_tx (
        .clk (clk),
        .rst (rst),
        .data (din),
        .data_valid (din_valid),
        .data_ready (din_ready),
        .tx (tx)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) uart_rx (
        .clk (clk),
        .rst (rst),
        .data (dout),
        .data_valid (dout_valid),
        .data_ready (dout_ready),
        .rx (rx)
    );

endmodule