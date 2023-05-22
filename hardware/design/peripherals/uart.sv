// TODO: potencial bug detected on tx (duplicated chars)

module uart #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
) (
    input  logic        clk,
    input  logic        rst,

    input  logic [0:0]  awaddr,
    input  logic [2:0]  awprot,
    input  logic        awvalid,
    output logic        awready,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    input  logic        wvalid,
    output logic        wready,
    output logic [1:0]  bresp,
    output logic        bvalid,
    input  logic        bready,
    input  logic [0:0]  araddr,
    input  logic [2:0]  arprot,
    input  logic        arvalid,
    output logic        arready,
    output logic [31:0] rdata,
    output logic [1:0]  rresp,
    output logic        rvalid,
    input  logic        rready,

    output logic        tx,
    input  logic        rx
);
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 1;
    parameter STRB_WIDTH = (DATA_WIDTH/8);

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic tx_ok;
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

    logic [DATA_BITS-1:0] din;
    logic din_valid;
    logic din_ready;

    logic [DATA_BITS-1:0] dout;
    logic dout_valid;
    logic dout_ready;

    logic [DATA_WIDTH-1:0] status;

    write_state_t w_curr;
    write_state_t w_next;

    read_state_t r_curr;
    read_state_t r_next;

    initial begin
        if (DATA_BITS > 32) begin
            $error("Error: DATA_BITS > 32");
            $finish;
        end
    end

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) uart_tx (
        .clk (clk),
        .rst (rst),
        .data (dout),
        .data_valid (dout_valid),
        .data_ready (dout_ready),
        .tx (tx)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) uart_rx (
        .clk (clk),
        .rst (rst),
        .data (din),
        .data_valid (din_valid),
        .data_ready (din_ready),
        .rx (rx)
    );
    
    assign status = {{DATA_WIDTH-2{1'b0}}, din_valid, dout_ready};
    
    /* Write */
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            w_curr.addr_ok <= 0;
            w_curr.data_ok <= 0;
            w_curr.resp_ok <= 0;
            w_curr.tx_ok <= 0;
            w_curr.addr <= 0;
            w_curr.data <= 0;
            w_curr.strb <= 0;
        end
        else begin
            w_curr <= w_next;
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        awready = 0;
        wready = 0;
        bresp = 0;
        bvalid = 0;

        dout = 0;
        dout_valid = 0;

        w_next.addr_ok = w_curr.addr_ok;
        w_next.data_ok = w_curr.data_ok;
        w_next.resp_ok = w_curr.resp_ok;
        w_next.tx_ok = w_curr.tx_ok;
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
        else if (w_curr.addr == 0 && !w_curr.tx_ok) begin
            // Transmit.

            dout_valid = !w_curr.tx_ok;

            dout = w_curr.data[DATA_BITS-1:0];
            
            w_next.tx_ok = w_curr.tx_ok || dout_ready;
        end
        else begin
            // Reset.

            w_next.addr_ok = 0;
            w_next.data_ok = 0;
            w_next.resp_ok = 0;
            w_next.tx_ok = 0;
            w_next.addr = 0;
            w_next.data = 0;
            w_next.strb = 0;
        end

    end

    /* Read */

    always_ff @(posedge clk, posedge rst) begin
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

        din_ready = 0;

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

            case (r_curr.addr)
                0: begin
                    din_ready = !r_curr.data_ok;

                    r_next.data_ok = r_curr.data_ok || din_valid;

                    if(!r_curr.data_ok) begin
                        r_next.data[DATA_BITS-1:0] = din;
                    end
                end

                1: begin
                    r_next.data_ok = 1;
                    r_next.data = status;
                end

                default: begin
                    r_next.data_ok = 1;
                    r_next.data = 0;
                end
            endcase
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