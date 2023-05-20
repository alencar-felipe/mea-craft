module top (
    input logic clk,
    input logic rst,

    output logic uart_tx,
    input logic uart_rx
);
    logic irq;

    logic [31: 0] core_awaddr;
    logic [ 2: 0] core_awprot;
    logic         core_awvalid;
    logic         core_awready;
    logic [31: 0] core_wdata;
    logic [ 3: 0] core_wstrb;
    logic         core_wvalid;
    logic         core_wready;
    logic [ 1: 0] core_bresp;
    logic         core_bvalid;
    logic         core_bready;
    logic [31: 0] core_araddr;
    logic [ 2: 0] core_arprot;
    logic         core_arvalid;
    logic         core_arready;
    logic [31: 0] core_rdata;
    logic [ 1: 0] core_rresp;
    logic         core_rvalid;
    logic         core_rready;

    logic [31: 0] gpu_awaddr;
    logic [ 2: 0] gpu_awprot;
    logic         gpu_awvalid;
    logic         gpu_awready;
    logic [31: 0] gpu_wdata;
    logic [ 3: 0] gpu_wstrb;
    logic         gpu_wvalid;
    logic         gpu_wready;
    logic [ 1: 0] gpu_bresp;
    logic         gpu_bvalid;
    logic         gpu_bready;
    logic [31: 0] gpu_araddr;
    logic [ 2: 0] gpu_arprot;
    logic         gpu_arvalid;
    logic         gpu_arready;
    logic [31: 0] gpu_rdata;
    logic [ 1: 0] gpu_rresp;
    logic         gpu_rvalid;
    logic         gpu_rready;

    logic [31: 0] rom_bootldr_awaddr;
    logic [ 2: 0] rom_bootldr_awprot;
    logic         rom_bootldr_awvalid;
    logic         rom_bootldr_awready;
    logic [31: 0] rom_bootldr_wdata;
    logic [ 3: 0] rom_bootldr_wstrb;
    logic         rom_bootldr_wvalid;
    logic         rom_bootldr_wready;
    logic [ 1: 0] rom_bootldr_bresp;
    logic         rom_bootldr_bvalid;
    logic         rom_bootldr_bready;
    logic [31: 0] rom_bootldr_araddr;
    logic [ 2: 0] rom_bootldr_arprot;
    logic         rom_bootldr_arvalid;
    logic         rom_bootldr_arready;
    logic [31: 0] rom_bootldr_rdata;
    logic [ 1: 0] rom_bootldr_rresp;
    logic         rom_bootldr_rvalid;
    logic         rom_bootldr_rready;

    logic [14: 0] ram_awaddr;
    logic [ 2: 0] ram_awprot;
    logic         ram_awvalid;
    logic         ram_awready;
    logic [31: 0] ram_wdata;
    logic [ 3: 0] ram_wstrb;
    logic         ram_wvalid;
    logic         ram_wready;
    logic [ 1: 0] ram_bresp;
    logic         ram_bvalid;
    logic         ram_bready;
    logic [14: 0] ram_araddr;
    logic [ 2: 0] ram_arprot;
    logic         ram_arvalid;
    logic         ram_arready;
    logic [31: 0] ram_rdata;
    logic [ 1: 0] ram_rresp;
    logic         ram_rvalid;
    logic         ram_rready;

    logic [14: 0] ram_aligner_awaddr;
    logic [ 2: 0] ram_aligner_awprot;
    logic         ram_aligner_awvalid;
    logic         ram_aligner_awready;
    logic [31: 0] ram_aligner_wdata;
    logic [ 3: 0] ram_aligner_wstrb;
    logic         ram_aligner_wvalid;
    logic         ram_aligner_wready;
    logic [ 1: 0] ram_aligner_bresp;
    logic         ram_aligner_bvalid;
    logic         ram_aligner_bready;
    logic [14: 0] ram_aligner_araddr;
    logic [ 2: 0] ram_aligner_arprot;
    logic         ram_aligner_arvalid;
    logic         ram_aligner_arready;
    logic [31: 0] ram_aligner_rdata;
    logic [ 1: 0] ram_aligner_rresp;
    logic         ram_aligner_rvalid;
    logic         ram_aligner_rready;

    logic [15: 0] frame_awaddr;
    logic [ 2: 0] frame_awprot;
    logic         frame_awvalid;
    logic         frame_awready;
    logic [31: 0] frame_wdata;
    logic [ 3: 0] frame_wstrb;
    logic         frame_wvalid;
    logic         frame_wready;
    logic [ 1: 0] frame_bresp;
    logic         frame_bvalid;
    logic         frame_bready;
    logic [15: 0] frame_araddr;
    logic [ 2: 0] frame_arprot;
    logic         frame_arvalid;
    logic         frame_arready;
    logic [31: 0] frame_rdata;
    logic [ 1: 0] frame_rresp;
    logic         frame_rvalid;
    logic         frame_rready;

    logic [31: 0] peripherals_awaddr;
    logic [ 2: 0] peripherals_awprot;
    logic         peripherals_awvalid;
    logic         peripherals_awready;
    logic [31: 0] peripherals_wdata;
    logic [ 3: 0] peripherals_wstrb;
    logic         peripherals_wvalid;
    logic         peripherals_wready;
    logic [ 1: 0] peripherals_bresp;
    logic         peripherals_bvalid;
    logic         peripherals_bready;
    logic [31: 0] peripherals_araddr;
    logic [ 2: 0] peripherals_arprot;
    logic         peripherals_arvalid;
    logic         peripherals_arready;
    logic [31: 0] peripherals_rdata;
    logic [ 1: 0] peripherals_rresp;
    logic         peripherals_rvalid;
    logic         peripherals_rready;

    core core (
        .clk (clk),
        .rst (rst),
        .irq (irq),

        .awaddr (core_awaddr),
        .awprot (core_awprot),
        .awvalid (core_awvalid),
        .awready (core_awready),
        .wdata (core_wdata),
        .wstrb (core_wstrb),
        .wvalid (core_wvalid),
        .wready (core_wready),
        .bresp (core_bresp),
        .bvalid (core_bvalid),
        .bready (core_bready),
        .araddr (core_araddr),
        .arprot (core_arprot),
        .arvalid (core_arvalid),
        .arready (core_arready),
        .rdata (core_rdata),
        .rresp (core_rresp),
        .rvalid (core_rvalid),
        .rready (core_rready)
    );

    assign irq = 0;

    assign gpu_awaddr = 0;
    assign gpu_awprot = 0;
    assign gpu_awvalid = 0;
    assign gpu_wdata = 0;
    assign gpu_wstrb = 0;
    assign gpu_wvalid = 0;
    assign gpu_bready = 1;
    assign gpu_araddr = 0;
    assign gpu_arprot = 0;
    assign gpu_arvalid = 0;
    assign gpu_rready = 1;

    rom_bootldr rom_bootldr (
        .clk (clk),
        .rst (rst),

        .araddr (rom_bootldr_araddr),
        .arprot (rom_bootldr_arprot),
        .arvalid (rom_bootldr_arvalid),
        .arready (rom_bootldr_arready),
        .rdata (rom_bootldr_rdata),
        .rresp (rom_bootldr_rresp),
        .rvalid (rom_bootldr_rvalid),
        .rready (rom_bootldr_rready)
    );

    assign rom_bootldr_awready = 1;
    assign rom_bootldr_wready = 1;
    assign rom_bootldr_bresp = 0;
    assign rom_bootldr_bvalid = 0;

    axil_ram #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (15),
        .STRB_WIDTH (32/8)
    ) ram (
        .clk (clk),
        .rst (rst),

        .s_axil_awaddr (ram_awaddr),
        .s_axil_awprot (ram_awprot),
        .s_axil_awvalid (ram_awvalid),
        .s_axil_awready (ram_awready),
        .s_axil_wdata (ram_wdata),
        .s_axil_wstrb (ram_wstrb),
        .s_axil_wvalid (ram_wvalid),
        .s_axil_wready (ram_wready),
        .s_axil_bresp (ram_bresp),
        .s_axil_bvalid (ram_bvalid),
        .s_axil_bready (ram_bready),
        .s_axil_araddr (ram_araddr),
        .s_axil_arprot (ram_arprot),
        .s_axil_arvalid (ram_arvalid),
        .s_axil_arready (ram_arready),
        .s_axil_rdata (ram_rdata),
        .s_axil_rresp (ram_rresp),
        .s_axil_rvalid (ram_rvalid),
        .s_axil_rready (ram_rready)
    );

    aligner #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (15),
        .STRB_WIDTH (32/8)
    ) ram_aligner (
        .clk (clk),
        .rst (rst),

        .s_awaddr (ram_aligner_awaddr),
        .s_awprot (ram_aligner_awprot),
        .s_awvalid (ram_aligner_awvalid),
        .s_awready (ram_aligner_awready),
        .s_wdata (ram_aligner_wdata),
        .s_wstrb (ram_aligner_wstrb),
        .s_wvalid (ram_aligner_wvalid),
        .s_wready (ram_aligner_wready),
        .s_bresp (ram_aligner_bresp),
        .s_bvalid (ram_aligner_bvalid),
        .s_bready (ram_aligner_bready),
        .s_araddr (ram_aligner_araddr),
        .s_arprot (ram_aligner_arprot),
        .s_arvalid (ram_aligner_arvalid),
        .s_arready (ram_aligner_arready),
        .s_rdata (ram_aligner_rdata),
        .s_rresp (ram_aligner_rresp),
        .s_rvalid (ram_aligner_rvalid),
        .s_rready (ram_aligner_rready),

        .m_awaddr (ram_awaddr),
        .m_awprot (ram_awprot),
        .m_awvalid (ram_awvalid),
        .m_awready (ram_awready),
        .m_wdata (ram_wdata),
        .m_wstrb (ram_wstrb),
        .m_wvalid (ram_wvalid),
        .m_wready (ram_wready),
        .m_bresp (ram_bresp),
        .m_bvalid (ram_bvalid),
        .m_bready (ram_bready),
        .m_araddr (ram_araddr),
        .m_arprot (ram_arprot),
        .m_arvalid (ram_arvalid),
        .m_arready (ram_arready),
        .m_rdata (ram_rdata),
        .m_rresp (ram_rresp),
        .m_rvalid (ram_rvalid),
        .m_rready (ram_rready)
    );

    axil_ram #(
        .DATA_WIDTH (12),
        .ADDR_WIDTH (19),
        .STRB_WIDTH (12/4)
    ) frame (
        .clk (clk),
        .rst (rst),

        .s_axil_awaddr (frame_awaddr),
        .s_axil_awprot (frame_awprot),
        .s_axil_awvalid (frame_awvalid),
        .s_axil_awready (frame_awready),
        .s_axil_wdata (frame_wdata),
        .s_axil_wstrb (frame_wstrb),
        .s_axil_wvalid (frame_wvalid),
        .s_axil_wready (frame_wready),
        .s_axil_bresp (frame_bresp),
        .s_axil_bvalid (frame_bvalid),
        .s_axil_bready (frame_bready),
        .s_axil_araddr (frame_araddr),
        .s_axil_arprot (frame_arprot),
        .s_axil_arvalid (frame_arvalid),
        .s_axil_arready (frame_arready),
        .s_axil_rdata (frame_rdata),
        .s_axil_rresp (frame_rresp),
        .s_axil_rvalid (frame_rvalid),
        .s_axil_rready (frame_rready)
    );

    peripherals peripherals (
        .clk (clk),
        .rst (rst),

        .awaddr (peripherals_awaddr),
        .awprot (peripherals_awprot),
        .awvalid (peripherals_awvalid),
        .awready (peripherals_awready),
        .wdata (peripherals_wdata),
        .wstrb (peripherals_wstrb),
        .wvalid (peripherals_wvalid),
        .wready (peripherals_wready),
        .bresp (peripherals_bresp),
        .bvalid (peripherals_bvalid),
        .bready (peripherals_bready),
        .araddr (peripherals_araddr),
        .arprot (peripherals_arprot),
        .arvalid (peripherals_arvalid),
        .arready (peripherals_arready),
        .rdata (peripherals_rdata),
        .rresp (peripherals_rresp),
        .rvalid (peripherals_rvalid),
        .rready (peripherals_rready),

        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );

    axil_crossbar_wrap_2x4 #(
        .M00_BASE_ADDR (32'h00000000),  // rom
        .M01_BASE_ADDR (32'h10000000),  // ram
        .M02_BASE_ADDR (32'h20000000),  // frame
        .M03_BASE_ADDR (32'h30000000)   // pheripherals
    ) axil_crossbar_wrap_2x4 (
        .clk (clk),
        .rst (rst),

        .s00_axil_awaddr (core_awaddr),
        .s00_axil_awprot (core_awprot),
        .s00_axil_awvalid (core_awvalid),
        .s00_axil_awready (core_awready),
        .s00_axil_wdata (core_wdata),
        .s00_axil_wstrb (core_wstrb),
        .s00_axil_wvalid (core_wvalid),
        .s00_axil_wready (core_wready),
        .s00_axil_bresp (core_bresp),
        .s00_axil_bvalid (core_bvalid),
        .s00_axil_bready (core_bready),
        .s00_axil_araddr (core_araddr),
        .s00_axil_arprot (core_arprot),
        .s00_axil_arvalid (core_arvalid),
        .s00_axil_arready (core_arready),
        .s00_axil_rdata (core_rdata),
        .s00_axil_rresp (core_rresp),
        .s00_axil_rvalid (core_rvalid),
        .s00_axil_rready (core_rready),

        .s01_axil_awaddr (gpu_awaddr),
        .s01_axil_awprot (gpu_awprot),
        .s01_axil_awvalid (gpu_awvalid),
        .s01_axil_awready (gpu_awready),
        .s01_axil_wdata (gpu_wdata),
        .s01_axil_wstrb (gpu_wstrb),
        .s01_axil_wvalid (gpu_wvalid),
        .s01_axil_wready (gpu_wready),
        .s01_axil_bresp (gpu_bresp),
        .s01_axil_bvalid (gpu_bvalid),
        .s01_axil_bready (gpu_bready),
        .s01_axil_araddr (gpu_araddr),
        .s01_axil_arprot (gpu_arprot),
        .s01_axil_arvalid (gpu_arvalid),
        .s01_axil_arready (gpu_arready),
        .s01_axil_rdata (gpu_rdata),
        .s01_axil_rresp (gpu_rresp),
        .s01_axil_rvalid (gpu_rvalid),
        .s01_axil_rready (gpu_rready),

        .m00_axil_awaddr (rom_bootldr_awaddr),
        .m00_axil_awprot (rom_bootldr_awprot),
        .m00_axil_awvalid (rom_bootldr_awvalid),
        .m00_axil_awready (rom_bootldr_awready),
        .m00_axil_wdata (rom_bootldr_wdata),
        .m00_axil_wstrb (rom_bootldr_wstrb),
        .m00_axil_wvalid (rom_bootldr_wvalid),
        .m00_axil_wready (rom_bootldr_wready),
        .m00_axil_bresp (rom_bootldr_bresp),
        .m00_axil_bvalid (rom_bootldr_bvalid),
        .m00_axil_bready (rom_bootldr_bready),
        .m00_axil_araddr (rom_bootldr_araddr),
        .m00_axil_arprot (rom_bootldr_arprot),
        .m00_axil_arvalid (rom_bootldr_arvalid),
        .m00_axil_arready (rom_bootldr_arready),
        .m00_axil_rdata (rom_bootldr_rdata),
        .m00_axil_rresp (rom_bootldr_rresp),
        .m00_axil_rvalid (rom_bootldr_rvalid),
        .m00_axil_rready (rom_bootldr_rready),

        .m01_axil_awaddr (ram_aligner_awaddr),
        .m01_axil_awprot (ram_aligner_awprot),
        .m01_axil_awvalid (ram_aligner_awvalid),
        .m01_axil_awready (ram_aligner_awready),
        .m01_axil_wdata (ram_aligner_wdata),
        .m01_axil_wstrb (ram_aligner_wstrb),
        .m01_axil_wvalid (ram_aligner_wvalid),
        .m01_axil_wready (ram_aligner_wready),
        .m01_axil_bresp (ram_aligner_bresp),
        .m01_axil_bvalid (ram_aligner_bvalid),
        .m01_axil_bready (ram_aligner_bready),
        .m01_axil_araddr (ram_aligner_araddr),
        .m01_axil_arprot (ram_aligner_arprot),
        .m01_axil_arvalid (ram_aligner_arvalid),
        .m01_axil_arready (ram_aligner_arready),
        .m01_axil_rdata (ram_aligner_rdata),
        .m01_axil_rresp (ram_aligner_rresp),
        .m01_axil_rvalid (ram_aligner_rvalid),
        .m01_axil_rready (ram_aligner_rready),

        .m02_axil_awaddr (frame_awaddr),
        .m02_axil_awprot (frame_awprot),
        .m02_axil_awvalid (frame_awvalid),
        .m02_axil_awready (frame_awready),
        .m02_axil_wdata (frame_wdata),
        .m02_axil_wstrb (frame_wstrb),
        .m02_axil_wvalid (frame_wvalid),
        .m02_axil_wready (frame_wready),
        .m02_axil_bresp (frame_bresp),
        .m02_axil_bvalid (frame_bvalid),
        .m02_axil_bready (frame_bready),
        .m02_axil_araddr (frame_araddr),
        .m02_axil_arprot (frame_arprot),
        .m02_axil_arvalid (frame_arvalid),
        .m02_axil_arready (frame_arready),
        .m02_axil_rdata (frame_rdata),
        .m02_axil_rresp (frame_rresp),
        .m02_axil_rvalid (frame_rvalid),
        .m02_axil_rready (frame_rready),

        .m03_axil_awaddr (peripherals_awaddr),
        .m03_axil_awprot (peripherals_awprot),
        .m03_axil_awvalid (peripherals_awvalid),
        .m03_axil_awready (peripherals_awready),
        .m03_axil_wdata (peripherals_wdata),
        .m03_axil_wstrb (peripherals_wstrb),
        .m03_axil_wvalid (peripherals_wvalid),
        .m03_axil_wready (peripherals_wready),
        .m03_axil_bresp (peripherals_bresp),
        .m03_axil_bvalid (peripherals_bvalid),
        .m03_axil_bready (peripherals_bready),
        .m03_axil_araddr (peripherals_araddr),
        .m03_axil_arprot (peripherals_arprot),
        .m03_axil_arvalid (peripherals_arvalid),
        .m03_axil_arready (peripherals_arready),
        .m03_axil_rdata (peripherals_rdata),
        .m03_axil_rresp (peripherals_rresp),
        .m03_axil_rvalid (peripherals_rvalid),
        .m03_axil_rready (peripherals_rready)
    );

endmodule