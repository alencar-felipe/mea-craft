module peripherals (
    input  logic         clk,
    input  logic         rst,

    input  logic [23: 0] awaddr,
    input  logic [ 2: 0] awprot,
    input  logic         awvalid,
    output logic         awready,
    input  logic [31: 0] wdata,
    input  logic [ 3: 0] wstrb,
    input  logic         wvalid,
    output logic         wready,
    output logic [ 1: 0] bresp,
    output logic         bvalid,
    input  logic         bready,
    input  logic [23: 0] araddr,
    input  logic [ 2: 0] arprot,
    input  logic         arvalid,
    output logic         arready,
    output logic [31: 0] rdata,
    output logic [ 1: 0] rresp,
    output logic         rvalid,
    input  logic         rready,

    output logic         uart_tx,
    input  logic         uart_rx
);

    logic [0:0]  uart_awaddr;
    logic [2:0]  uart_awprot;
    logic        uart_awvalid;
    logic        uart_awready;
    logic [31:0] uart_wdata;
    logic [3:0]  uart_wstrb;
    logic        uart_wvalid;
    logic        uart_wready;
    logic [1:0]  uart_bresp;
    logic        uart_bvalid;
    logic        uart_bready;
    logic [0:0]  uart_araddr;
    logic [2:0]  uart_arprot;
    logic        uart_arvalid;
    logic        uart_arready;
    logic [31:0] uart_rdata;
    logic [1:0]  uart_rresp;
    logic        uart_rvalid;
    logic        uart_rready;

    uart uart (
        .clk (clk),
        .rst (rst),

        .awaddr (uart_awaddr),
        .awprot (uart_awprot),
        .awvalid (uart_awvalid),
        .awready (uart_awready),
        .wdata (uart_wdata),
        .wstrb (uart_wstrb),
        .wvalid (uart_wvalid),
        .wready (uart_wready),
        .bresp (uart_bresp),
        .bvalid (uart_bvalid),
        .bready (uart_bready),
        .araddr (uart_araddr),
        .arprot (uart_arprot),
        .arvalid (uart_arvalid),
        .arready (uart_arready),
        .rdata (uart_rdata),
        .rresp (uart_rresp),
        .rvalid (uart_rvalid),
        .rready (uart_rready),

        .tx (uart_tx),
        .rx (uart_rx)
    );

    axil_interconnect_wrap_1x1 #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (24),
        .STRB_WIDTH (32/8),
        .M00_BASE_ADDR (0),
        .M00_ADDR_WIDTH ({1{32'd16}})
    ) axil_interconnect (
        .clk (clk),
        .rst (rst),
        
        .s00_axil_awaddr (awaddr),
        .s00_axil_awprot (awprot),
        .s00_axil_awvalid (awvalid),
        .s00_axil_awready (awready),
        .s00_axil_wdata (wdata),
        .s00_axil_wstrb (wstrb),
        .s00_axil_wvalid (wvalid),
        .s00_axil_wready (wready),
        .s00_axil_bresp (bresp),
        .s00_axil_bvalid (bvalid),
        .s00_axil_bready (bready),
        .s00_axil_araddr (araddr),
        .s00_axil_arprot (arprot),
        .s00_axil_arvalid (arvalid),
        .s00_axil_arready (arready),
        .s00_axil_rdata (rdata),
        .s00_axil_rresp (rresp),
        .s00_axil_rvalid (rvalid),
        .s00_axil_rready (rready),

        .m00_axil_awaddr (uart_awaddr),
        .m00_axil_awprot (uart_awprot),
        .m00_axil_awvalid (uart_awvalid),
        .m00_axil_awready (uart_awready),
        .m00_axil_wdata (uart_wdata),
        .m00_axil_wstrb (uart_wstrb),
        .m00_axil_wvalid (uart_wvalid),
        .m00_axil_wready (uart_wready),
        .m00_axil_bresp (uart_bresp),
        .m00_axil_bvalid (uart_bvalid),
        .m00_axil_bready (uart_bready),
        .m00_axil_araddr (uart_araddr),
        .m00_axil_arprot (uart_arprot),
        .m00_axil_arvalid (uart_arvalid),
        .m00_axil_arready (uart_arready),
        .m00_axil_rdata (uart_rdata),
        .m00_axil_rresp (uart_rresp),
        .m00_axil_rvalid (uart_rvalid),
        .m00_axil_rready (uart_rready)
    );
    
endmodule