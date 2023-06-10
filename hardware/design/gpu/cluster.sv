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
    output logic [COLOR_WIDTH-1:0] pixel,

    input  logic texture_lock
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

    logic signed [INT_WIDTH-1:0] sig_x;
    logic signed [INT_WIDTH-1:0] sig_y;
    logic signed [INT_WIDTH-1:0] sig_sx  [CLUSTER_SIZE-1:0];     
    logic signed [INT_WIDTH-1:0] sig_sy  [CLUSTER_SIZE-1:0]; 
    logic signed [INT_WIDTH-1:0] sig_stx [CLUSTER_SIZE-1:0]; 
    logic signed [INT_WIDTH-1:0] sig_sty [CLUSTER_SIZE-1:0]; 
    logic signed [INT_WIDTH-1:0] sig_stw [CLUSTER_SIZE-1:0]; 
    logic signed [INT_WIDTH-1:0] sig_sth [CLUSTER_SIZE-1:0];

    position_reg #(
        .ADDR_WIDTH   (ADDR_WIDTH),
        .INT_WIDTH    (16),
        .CLUSTER_SIZE (CLUSTER_SIZE)
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
        logic [CLUSTER_WIDTH:0] k;

        sig_x = $signed(x);
        sig_y = $signed(y);

        for(k = 0; k < CLUSTER_SIZE; k++) begin
            sig_sx[k] = $signed(sx[k]);
            sig_sy[k] = $signed(sy[k]);
            sig_stx[k] = $signed(stx[k]);
            sig_sty[k] = $signed(sty[k]);
            sig_stw[k] = $signed(stw[k]);
            sig_sth[k] = $signed(sth[k]);
        end
    end

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
            texture_wen    = (!texture_lock) && wen;
        end
    end

    always_comb begin
        logic [CLUSTER_WIDTH:0] k;
        logic valid;

        raddr = 0;
        valid = 0;
        
        for(k = 0; k < CLUSTER_SIZE; k++) begin
            if (
                (sig_x >= sig_sx[k]) &&
                (sig_x <  sig_sx[k] + sig_stw[k]*SCALE) &&
                (sig_y >= sig_sy[k]) &&
                (sig_y <  sig_sy[k] + sig_sth[k]*SCALE)
            ) begin
                raddr = (sig_stx[k] + (sig_x - sig_sx[k])/SCALE) + 
                        (sig_sty[k] + (sig_y - sig_sy[k])/SCALE)*TEXTURE_WIDTH;
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