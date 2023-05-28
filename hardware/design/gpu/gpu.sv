module gpu #(
    parameter CLUSTER_COUNT = 5,
    parameter CLUSTER_SIZE = 20,
    parameter TEXTURE_WIDTH = 64,
    parameter TEXTURE_HEIGHT = 64,

    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 24,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
) (
    input  logic clk, // 50 MHz
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic [2:0]            awprot,
    input  logic                  awvalid,
    output logic                  awready,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic [STRB_WIDTH-1:0] wstrb,
    input  logic                  wvalid,
    output logic                  wready,
    output logic [1:0]            bresp,
    output logic                  bvalid,
    input  logic                  bready,

    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,

    output logic hsync,
    output logic vsync
);
    localparam WIDTH  = 640;
    localparam HEIGHT = 480;
    localparam COLOR_WIDTH = 12;

    logic clk25;
    logic rst25;
    
    logic [ADDR_WIDTH-1:0] x;
    logic [ADDR_WIDTH-1:0] y;
    logic visible;

    logic [ADDR_WIDTH-1:0] raddr;
    logic [COLOR_WIDTH-1:0] rcolor;
    
    logic [COLOR_WIDTH-1:0] pixel;

    clkdiv #(
        .DIV (2)
    ) clkdiv (
        .clk_in (clk),
        .rst_in (rst),
        .clk_out (clk25),
        .rst_out (rst25)
    );

    vga_counter #(
        .WIDTH  (WIDTH),
        .HEIGHT (HEIGHT),
        .HSP    ( 96),
        .HBP    ( 48),
        .HFP    ( 16),
        .VSP    (  2),
        .VBP    ( 29),
        .VFP    ( 10) 
    ) vga_counter (
        .clk (clk25),
        .rst (rst25),

        .hsync (hsync),
        .vsync (vsync),

        .x (x),
        .y (y),

        .visible (visible)
    );

    texture_ram #(
        .ADDR_WIDTH   (ADDR_WIDTH-2),
        .DATA_WIDTH   (DATA_WIDTH),
        .COLOR_WIDTH  (COLOR_WIDTH),
        .TEXTURE_SIZE  (TEXTURE_WIDTH*TEXTURE_HEIGHT)
    ) texture_ram (
        .clk (clk),
        .rst (rst),

        .awaddr  (awaddr[ADDR_WIDTH-1:2]),
        .awprot  (awprot),
        .awvalid (awvalid),
        .awready (awready),
        .wdata   (wdata),
        .wvalid  (wvalid),
        .wready  (wready),
        .bresp   (bresp),
        .bvalid  (bvalid),
        .bready  (bready),

        .raddr (raddr),
        .rcolor (rcolor)
    );

    assign red   = pixel[11: 8];
    assign green = pixel[ 7: 4];
    assign blue  = pixel[ 3: 0];

    always_comb begin
        if (
            (visible) &&
            (x > 300 && x <= 364) &&
            (y > 300 && y <= 364)
        ) begin
            raddr = (x-300) + (y-300)*TEXTURE_WIDTH;
            pixel = rcolor;
        end
        else begin
            raddr = 0;
            pixel = 0; 
        end
    end

endmodule