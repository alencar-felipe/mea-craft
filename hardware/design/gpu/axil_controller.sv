module axil_controller #(
    parameter ADDR_WIDTH = 24,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
) (
    input  logic clk,
    input  logic rst,

    input  logic [ADDR_WIDTH-1:0]  axil_awaddr,
    input  logic [2:0]             axil_awprot,
    input  logic                   axil_awvalid,
    output logic                   axil_awready,
    input  logic [DATA_WIDTH-1:0]  axil_wdata,
    input  logic [STRB_WIDTH-1:0]  axil_wstrb,
    input  logic                   axil_wvalid,
    output logic                   axil_wready,
    output logic [1:0]             axil_bresp,
    output logic                   axil_bvalid,
    input  logic                   axil_bready,

    output  logic [ADDR_WIDTH-1:0] waddr,
    output logic [DATA_WIDTH-1:0]  wdata,
    output logic                   wen
);

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic mem_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
    } write_state_t;
    
    write_state_t w_curr;
    write_state_t w_next;
    
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

    always_comb begin
        
        /* First, set everything to the default value. */

        axil_awready = 0;
        axil_wready = 0;
        axil_bresp = 0;
        axil_bvalid = 0;

        waddr = 0;
        wdata = 0;
        wen = 0;

        w_next.addr_ok = w_curr.addr_ok;
        w_next.data_ok = w_curr.data_ok;
        w_next.resp_ok = w_curr.resp_ok;
        w_next.mem_ok = w_curr.mem_ok;
        w_next.addr = w_curr.addr;
        w_next.data = w_curr.data;

        /* Now, make changes as required on a case-by-case basis. */

        if(!w_curr.addr_ok || !w_curr.data_ok || !w_curr.resp_ok) begin
            // Receive data from master.

            axil_awready = !w_curr.addr_ok;
            axil_wready = !w_curr.data_ok;
            axil_bvalid = !w_curr.resp_ok;

            axil_bresp = 0;

            w_next.addr_ok = w_curr.addr_ok || axil_awvalid;
            w_next.data_ok = w_curr.data_ok || axil_wvalid;
            w_next.resp_ok = w_curr.resp_ok || axil_bready;

            if (!w_curr.addr_ok) begin
                w_next.addr = axil_awaddr;
            end

            if (!w_curr.data_ok) begin
                w_next.data = axil_wdata;
            end
        end
        else if (!w_curr.mem_ok) begin
            // Save.

            waddr = w_curr.addr;
            wdata = w_curr.data;
            wen   = 1;
            
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
    
endmodule