module gpu_ram #(
    parameter ADDR_WIDTH     = 22,
    parameter DATA_WIDTH     = 32,
    parameter COLOR_WIDTH    = 12,

    parameter CLUSTERS_SIZE  = 10,
    parameter CLUSTER_SIZE   = 10,
    parameter TEXTURE_SIZE   = 16*16,

    parameter REM_SIZE       = TEXTURE_SIZE + 2*CLUSTER_SIZE,

    parameter CLUSTERS_WIDTH = $clog2(CLUSTERS_SIZE),
    parameter CLUSTER_WIDTH  = $clog2(CLUSTER_SIZE),
    parameter TEXTURE_WIDTH  = $clog2(TEXTURE_SIZE),
    parameter REM_WIDTH      = $clog2(REM_SIZE)
) (
    input  logic        clk,
    input  logic        rst,

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

    input  logic [TEXTURE_WIDTH-1:0] rindex [CLUSTERS_SIZE-1:0],
    output logic [COLOR_WIDTH-1:0]   rcolor [CLUSTERS_SIZE-1:0],
    output logic [DATA_WIDTH-1:0]    rcoord [CLUSTERS_SIZE-1:0][CLUSTER_SIZE-1:0][1:0]
);

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic mem_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
    } write_state_t;

    logic [DATA_WIDTH-1:0]  coords   [CLUSTERS_SIZE-1:0][CLUSTER_SIZE-1:0][1:0];
    logic [COLOR_WIDTH-1:0] textures [CLUSTERS_SIZE-1:0][TEXTURE_SIZE-1:0];
    
    write_state_t w_curr;
    write_state_t w_next;
    
    logic write_en;

    initial begin
        if (2**ADDR_WIDTH < CLUSTERS_SIZE*REM_SIZE) begin
            $error("Error: 2**ADDR_WIDTH < CLUSTERS_SIZE*REM_SIZE");
            $finish;
        end

        if (DATA_WIDTH < COLOR_WIDTH) begin
            $error("Error: DATA_WIDTH < COLOR_WIDTH");
            $finish;
        end
    end
    
    /* Write */
    
    always_ff @(posedge clk) begin
        if (rst) begin
            w_curr.addr_ok <= 0;
            w_curr.data_ok <= 0;
            w_curr.resp_ok <= 0;
            w_curr.mem_ok <= 0;
            w_curr.addr <= 0;
            w_curr.data <= 0;
        end
        else begin
            w_curr <= w_next;
        end
    end

    always_ff @(posedge clk) begin
        logic [CLUSTERS_WIDTH-1:0] cluster;
        logic [REM_WIDTH-1:0]      rem;
        logic [TEXTURE_WIDTH-1:0]  index;
        
        cluster = w_curr.addr / (REM_SIZE);
        rem     = w_curr.addr % (REM_SIZE);
        
        index = rem - 2*CLUSTER_SIZE;

        if (write_en) begin
            if (rem >= 2*CLUSTER_SIZE) begin
                textures[cluster][index] <= w_curr.data[COLOR_WIDTH-1:0];
            end
            else begin
                coords[cluster][rem / 2][rem % 2] <= w_curr.data;
            end
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        awready = 0;
        wready = 0;
        bresp = 0;
        bvalid = 0;

        write_en = 1;

        w_next.addr_ok = w_curr.addr_ok;
        w_next.data_ok = w_curr.data_ok;
        w_next.resp_ok = w_curr.resp_ok;
        w_next.mem_ok = w_curr.mem_ok;
        w_next.addr = w_curr.addr;
        w_next.data = w_curr.data;

        /* Now, make changes as required on a case-by-case basis. */

        if(!w_curr.addr_ok || !w_curr.data_ok || !w_curr.resp_ok) begin
            // Receive data from master.

            awready = !w_curr.addr_ok;
            wready = !w_curr.data_ok;
            bvalid = !w_curr.resp_ok;

            bresp = 0;

            w_next.addr_ok = w_curr.addr_ok || awvalid;
            w_next.data_ok = w_curr.data_ok || wvalid;
            w_next.resp_ok = w_curr.resp_ok || bready;

            if (!w_curr.addr_ok) begin
                w_next.addr = awaddr;
            end

            if (!w_curr.data_ok) begin
                w_next.data = wdata;
            end
        end
        else if (!w_curr.mem_ok) begin
            // Save.

            write_en = 1;
            
            w_next.mem_ok = 1;
        end
        else begin
            // Reset.

            w_next.addr_ok = 0;
            w_next.data_ok = 0;
            w_next.resp_ok = 0;
            w_next.mem_ok = 0;
            w_next.addr = 0;
            w_next.data = 0;
        end

    end

    /* Read */

    generate
        genvar i;
        genvar j;

        for (i = 0; i < CLUSTERS_SIZE; i++) begin
            always_ff @(posedge clk) begin
                if (rst) begin
                    rcolor[i] <= 0;
                end
                else begin
                    rcolor[i] <= textures[i][rindex[i]];
                end
            end

            for (j = 0; j < CLUSTER_SIZE; j++) begin
                always_ff @(posedge clk) begin
                    if (rst) begin
                        rcoord[i][j] <= {0, 0};
                    end
                    else begin
                        rcoord[i][j] <= coords[i][j];
                    end
                end
            end
        end
    endgenerate
    
endmodule