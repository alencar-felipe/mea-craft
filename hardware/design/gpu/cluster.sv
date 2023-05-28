module cluster #(
    parameter CLUSTER_SIZE   = 3,
    parameter TEXTURE_WIDTH  = 64,
    parameter TEXTURE_HEIGHT = 64,

    parameter ADDR_WIDTH     = 22,
    parameter DATA_WIDTH     = 32,
    parameter COLOR_WIDTH    = 12,
    parameter SHORT_WIDTH    = DATA_WIDTH/4
) ( 
    input  logic clk,
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0]  awaddr,
    input  logic [2:0]             awprot,
    input  logic                   awvalid,
    output logic                   awready,
    input  logic [DATA_WIDTH-1:0]  wdata,
    input  logic                   wvalid,
    output logic                   wready,
    output logic [1:0]             bresp,
    output logic                   bvalid,
    input  logic                   bready,

    input  logic [DATA_WIDTH-1:0]  x,
    input  logic [DATA_WIDTH-1:0]  y,
    output logic [COLOR_WIDTH-1:0] pixel,

    // sprite x
    input  logic [DATA_WIDTH-1:0]  sx  [CLUSTER_SIZE-1:0],
    // sprite y
    input  logic [DATA_WIDTH-1:0]  sy  [CLUSTER_SIZE-1:0],
    // sprite texture x
    input  logic [SHORT_WIDTH-1:0] stx [CLUSTER_SIZE-1:0],
    // sprite texture y
    input  logic [SHORT_WIDTH-1:0] sty [CLUSTER_SIZE-1:0],
    // sprite texture width
    input  logic [SHORT_WIDTH-1:0] stw [CLUSTER_SIZE-1:0],
    // sprite texture height
    input  logic [SHORT_WIDTH-1:0] sth [CLUSTER_SIZE-1:0],
    // sprite scale
    input  logic [SHORT_WIDTH-1:0] ssc [CLUSTER_SIZE-1:0]
);
    localparam CLUSTER_WIDTH = $clog2(CLUSTER_SIZE);

    logic [ADDR_WIDTH-1:0]  raddr;
    logic [COLOR_WIDTH-1:0] rcolor;

    texture_ram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .COLOR_WIDTH (COLOR_WIDTH),
        .TEXTURE_SIZE (TEXTURE_WIDTH*TEXTURE_HEIGHT)
    ) texture_ram (
        .clk (clk),
        .rst (rst),

        .awaddr (awaddr),
        .awprot (awprot),
        .awvalid (awvalid),
        .awready (awready),
        .wdata (wdata),
        .wvalid (wvalid),
        .wready (wready),
        .bresp (bresp),
        .bvalid (bvalid),
        .bready (bready),

        .raddr (raddr),
        .rcolor (rcolor)
    );

    always_comb begin
        logic [CLUSTER_WIDTH-1:0] k;
        logic valid;

        valid = 0;

        for(k = 0; k < CLUSTER_SIZE; k++) begin
            if (
                (x >= sx[k] && x < sx[k] + stw[k]*ssc[k]) &&
                (y >= sy[k] && y < sy[k] + sth[k]*ssc[k])
            ) begin
                raddr = ((stx[k] + (x - sx[k])/ssc[k])                ) + 
                        ((sty[k] + (y - sy[k])/ssc[k]) * TEXTURE_WIDTH);
                valid = 1;
                break;
            end
        end

        if (valid) begin
            pixel = rcolor;
        end
        else begin
            pixel = {COLOR_WIDTH{1'b1}};
        end
    end
endmodule