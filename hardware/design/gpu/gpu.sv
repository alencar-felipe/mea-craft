module gpu #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 24,
    parameter STRB_WIDTH = (DATA_WIDTH/8)    
) (
    input  logic clk, // 50 MHz
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0] axil_awaddr,
    input  logic [2:0]            axil_awprot,
    input  logic                  axil_awvalid,
    output logic                  axil_awready,
    input  logic [DATA_WIDTH-1:0] axil_wdata,
    input  logic [STRB_WIDTH-1:0] axil_wstrb,
    input  logic                  axil_wvalid,
    output logic                  axil_wready,
    output logic [1:0]            axil_bresp,
    output logic                  axil_bvalid,
    input  logic                  axil_bready,

    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,

    output logic hsync,
    output logic vsync
);
    localparam WIDTH  = 640;
    localparam HEIGHT = 480;
    localparam COLOR_WIDTH = 12;
    localparam INT_WIDTH = 16;

    localparam TEXTURE_WIDTH  = 64;
    localparam TEXTURE_HEIGHT = 64;
    localparam CLUSTER_COUNT  = 3;
    localparam CLUSTER_SIZE   = 20;

    logic clk25;
    logic rst25;
    
    logic [INT_WIDTH-1:0] x;
    logic [INT_WIDTH-1:0] y;
    logic visible;
    
    logic [ADDR_WIDTH-1:0] waddr;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  wen;

    logic [COLOR_WIDTH-1:0] pixel;
    logic [COLOR_WIDTH-1:0] cluster_pixel [CLUSTER_COUNT-1:0];
    
    logic [ADDR_WIDTH-1:0] cluster_waddr [CLUSTER_COUNT-1:0];
    logic [INT_WIDTH-1:0]  cluster_wdata [CLUSTER_COUNT-1:0];
    logic                  cluster_wen   [CLUSTER_COUNT-1:0];

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
        .VFP    ( 10),

        .INT_WIDTH (INT_WIDTH)
    ) vga_counter (
        .clk (clk25),
        .rst (rst25),

        .hsync (hsync),
        .vsync (vsync),

        .x (x),
        .y (y),

        .visible (visible)
    );

    axil_controller #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .STRB_WIDTH (STRB_WIDTH)
    ) axil_controller (
        .clk (clk),
        .rst (rst),

        .axil_awaddr  (axil_awaddr),
        .axil_awprot  (axil_awprot),
        .axil_awvalid (axil_awvalid),
        .axil_awready (axil_awready),
        .axil_wdata   (axil_wdata),
        .axil_wstrb   (axil_wstrb), 
        .axil_wvalid  (axil_wvalid),
        .axil_wready  (axil_wready),
        .axil_bresp   (axil_bresp),
        .axil_bvalid  (axil_bvalid),
        .axil_bready  (axil_bready),

        .waddr (waddr),
        .wdata (wdata),
        .wen   (wen)
    );

    cluster #(
        .CLUSTER_SIZE   (CLUSTER_SIZE),
        .TEXTURE_WIDTH  (TEXTURE_WIDTH),
        .TEXTURE_HEIGHT (TEXTURE_HEIGHT),

        .ADDR_WIDTH  (16),
        .INT_WIDTH   (INT_WIDTH),
        .COLOR_WIDTH (COLOR_WIDTH),
        .SCALE (1)
    ) cluster ( 
        .clk (clk),
        .rst (rst),

        .waddr (waddr[17:2]),
        .wdata (wdata[INT_WIDTH-1:0]),
        .wen   (wen),

        .x     (x),
        .y     (y),
        .pixel (cluster_pixel[0])
    );

    always_comb begin
        logic [$clog2(CLUSTER_SIZE)-1:0] k;

        if (visible) begin
            pixel = cluster_pixel[0];
            /*for (k = 0; k < CLUSTER_SIZE; k++) begin
                if(cluster_pixel[k] != 24'hFFF) begin
                    pixel = cluster_pixel[k];
                    break;
                end
            end*/
        end
        else begin
            pixel = 0;
        end
    end

    assign red   = pixel[11: 8];
    assign green = pixel[ 7: 4];
    assign blue  = pixel[ 3: 0];

    always_comb begin
        logic [$clog2(CLUSTER_SIZE)-1:0] k;
        for (k = 1; k < CLUSTER_SIZE; k++) begin
            cluster_pixel[k] = 24'hFFF;
        end
    end

endmodule