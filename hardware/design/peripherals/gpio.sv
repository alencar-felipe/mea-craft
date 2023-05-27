module gpio #(
    parameter ADDR_WIDTH = 2,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
) (
    input  logic                  clk,
    input  logic                  rst,

    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic [2:0]            awprot,
    input  logic                  awvalid,
    output logic                  awready,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic [3:0]            wstrb,
    input  logic                  wvalid,
    output logic                  wready,
    output logic [1:0]            bresp,
    output logic                  bvalid,
    input  logic                  bready,
    input  logic [ADDR_WIDTH:0]   araddr,
    input  logic [2:0]            arprot,
    input  logic                  arvalid,
    output logic                  arready,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic [1:0]            rresp,
    output logic                  rvalid,
    input  logic                  rready,

    output logic [DATA_WIDTH-1:0] out [ADDR_WIDTH-1:0],
    input  logic [DATA_WIDTH-1:0] in [ADDR_WIDTH-1:0]
);
    localparam WORD_WIDTH = STRB_WIDTH; 
    localparam WORD_SIZE = DATA_WIDTH/WORD_WIDTH;

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic gpio_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
        logic [STRB_WIDTH-1:0] strb;
    } write_state_t;

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
    } read_state_t;

    write_state_t w_curr;
    write_state_t w_next;

    read_state_t r_curr;
    read_state_t r_next;
    
    logic [DATA_WIDTH-1:0] out_next [ADDR_WIDTH-1:0];
    
    /* Write */
    
    always_ff @(posedge clk) begin
        if (rst) begin
            w_curr.addr_ok <= 0;
            w_curr.data_ok <= 0;
            w_curr.resp_ok <= 0;
            w_curr.gpio_ok <= 0;
            w_curr.addr <= 0;
            w_curr.data <= 0;
            w_curr.strb <= 0;

            for (int j = 0; j < ADDR_WIDTH; j++) begin
                out[j] <= 0;
            end
        end
        else begin
            w_curr <= w_next;
            out <= out_next;
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        awready = 0;
        wready = 0;
        bresp = 0;
        bvalid = 0;

        for (int i = 0; i < ADDR_WIDTH; i++) begin
            out_next[i] = out[i];
        end

        w_next.addr_ok = w_curr.addr_ok;
        w_next.data_ok = w_curr.data_ok;
        w_next.resp_ok = w_curr.resp_ok;
        w_next.gpio_ok = w_curr.gpio_ok;
        w_next.addr = w_curr.addr;
        w_next.data = w_curr.data;
        w_next.strb = w_curr.strb;

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
                w_next.strb = wstrb;
            end
        end
        else if (!w_curr.gpio_ok) begin
            // Update state.

            for (int i = 0; i < WORD_WIDTH; i++) begin
                if (w_curr.strb[i]) begin
                    out_next[w_curr.addr][WORD_SIZE*i +: WORD_SIZE] =
                        w_curr.data[WORD_SIZE*i +: WORD_SIZE];
                end
            end

            w_next.gpio_ok = 1;
        end
        else begin
            // Reset.

            w_next.addr_ok = 0;
            w_next.data_ok = 0;
            w_next.resp_ok = 0;
            w_next.gpio_ok = 0;
            w_next.addr = 0;
            w_next.data = 0;
            w_next.strb = 0;
        end

    end

    /* Read */

    always_ff @(posedge clk) begin
        if (rst) begin
            r_curr.addr_ok <= 0;
            r_curr.data_ok <= 0;
            r_curr.resp_ok <= 0;
            r_curr.addr <= 0;
            r_curr.data <= 0;
        end
        else begin
            r_curr <= r_next;
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        arready = 0;
        rresp = 0;
        rvalid = 0;

        r_next.addr_ok = r_curr.addr_ok;
        r_next.data_ok = r_curr.data_ok;
        r_next.resp_ok = r_curr.resp_ok;
        r_next.addr = r_curr.addr;
        r_next.data = r_curr.data;

        /* Now, make changes as required on a case-by-case basis. */

        if (!r_curr.addr_ok) begin
            // Receive address from master.

            arready = !r_curr.addr_ok;

            r_next.addr_ok = r_curr.addr_ok || arvalid;
            
            if (!r_curr.addr_ok) begin
                r_next.addr = araddr;
            end
        end
        else if (!r_curr.data_ok) begin
            // Load correponding data.
            
            r_next.data = in[r_curr.addr];
            
            r_next.data_ok = 1;
        end 
        else if (!r_curr.resp_ok) begin
            // Send response to master.

            rvalid = !r_curr.resp_ok;

            rdata = r_curr.data;

            r_next.resp_ok = r_curr.resp_ok || rready;
        end
        else begin
            // Reset.

            r_next.addr_ok = 0;
            r_next.data_ok = 0;
            r_next.resp_ok = 0;
            r_next.addr = 0;
            r_next.data = 0;
        end
    end

endmodule