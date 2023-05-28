module texture_ram #(
    parameter ADDR_WIDTH     = 16,
    parameter COLOR_WIDTH    = 12,
    parameter TEXTURE_SIZE   = 64*64
) (
    input  logic clk,
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0]  waddr,
    input  logic [COLOR_WIDTH-1:0] wcolor,
    input  logic                   wen,

    input  logic [ADDR_WIDTH-1:0]  raddr,
    output logic [COLOR_WIDTH-1:0] rcolor
);
    
    logic [COLOR_WIDTH-1:0] mem [TEXTURE_SIZE-1:0];
    
    always_ff @(posedge clk) begin
        if (wen) begin
            if(waddr < TEXTURE_SIZE) begin
                mem[waddr] = wcolor;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rcolor <= 0;
        end
        else begin
            if (raddr < TEXTURE_SIZE) begin
                rcolor <= mem[raddr];
            end
            else begin
                rcolor <= 0;
            end
        end
    end

endmodule