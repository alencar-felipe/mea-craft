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

    output logic uart_tx,
    input  logic uart_rx,

    input  logic ps2_clk,
    input  logic ps2_data,
    output logic ps2_irq,
    
    output logic [31: 0] gpio_out [1:0],
    input  logic [31: 0] gpio_in  [1:0]
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

    logic [0:0]  gpio_awaddr;
    logic [2:0]  gpio_awprot;
    logic        gpio_awvalid;
    logic        gpio_awready;
    logic [31:0] gpio_wdata;
    logic [3:0]  gpio_wstrb;
    logic        gpio_wvalid;
    logic        gpio_wready;
    logic [1:0]  gpio_bresp;
    logic        gpio_bvalid;
    logic        gpio_bready;
    logic [0:0]  gpio_araddr;
    logic [2:0]  gpio_arprot;
    logic        gpio_arvalid;
    logic        gpio_arready;
    logic [31:0] gpio_rdata;
    logic [1:0]  gpio_rresp;
    logic        gpio_rvalid;
    logic        gpio_rready;

    logic [0:0]  ps2_awaddr;
    logic [2:0]  ps2_awprot;
    logic        ps2_awvalid;
    logic        ps2_awready;
    logic [31:0] ps2_wdata;
    logic [3:0]  ps2_wstrb;
    logic        ps2_wvalid;
    logic        ps2_wready;
    logic [1:0]  ps2_bresp;
    logic        ps2_bvalid;
    logic        ps2_bready;
    logic [0:0]  ps2_araddr;
    logic [2:0]  ps2_arprot;
    logic        ps2_arvalid;
    logic        ps2_arready;
    logic [31:0] ps2_rdata;
    logic [1:0]  ps2_rresp;
    logic        ps2_rvalid;
    logic        ps2_rready;

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

    ps2 ps2 (
        .clk (clk),
        .rst (rst),

        .araddr (ps2_araddr),
        .arprot (ps2_arprot),
        .arvalid (ps2_arvalid),
        .arready (ps2_arready),
        .rdata (ps2_rdata),
        .rresp (ps2_rresp),
        .rvalid (ps2_rvalid),
        .rready (ps2_rready),

        .irq (ps2_irq),

        .ps2_clk (ps2_clk),
        .ps2_data (ps2_data)
    );

    assign ps2_awready = 1;
    assign ps2_wready = 1;
    assign ps2_bresp = 0;
    assign ps2_bvalid = 1;

    gpio gpio (
        .clk (clk),
        .rst (rst),

        .awaddr (gpio_awaddr),
        .awprot (gpio_awprot),
        .awvalid (gpio_awvalid),
        .awready (gpio_awready),
        .wdata (gpio_wdata),
        .wstrb (gpio_wstrb),
        .wvalid (gpio_wvalid),
        .wready (gpio_wready),
        .bresp (gpio_bresp),
        .bvalid (gpio_bvalid),
        .bready (gpio_bready),
        .araddr (gpio_araddr),
        .arprot (gpio_arprot),
        .arvalid (gpio_arvalid),
        .arready (gpio_arready),
        .rdata (gpio_rdata),
        .rresp (gpio_rresp),
        .rvalid (gpio_rvalid),
        .rready (gpio_rready),

        .out (gpio_out),
        .in (gpio_in)
    );

    axil_interconnect_wrap_1x3 #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (24),
        .STRB_WIDTH (32/8),
        .M00_BASE_ADDR (24'h000000),
        .M00_ADDR_WIDTH ({1{32'd16}}),
        .M01_BASE_ADDR (24'h010000),
        .M01_ADDR_WIDTH ({1{32'd16}}),
        .M02_BASE_ADDR (24'h020000),
        .M02_ADDR_WIDTH ({1{32'd16}})
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
        .m00_axil_rready (uart_rready),

        .m01_axil_awaddr (gpio_awaddr),
        .m01_axil_awprot (gpio_awprot),
        .m01_axil_awvalid (gpio_awvalid),
        .m01_axil_awready (gpio_awready),
        .m01_axil_wdata (gpio_wdata),
        .m01_axil_wstrb (gpio_wstrb),
        .m01_axil_wvalid (gpio_wvalid),
        .m01_axil_wready (gpio_wready),
        .m01_axil_bresp (gpio_bresp),
        .m01_axil_bvalid (gpio_bvalid),
        .m01_axil_bready (gpio_bready),
        .m01_axil_araddr (gpio_araddr),
        .m01_axil_arprot (gpio_arprot),
        .m01_axil_arvalid (gpio_arvalid),
        .m01_axil_arready (gpio_arready),
        .m01_axil_rdata (gpio_rdata),
        .m01_axil_rresp (gpio_rresp),
        .m01_axil_rvalid (gpio_rvalid),
        .m01_axil_rready (gpio_rready),

        .m02_axil_awaddr (ps2_awaddr),
        .m02_axil_awprot (ps2_awprot),
        .m02_axil_awvalid (ps2_awvalid),
        .m02_axil_awready (ps2_awready),
        .m02_axil_wdata (ps2_wdata),
        .m02_axil_wstrb (ps2_wstrb),
        .m02_axil_wvalid (ps2_wvalid),
        .m02_axil_wready (ps2_wready),
        .m02_axil_bresp (ps2_bresp),
        .m02_axil_bvalid (ps2_bvalid),
        .m02_axil_bready (ps2_bready),
        .m02_axil_araddr (ps2_araddr),
        .m02_axil_arprot (ps2_arprot),
        .m02_axil_arvalid (ps2_arvalid),
        .m02_axil_arready (ps2_arready),
        .m02_axil_rdata (ps2_rdata),
        .m02_axil_rresp (ps2_rresp),
        .m02_axil_rvalid (ps2_rvalid),
        .m02_axil_rready (ps2_rready)
    );
    
endmodule