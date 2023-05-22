module vga #(
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
    localparam SCALE = $clog2(2);
    localparam INDEX_WIDTH = $clog2((WIDTH >> SCALE)*(HEIGHT >> SCALE));
    localparam COLOR_WIDTH = 12;
    
    logic clk25;
    
    shortint x;
    shortint y;
    logic visible;

    logic [INDEX_WIDTH-1:0] windex;
    logic [COLOR_WIDTH-1:0] wcolor;

    logic [INDEX_WIDTH-1:0] rindex;
    logic [COLOR_WIDTH-1:0] rcolor;

    clkdiv #(
        .DIV (2)
    ) clkdiv (
        .clk (clk),
        .rst (rst),
        .out (clk25)
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
        .rst (rst),

        .hsync (hsync),
        .vsync (vsync),

        .x (x),
        .y (y),

        .visible (visible)
    );

    vga_ram #(
        .DATA_WIDTH (COLOR_WIDTH),
        .ADDR_WIDTH (INDEX_WIDTH)
    ) vga_ram (
        .clk (clk),
        .rst (rst),

        .awaddr  (windex),
        .awprot  (awprot),
        .awvalid (awvalid),
        .awready (awready),
        .wdata   (wcolor),
        .wvalid  (wvalid),
        .wready  (wready),
        .bresp   (bresp),
        .bvalid  (bvalid),
        .bready  (bready),

        .araddr  (rindex),
        .rdata   (rcolor)
    );

    always_comb begin
        windex = awaddr[(INDEX_WIDTH-1)+2:2];
        wcolor = wdata[COLOR_WIDTH-1:0];

        if (visible) begin
            rindex = (x >> SCALE) + (y >> SCALE) * (WIDTH >> SCALE);
        end
        else begin
            rindex = 0;
        end

        red   = rcolor[ 3: 0];
        green = rcolor[ 7: 4];
        blue  = rcolor[11: 8];
    end
    
endmodule