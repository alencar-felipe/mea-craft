module gpu #(
    parameter CLUSTERS_SIZE = 5,
    parameter CLUSTER_SIZE = 20,
    parameter TEXTURE_WIDTH = 16,
    parameter TEXTURE_HEIGHT = 16,

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
    localparam INDEX_WIDTH = $clog2(TEXTURE_WIDTH*TEXTURE_HEIGHT);
    localparam CLUSTER_WIDTH = $clog2(CLUSTER_SIZE);
    localparam CLUSTERS_WIDTH = $clog2(CLUSTERS_SIZE);

    logic clk25;
    logic rst25;
    
    logic [DATA_WIDTH-1:0] x;
    logic [DATA_WIDTH-1:0] y;
    logic visible;

    logic [INDEX_WIDTH-1:0] windex;
    logic [COLOR_WIDTH-1:0] wcolor;

    logic [DATA_WIDTH-1:0] rcoord [CLUSTERS_SIZE-1:0][CLUSTER_SIZE-1:0][1:0];

    logic [DATA_WIDTH-1:0] i       [CLUSTERS_SIZE-1:0][CLUSTER_SIZE-1:0];
    logic [DATA_WIDTH-1:0] j       [CLUSTERS_SIZE-1:0][CLUSTER_SIZE-1:0];
    logic [COLOR_WIDTH-1:0] outs   [CLUSTERS_SIZE-1:0];
    logic [INDEX_WIDTH-1:0] rindex [CLUSTERS_SIZE-1:0];
    logic [COLOR_WIDTH-1:0] rcolor [CLUSTERS_SIZE-1:0];
    
    logic [COLOR_WIDTH-1:0] color;

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

    gpu_ram #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .COLOR_WIDTH  (COLOR_WIDTH),

        .CLUSTERS_SIZE (CLUSTERS_SIZE),
        .CLUSTER_SIZE  (CLUSTER_SIZE),
        .TEXTURE_SIZE  (TEXTURE_WIDTH*TEXTURE_HEIGHT)
    ) gpu_ram (
        .clk (clk),
        .rst (rst),

        .awaddr  (awaddr[(INDEX_WIDTH-1)+2:2]),
        .awprot  (awprot),
        .awvalid (awvalid),
        .awready (awready),
        .wdata   (wdata),
        .wvalid  (wvalid),
        .wready  (wready),
        .bresp   (bresp),
        .bvalid  (bvalid),
        .bready  (bready),

        .rindex (rindex),
        .rcolor (rcolor),
        .rcoord (rcoord)
    );

    generate
        genvar k;
        genvar l;
        for (k = 0; k < CLUSTERS_SIZE; k++) begin
            cluster #(
                .SIZE   (CLUSTER_SIZE),
                .WIDTH  (TEXTURE_WIDTH),
                .HEIGHT (TEXTURE_HEIGHT),
                
                .DATA_WIDTH  (DATA_WIDTH),
                .INDEX_WIDTH (INDEX_WIDTH),
                .COLOR_WIDTH (COLOR_WIDTH)
            ) cluster (
                .x (x),
                .y (y),
                .out(outs[k]),

                .i (i[k]),
                .j (j[k]),

                .mem_index(rindex[k]),
                .mem_color(rcolor[k])
            );

            for (l = 0; l < CLUSTER_SIZE; l++) begin
                assign i[k][l] = rcoord[k][l][0];
                assign j[k][l] = rcoord[k][l][1];
            end
        end
    endgenerate

    assign red   = color[11: 8];
    assign green = color[ 7: 4];
    assign blue  = color[ 3: 0];

    always_comb begin
        shortint k;

        for(k = 0; k < CLUSTERS_SIZE; k++) begin
            if (outs[k] != {COLOR_WIDTH{1'b0}}) begin
                color = outs[k];
                break;
            end
        end
    end

endmodule