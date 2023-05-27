module cluster #(
    parameter SIZE = 10,
    parameter WIDTH = 16,
    parameter HEIGHT = 16,

    parameter DATA_WIDTH  = 32,
    parameter INDEX_WIDTH = 32,
    parameter COLOR_WIDTH = 12
) (    
    input  logic [DATA_WIDTH-1:0] x,
    input  logic [DATA_WIDTH-1:0] y,
    output logic [COLOR_WIDTH-1:0] out,

    input  logic [DATA_WIDTH-1:0] i [SIZE-1:0],
    input  logic [DATA_WIDTH-1:0] j [SIZE-1:0],

    output logic [INDEX_WIDTH-1:0] mem_index,
    input  logic [COLOR_WIDTH-1:0] mem_color
);
    always_comb begin
        shortint k;
        logic valid;

        valid = 0;

        for(k = 0; k < SIZE; k++) begin
            if (
                (x > i[k] && x <= i[k] + WIDTH) &&
                (y > j[k] && y <= j[k] + HEIGHT)
            ) begin
                mem_index = (x - i[k]) + WIDTH*(y - j[k]);
                valid = 1;
            end
        end

        if (valid) begin
            out = mem_color;
        end
        else begin
            out = {COLOR_WIDTH{1'b1}};
        end
    end
endmodule