module cluster #(
    parameter CLUSTER_SIZE   = 10,
    parameter TEXTURE_WIDTH  = 64,
    parameter TEXTURE_HEIGHT = 64,

    parameter ADDR_WIDTH     = 16,
    parameter INT_WIDTH      = 16,
    parameter COLOR_WIDTH    = 12,
    
    parameter SCALE          = 2
) ( 
    input  logic clk,
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic [INT_WIDTH-1:0]  wdata,
    input  logic                  wen,

    input  logic [INT_WIDTH-1:0]   x,
    input  logic [INT_WIDTH-1:0]   y,
    output logic [COLOR_WIDTH-1:0] pixel
); 
    localparam CLUSTER_WIDTH = $clog2(CLUSTER_SIZE);

    logic [ADDR_WIDTH-1:0] position_waddr;
    logic [INT_WIDTH-1:0]  position_wdata;
    logic                  position_wen;

    logic [ADDR_WIDTH-1:0]  texture_waddr;
    logic [COLOR_WIDTH-1:0] texture_wcolor;
    logic                   texture_wen;

    logic [ADDR_WIDTH-1:0]  raddr;
    logic [COLOR_WIDTH-1:0] rcolor;

    logic [INT_WIDTH-1:0]  sx [CLUSTER_SIZE-1:0]; // sprite x    
    logic [INT_WIDTH-1:0]  sy [CLUSTER_SIZE-1:0]; // sprite y
    logic [INT_WIDTH-1:0] stx [CLUSTER_SIZE-1:0]; // sprite texture x
    logic [INT_WIDTH-1:0] sty [CLUSTER_SIZE-1:0]; // sprite texture y
    logic [INT_WIDTH-1:0] stw [CLUSTER_SIZE-1:0]; // sprite texture width
    logic [INT_WIDTH-1:0] sth [CLUSTER_SIZE-1:0]; // sprite texture height

    position_reg #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .INT_WIDTH    (16),
        .CLUSTER_SIZE (20)
    ) position_reg (
        .clk (clk),
        .rst (rst),

        .waddr (position_waddr),
        .wdata (position_wdata),
        .wen   (position_wen),

        .sx  (sx),
        .sy  (sy),
        .stx (stx),
        .sty  (sty),
        .stw  (stw),
        .sth  (sth)
    );

    texture_ram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .COLOR_WIDTH (COLOR_WIDTH),
        .TEXTURE_SIZE (TEXTURE_WIDTH*TEXTURE_HEIGHT)
    ) texture_ram (
        .clk (clk),
        .rst (rst),

        .waddr  (texture_waddr),
        .wcolor (texture_wcolor),
        .wen    (texture_wen),

        .raddr  (raddr),
        .rcolor (rcolor)
    );

    always_comb begin
        position_waddr = 0;
        position_wdata = 0;
        position_wen   = 0;

        texture_waddr  = 0;
        texture_wcolor = 0;
        texture_wen    = 0;

        if (waddr < CLUSTER_SIZE*6) begin
            position_waddr = waddr;
            position_wdata = wdata;
            position_wen   = wen;
        end
        else begin
            texture_waddr  = waddr - CLUSTER_SIZE*6;
            texture_wcolor = wdata[COLOR_WIDTH-1:0];
            texture_wen    = wen;
        end
    end

    always_comb begin
        logic [CLUSTER_WIDTH-1:0] k;
        logic valid;

        raddr = 0;
        valid = 0;
        
        for(k = 0; k < CLUSTER_SIZE; k++) begin
            if (
                (x >= sx[k] && x < sx[k] + stw[k]*SCALE) &&
                (y >= sy[k] && y < sy[k] + sth[k]*SCALE)
            ) begin
                raddr = ((stx[k] + (x - sx[k])/SCALE)                ) + 
                        ((sty[k] + (y - sy[k])/SCALE) * TEXTURE_WIDTH);
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