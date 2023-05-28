module position_reg #(
    parameter ADDR_WIDTH    = 16,
    parameter INT_WIDTH     = 16,
    parameter CLUSTER_SIZE  = 20
) (
    input  logic clk,
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic [INT_WIDTH-1:0]  wdata,
    input  logic                  wen,

    output logic [INT_WIDTH-1:0] sx  [CLUSTER_SIZE-1:0],
    output logic [INT_WIDTH-1:0] sy  [CLUSTER_SIZE-1:0],
    output logic [INT_WIDTH-1:0] stx [CLUSTER_SIZE-1:0],
    output logic [INT_WIDTH-1:0] sty [CLUSTER_SIZE-1:0],
    output logic [INT_WIDTH-1:0] stw [CLUSTER_SIZE-1:0],
    output logic [INT_WIDTH-1:0] sth [CLUSTER_SIZE-1:0]
);
    always_ff @(posedge clk) begin
        logic [$clog2(CLUSTER_SIZE)-1:0] sprite;
        logic [$clog2(6)-1:0] value;

        sprite = waddr / 6;
        value  = waddr % 6;

        if (
            (wen) &&
            (sprite < CLUSTER_SIZE)  
        ) begin
            case (value)
                0:  sx[sprite] <= wdata;
                1:  sy[sprite] <= wdata;
                2: stx[sprite] <= wdata;
                3: sty[sprite] <= wdata;
                4: stw[sprite] <= wdata;
                5: sth[sprite] <= wdata;
            endcase
        end
    end

endmodule