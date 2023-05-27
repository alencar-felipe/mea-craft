module basys3 (
    input  logic clk,
    
    input  logic [15: 0] sw,
    
    output logic [15: 0] led, 
    
    output logic [ 6: 0] seg,
    output logic         dp,
    output logic [ 3: 0] an,

    input  logic btn_c,
    input  logic btn_u,
    input  logic btn_l,
    input  logic btn_r,
    input  logic btn_d,

    output logic [ 3: 0] vga_red,
    output logic [ 3: 0] vga_green,
    output logic [ 3: 0] vga_blue,
    output logic         vga_hsync,
    output logic         vga_vsync,

    output logic uart_tx,
    input  logic uart_rx,

    input  logic ps2_clk,
    input  logic ps2_data
);

    logic [31: 0] gpio_out [1:0];
    logic [31: 0] gpio_in  [1:0];

    assign gpio_in[0][15: 0] = sw;
    assign gpio_in[0][19:16] = {btn_d, btn_r, btn_l, btn_u};
    assign gpio_in[0][31:20] = 0;
    assign gpio_in[1] = 0;

    assign led = gpio_out[0][15:0];

    top top (
        .clk (clk),
        .rst (btn_c),

        .uart_tx (uart_tx),
        .uart_rx (uart_rx),

        .gpio_out (gpio_out),
        .gpio_in  (gpio_in),

        .vga_red   (vga_red),
        .vga_green (vga_green),
        .vga_blue  (vga_blue),
        .vga_hsync (vga_hsync),
        .vga_vsync (vga_vsync),

        .ps2_clk (ps2_clk),
        .ps2_data (ps2_data)
    );


endmodule