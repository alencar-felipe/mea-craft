module aligner #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 16,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)
(
    input  logic                   clk,
    input  logic                   rst,

    input  logic [ADDR_WIDTH-1:0]  s_awaddr,
    input  logic [2:0]             s_awprot,
    input  logic                   s_awvalid,
    output logic                   s_awready,
    input  logic [DATA_WIDTH-1:0]  s_wdata,
    input  logic [STRB_WIDTH-1:0]  s_wstrb,
    input  logic                   s_wvalid,
    output logic                   s_wready,
    output logic [1:0]             s_bresp,
    output logic                   s_bvalid,
    input  logic                   s_bready,
    input  logic [ADDR_WIDTH-1:0]  s_araddr,
    input  logic [2:0]             s_arprot,
    input  logic                   s_arvalid,
    output logic                   s_arready,
    output logic [DATA_WIDTH-1:0]  s_rdata,
    output logic [1:0]             s_rresp,
    output logic                   s_rvalid,
    input  logic                   s_rready,

    output logic [ADDR_WIDTH-1:0]  m_awaddr,
    output logic [2:0]             m_awprot,
    output logic                   m_awvalid,
    input  logic                   m_awready,
    output logic [DATA_WIDTH-1:0]  m_wdata,
    output logic [STRB_WIDTH-1:0]  m_wstrb,
    output logic                   m_wvalid,
    input  logic                   m_wready,
    input  logic [1:0]             m_bresp,
    input  logic                   m_bvalid,
    output logic                   m_bready,
    output logic [ADDR_WIDTH-1:0]  m_araddr,
    output logic [2:0]             m_arprot,
    output logic                   m_arvalid,
    input  logic                   m_arready,
    input  logic [DATA_WIDTH-1:0]  m_rdata,
    input  logic [1:0]             m_rresp,
    input  logic                   m_rvalid,
    output logic                   m_rready
);

    parameter ELEM_WIDTH = DATA_WIDTH/STRB_WIDTH;
    parameter REST_WIDTH = $clog2(STRB_WIDTH);
    parameter QUOT_WIDTH = ADDR_WIDTH - REST_WIDTH;
    parameter MEM_LEN = QUOT_WIDTH**2;

    typedef struct packed {
        logic s_addr_ok;
        logic s_data_ok;
        logic s_resp_ok;
        logic m_addr_ok;
        logic m_data_ok;
        logic m_resp_ok;
        logic [REST_WIDTH-1:0] shift;
        logic [ADDR_WIDTH-1:0] addr;
        logic [2:0] prot;
        logic [DATA_WIDTH-1:0] data;
        logic [STRB_WIDTH-1:0] strb;
        logic [1:0] resp;
    } write_state_t;

    typedef struct packed {
        logic s_addr_ok;
        logic m_addr_ok;
        logic m_data_ok;
        logic [REST_WIDTH-1:0] shift;
        logic [ADDR_WIDTH-1:0] addr;
        logic [2:0] prot;
        logic [DATA_WIDTH-1:0] data1;
        logic [DATA_WIDTH-1:0] data2;
        logic [1:0] resp;
    } read_state_t;

    write_state_t w_curr;
    write_state_t w_next;

    logic [REST_WIDTH-1:0] w_curr_rest;
    logic [QUOT_WIDTH-1:0] w_curr_quot;

    read_state_t r_curr;
    read_state_t r_next;

    logic [REST_WIDTH-1:0] r_curr_rest;
    logic [QUOT_WIDTH-1:0] r_curr_quot;

    /* Write */
    
    always_ff @(posedge clk) begin
        if (rst) begin
            w_curr.s_addr_ok <= 0;
            w_curr.s_data_ok <= 0;
            w_curr.s_resp_ok <= 0;
            w_curr.m_addr_ok <= 0;
            w_curr.m_data_ok <= 0;
            w_curr.m_resp_ok <= 0;
            w_curr.shift <= 0;
            w_curr.addr <= 0;
            w_curr.prot <= 0;
            w_curr.data <= 0;
            w_curr.strb <= 0;
            w_curr.resp <= 0;
        end
        else begin
            w_curr <= w_next;
        end
    end

    assign w_curr_quot = w_curr.addr[ADDR_WIDTH-1:REST_WIDTH];
    assign w_curr_rest = w_curr.addr[REST_WIDTH-1:0];

    always_comb begin
        
        /* First, set everything to the default value. */

        s_awready = 0;
        s_wready = 0;
        s_bresp = 0;
        s_bvalid = 0;
        
        m_awaddr = 0;
        m_awprot = 0;
        m_awvalid = 0;
        m_wdata = 0;
        m_wstrb = 0;
        m_wvalid = 0;        
        m_bready = 0;

        w_next.s_addr_ok = w_curr.s_addr_ok;
        w_next.s_data_ok = w_curr.s_data_ok;
        w_next.s_resp_ok = w_curr.s_resp_ok;
        w_next.m_addr_ok = w_curr.m_addr_ok;
        w_next.m_data_ok = w_curr.m_data_ok;
        w_next.m_resp_ok = w_curr.m_resp_ok;
        w_next.shift = w_curr.shift;
        w_next.addr = w_curr.addr;
        w_next.prot = w_curr.prot;
        w_next.data = w_curr.data;
        w_next.strb = w_curr.strb;
        w_next.resp = w_curr.resp;

        /* Now, make changes as required on a case-by-case basis. */

        if (!w_curr.s_addr_ok || !w_curr.s_data_ok) begin
            // Receive address and data from master

            s_awready = !w_curr.s_addr_ok;
            s_wready = !w_curr.s_data_ok;

            w_next.s_addr_ok = w_curr.s_addr_ok || s_awvalid;
            w_next.s_data_ok = w_curr.s_data_ok || s_wvalid;
            
            if (!w_curr.s_addr_ok) begin
                w_next.addr = s_awaddr;
                w_next.prot = s_awprot;
            end

            if (!w_curr.s_data_ok) begin
                w_next.data = s_wdata;
                w_next.strb = s_wstrb;
            end
        end
        else if (w_curr_rest != 0) begin
            // Unaligned access detected.

            m_awvalid = !w_curr.m_addr_ok;
            m_wvalid = !w_curr.m_data_ok;
            m_bready = !w_curr.m_resp_ok;

            m_awaddr[ADDR_WIDTH-1:REST_WIDTH] = w_curr_quot + 1;
            m_awprot = w_curr.prot;
            m_wdata = w_curr.data >> ELEM_WIDTH * (STRB_WIDTH - w_curr_rest);
            m_wstrb = w_curr.strb >> (STRB_WIDTH - w_curr_rest);

            w_next.m_addr_ok = w_curr.m_addr_ok || m_awready;
            w_next.m_data_ok = w_curr.m_data_ok || m_wready;
            w_next.m_resp_ok = w_curr.m_resp_ok || m_bvalid;

            if(w_curr.m_addr_ok && w_curr.m_data_ok & w_curr.m_resp_ok) begin
                w_next.m_addr_ok = 0;
                w_next.m_data_ok = 0;
                w_next.m_resp_ok = 0;
                w_next.addr[REST_WIDTH-1:0] = 0; // w_curr_rest = 0
                w_next.shift = w_curr_rest;
            end
        end
        else if (!w_curr.m_addr_ok || !w_curr.m_data_ok || !w_curr.m_resp_ok) begin
            // Receive data.

            m_awvalid = !w_curr.m_addr_ok;
            m_wvalid = !w_curr.m_data_ok;
            m_bready = !w_curr.m_resp_ok;

            m_awaddr[ADDR_WIDTH-1:REST_WIDTH] = w_curr_quot;
            m_awprot = w_curr.prot;
            m_wdata = w_curr.data << ELEM_WIDTH * w_curr.shift;
            m_wstrb = w_curr.strb << w_curr.shift;
            
            w_next.m_addr_ok = w_curr.m_addr_ok || m_awready;
            w_next.m_data_ok = w_curr.m_data_ok || m_wready;
            w_next.m_resp_ok = w_curr.m_resp_ok || m_bvalid;

            if(!w_curr.m_resp_ok) begin
                w_next.resp = m_bresp;
            end
        end
        else begin
            // Relay response to master.

            s_bvalid = 1;

            s_bresp = w_curr.resp;

            if(s_bready) begin
                w_next.s_addr_ok = 0;
                w_next.s_data_ok = 0;
                w_next.s_resp_ok = 0;
                w_next.m_addr_ok = 0;
                w_next.m_data_ok = 0;
                w_next.m_resp_ok = 0;
                w_next.shift = 0;
                w_next.addr = 0;
                w_next.prot = 0;
                w_next.data = 0;
                w_next.strb = 0;
                w_next.resp = 0;
            end
        end
    end

    /* Read */

    always_ff @(posedge clk) begin
        if (rst) begin
            r_curr.s_addr_ok <= 0;
            r_curr.m_addr_ok <= 0;
            r_curr.m_data_ok <= 0;
            r_curr.shift <= 0;
            r_curr.addr <= 0;
            r_curr.prot <= 0;
            r_curr.data1 <= 0;
            r_curr.data2 <= 0;
            r_curr.resp <= 0;
        end
        else begin
            r_curr <= r_next;
        end
    end

    assign r_curr_quot = r_curr.addr[ADDR_WIDTH-1:REST_WIDTH];
    assign r_curr_rest = r_curr.addr[REST_WIDTH-1:0];
 
    always_comb begin
        
        /* First, set everything to the default value. */

        s_arready = 0;
        s_rdata = 0;
        s_rresp = 0;
        s_rvalid = 0;

        m_arvalid = 0;
        m_rready = 0;
        m_araddr = 0;
        m_arprot = 0;

        r_next.s_addr_ok = r_curr.s_addr_ok;
        r_next.m_addr_ok = r_curr.m_addr_ok;
        r_next.m_data_ok = r_curr.m_data_ok;
        r_next.shift = r_curr.shift;
        r_next.addr = r_curr.addr;
        r_next.prot = r_curr.prot;
        r_next.data1 = r_curr.data1;
        r_next.data2 = r_curr.data2;
        r_next.resp = r_curr.resp;

        /* Now, make changes as required on a case-by-case basis. */

        if (!r_curr.s_addr_ok) begin
            // Receive address from master

            s_arready = 1;

            r_next.s_addr_ok = s_arvalid;
            r_next.addr = s_araddr;
            r_next.prot = s_arprot;
        end
        else if (r_curr_rest != 0) begin
            // Unaligned access detected.

            m_arvalid = !r_curr.m_addr_ok;
            m_rready = !r_curr.m_data_ok;

            m_araddr[ADDR_WIDTH-1:REST_WIDTH] = r_curr_quot + 1;
            m_arprot = r_curr.prot;
            r_next.data1 = m_rdata << ELEM_WIDTH * (STRB_WIDTH - r_curr_rest);
            r_next.resp = m_rresp;
            
            r_next.m_addr_ok = r_curr.m_addr_ok || m_arready;
            r_next.m_data_ok = r_curr.m_data_ok || m_rvalid;

            if(r_curr.m_addr_ok && r_curr.m_data_ok) begin
                r_next.m_addr_ok = 0;
                r_next.m_data_ok = 0;
                r_next.addr[REST_WIDTH-1:0] = 0; // r_curr_rest = 0
                r_next.shift = r_curr_rest;
            end
        end
        else if (!r_curr.m_addr_ok || !r_curr.m_data_ok) begin
            // Receive response from slave.

            m_arvalid = !r_curr.m_addr_ok;
            m_rready = !r_curr.m_data_ok;

            m_araddr[ADDR_WIDTH-1:REST_WIDTH] = r_curr_quot;
            m_arprot = r_curr.prot;
            r_next.data2 = m_rdata >> ELEM_WIDTH * r_curr.shift;
            r_next.resp = m_rresp;

            r_next.m_addr_ok = r_curr.m_addr_ok || m_arready;
            r_next.m_data_ok = r_curr.m_data_ok || m_rvalid;
        end
        else begin
            // Relay response to master.

            s_rvalid = 1;

            s_rdata = r_curr.data1 | r_curr.data2;
            s_rresp = r_curr.resp;

            if (s_rready) begin
                r_next.s_addr_ok = 0;
                r_next.m_addr_ok = 0;
                r_next.m_data_ok = 0;
                r_next.shift = 0;
                r_next.addr = 0;
                r_next.prot = 0;
                r_next.data1 = 0;
                r_next.data2 = 0;
                r_next.resp = 0;               
            end
        end
    end

endmodule