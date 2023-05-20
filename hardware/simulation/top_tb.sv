
module top_tb;
    logic clk;
    logic rst;
    logic uart_loopback;
    
    initial begin  
        clk = 0;
        rst = 1;
        #2;
        rst = 0;
    end
    
    always #5 clk = ~clk;

    top top (
        .clk (clk),
        .rst (rst),
        .uart_tx (uart_loopback),
        .uart_rx (uart_loopback)
    );
endmodule