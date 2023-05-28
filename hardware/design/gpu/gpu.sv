module gpu #(
    parameter CLUSTER_COUNT = 20,
    parameter CLUSTER_SIZE = 10,
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

    localparam INDEX_WIDTH   = ADDR_WIDTH-2;
    localparam SHORT_WIDTH   = DATA_WIDTH/4;
    localparam CLUSTER_WIDTH = $clog2(CLUSTER_SIZE);

    logic clk25;
    logic rst25;
    
    logic [INDEX_WIDTH-1:0] x;
    logic [INDEX_WIDTH-1:0] y;
    logic visible;
    
    logic [COLOR_WIDTH-1:0] pixel;
    logic [COLOR_WIDTH-1:0] cluster_pixel;

    logic [DATA_WIDTH-1:0]  sx  [CLUSTER_SIZE-1:0];
    logic [DATA_WIDTH-1:0]  sy  [CLUSTER_SIZE-1:0];
    logic [SHORT_WIDTH-1:0] stx [CLUSTER_SIZE-1:0];
    logic [SHORT_WIDTH-1:0] sty [CLUSTER_SIZE-1:0];
    logic [SHORT_WIDTH-1:0] stw [CLUSTER_SIZE-1:0];
    logic [SHORT_WIDTH-1:0] sth [CLUSTER_SIZE-1:0];
    logic [SHORT_WIDTH-1:0] ssc [CLUSTER_SIZE-1:0];

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

    cluster #(
        .CLUSTER_SIZE (CLUSTER_SIZE),
        .TEXTURE_WIDTH (TEXTURE_WIDTH),
        .TEXTURE_HEIGHT (TEXTURE_HEIGHT),

        .ADDR_WIDTH (INDEX_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .COLOR_WIDTH (COLOR_WIDTH),
        .SHORT_WIDTH (DATA_WIDTH/4)
    ) cluster ( 
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

        .x     (x),
        .y     (y),
        .pixel (cluster_pixel),

        .sx  (sx),
        .sy  (sy),
        .stx (stx),
        .sty (sty),
        .stw (stw),
        .sth (sth),
        .ssc (ssc)
    );

    always_comb begin
        if (visible) begin
            pixel = cluster_pixel;
        end
        else begin
            pixel = 0;
        end
    end

    assign red   = pixel[11: 8];
    assign green = pixel[ 7: 4];
    assign blue  = pixel[ 3: 0];

    always_comb begin
        logic [CLUSTER_WIDTH-1:0] k;

        sx[0] = 100;
        sy[0] = 100;
        stx[0] = 0;
        sty[0] = 0;
        stw[0] = 64;
        sth[0] = 64;
        ssc[0] = 1;

        sx[1] = 300;
        sy[1] = 100;
        stx[1] = 0;
        sty[1] = 0;
        stw[1] = 64;
        sth[1] = 64;
        ssc[1] = 2;

        sx[2] = 100;
        sy[2] = 300;
        stx[2] = 0;
        sty[2] = 0;
        stw[2] = 64;
        sth[2] = 64;
        ssc[2] = 4;

        for (k = 3; k < CLUSTER_SIZE; k++) begin
            sx[k] = 0;
            sy[k] = 0;
            stx[k] = 0;
            sty[k] = 0;
            stw[k] = 0;
            sth[k] = 0;
            ssc[k] = 1;
        end
    end

endmodule