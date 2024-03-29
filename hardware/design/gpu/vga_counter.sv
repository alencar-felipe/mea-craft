module vga_counter #(
    parameter WIDTH     = 640,
    parameter HEIGHT    = 480,
    parameter HSP       =  96,
    parameter HBP       =  48,
    parameter HFP       =  16,
    parameter VSP       =   2,
    parameter VBP       =  29,
    parameter VFP       =  10,

    parameter INT_WIDTH = 16 
) (
    input  logic        clk, // 25 MHz
    input  logic        rst,

    output logic        hsync,
    output logic        vsync,

    output logic [INT_WIDTH-1:0] x,
    output logic [INT_WIDTH-1:0] y,

    output logic        visible
);
    localparam I_MAX = HSP + HBP + WIDTH + HFP - 1;
    localparam J_MAX = VSP + VBP + HEIGHT + VFP - 1;
    
    logic [INT_WIDTH-1:0] i;
    logic [INT_WIDTH-1:0] j;

    always_ff @(posedge clk) begin
        if (rst) begin
            i <= 0;
            j <= 0;
        end
        else begin
            if (j < J_MAX) begin
                if (i < I_MAX) begin
                    i <= i + 1;
                end
                else begin
                    i <= 0;
                    j <= j + 1;
                end
            end
            else begin
                i <= 0;
                j <= 0;
            end
        end
    end
	
    always_comb begin
        hsync = i < HSP;
        vsync = j < VSP;

        x = i - (HSP + HBP);
        y = j - (VSP + VBP);

        visible = (
            (i >= HSP + HBP) &&
            (i < HSP + HBP + WIDTH) &&
            (j >= VSP + VBP) &&
            (j < VSP + VBP + HEIGHT)
        );
    end

endmodule