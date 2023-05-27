module vga_ram #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_WIDTH = 17
) (
    input  logic        clk,
    input  logic        rst,

    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic [2:0]            awprot,
    input  logic                  awvalid,
    output logic                  awready,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic                  wvalid,
    output logic                  wready,
    output logic [1:0]            bresp,
    output logic                  bvalid,
    input  logic                  bready,

    input  logic [ADDR_WIDTH-1:0] araddr,
    output logic [DATA_WIDTH-1:0] rdata
);

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic mem_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
    } write_state_t;

    logic [DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0];

    write_state_t w_curr;
    write_state_t w_next;
    
    logic write_en;
    
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
        if (write_en) begin
            mem[w_curr.addr] <= w_curr.data;
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

    always_ff @(posedge clk) begin
        if (rst) begin
            rdata <= 0;
        end
        else begin
            rdata <= mem[araddr];
        end
    end
    
endmodule