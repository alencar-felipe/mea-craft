module top (
    input logic          clk,
    input logic          rst,

    output logic         uart_tx,
    input  logic         uart_rx,

    input  logic [31:0] btn,
    output logic [31:0] led,

    output logic [ 3: 0] vga_red,
    output logic [ 3: 0] vga_green,
    output logic [ 3: 0] vga_blue,
    output logic         vga_hsync,
    output logic         vga_vsync,

    input ps2_clk,
    input ps2_data
);
    logic dclk;
    logic drst;

    logic core_irq;
    logic ps2_irq;

    logic [31: 0] gpio_in  [1:0];
    logic [31: 0] gpio_out [1:0];

    logic [31: 0] frame_counter;

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

    logic [31: 0] core_aligner_awaddr;
    logic [ 2: 0] core_aligner_awprot;
    logic         core_aligner_awvalid;
    logic         core_aligner_awready;
    logic [31: 0] core_aligner_wdata;
    logic [ 3: 0] core_aligner_wstrb;
    logic         core_aligner_wvalid;
    logic         core_aligner_wready;
    logic [ 1: 0] core_aligner_bresp;
    logic         core_aligner_bvalid;
    logic         core_aligner_bready;
    logic [31: 0] core_aligner_araddr;
    logic [ 2: 0] core_aligner_arprot;
    logic         core_aligner_arvalid;
    logic         core_aligner_arready;
    logic [31: 0] core_aligner_rdata;
    logic [ 1: 0] core_aligner_rresp;
    logic         core_aligner_rvalid;
    logic         core_aligner_rready;

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

    logic [23: 0] gpu_awaddr;
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
    logic [23: 0] gpu_araddr;
    logic [ 2: 0] gpu_arprot;
    logic         gpu_arvalid;
    logic         gpu_arready;
    logic [31: 0] gpu_rdata;
    logic [ 1: 0] gpu_rresp;
    logic         gpu_rvalid;
    logic         gpu_rready;

    logic [23: 0] peripherals_awaddr;
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
    logic [23: 0] peripherals_araddr;
    logic [ 2: 0] peripherals_arprot;
    logic         peripherals_arvalid;
    logic         peripherals_arready;
    logic [31: 0] peripherals_rdata;
    logic [ 1: 0] peripherals_rresp;
    logic         peripherals_rvalid;
    logic         peripherals_rready;
    
    clkdiv #(
        .DIV (2)
    ) clkdiv (
        .clk_in (clk),
        .rst_in (rst),
        .clk_out (dclk),
        .rst_out (drst)
    );

    core core (
        .clk (dclk),
        .rst (drst),
        .irq (core_irq),

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

    aligner #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (32),
        .STRB_WIDTH (32/8)
    ) core_aligner (
        .clk (dclk),
        .rst (drst),

        .s_awaddr  (core_awaddr),
        .s_awprot  (core_awprot),
        .s_awvalid (core_awvalid),
        .s_awready (core_awready),
        .s_wdata   (core_wdata),
        .s_wstrb   (core_wstrb),
        .s_wvalid  (core_wvalid),
        .s_wready  (core_wready),
        .s_bresp   (core_bresp),
        .s_bvalid  (core_bvalid),
        .s_bready  (core_bready),
        .s_araddr  (core_araddr),
        .s_arprot  (core_arprot),
        .s_arvalid (core_arvalid),
        .s_arready (core_arready),
        .s_rdata   (core_rdata),
        .s_rresp   (core_rresp),
        .s_rvalid  (core_rvalid),
        .s_rready  (core_rready),

        .m_awaddr  (core_aligner_awaddr),
        .m_awprot  (core_aligner_awprot),
        .m_awvalid (core_aligner_awvalid),
        .m_awready (core_aligner_awready),
        .m_wdata   (core_aligner_wdata),
        .m_wstrb   (core_aligner_wstrb),
        .m_wvalid  (core_aligner_wvalid),
        .m_wready  (core_aligner_wready),
        .m_bresp   (core_aligner_bresp),
        .m_bvalid  (core_aligner_bvalid),
        .m_bready  (core_aligner_bready),
        .m_araddr  (core_aligner_araddr),
        .m_arprot  (core_aligner_arprot),
        .m_arvalid (core_aligner_arvalid),
        .m_arready (core_aligner_arready),
        .m_rdata   (core_aligner_rdata),
        .m_rresp   (core_aligner_rresp),
        .m_rvalid  (core_aligner_rvalid),
        .m_rready  (core_aligner_rready)
    );
    
    axil_rom_bootldr rom_bootldr (
        .clk (dclk),
        .rst (drst),

        .s_axil_araddr  (rom_bootldr_araddr),
        .s_axil_arprot  (rom_bootldr_arprot),
        .s_axil_arvalid (rom_bootldr_arvalid),
        .s_axil_arready (rom_bootldr_arready),
        .s_axil_rdata   (rom_bootldr_rdata),
        .s_axil_rresp   (rom_bootldr_rresp),
        .s_axil_rvalid  (rom_bootldr_rvalid),
        .s_axil_rready  (rom_bootldr_rready)
    );

    assign rom_bootldr_awready = 1;
    assign rom_bootldr_wready = 1;
    assign rom_bootldr_bresp = 0;
    assign rom_bootldr_bvalid = 1;

    axil_ram #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (16),
        .STRB_WIDTH (32/8)
    ) ram (
        .clk (dclk),
        .rst (drst),

        .s_axil_awaddr  (ram_awaddr),
        .s_axil_awprot  (ram_awprot),
        .s_axil_awvalid (ram_awvalid),
        .s_axil_awready (ram_awready),
        .s_axil_wdata   (ram_wdata),
        .s_axil_wstrb   (ram_wstrb),
        .s_axil_wvalid  (ram_wvalid),
        .s_axil_wready  (ram_wready),
        .s_axil_bresp   (ram_bresp),
        .s_axil_bvalid  (ram_bvalid),
        .s_axil_bready  (ram_bready),
        .s_axil_araddr  (ram_araddr),
        .s_axil_arprot  (ram_arprot),
        .s_axil_arvalid (ram_arvalid),
        .s_axil_arready (ram_arready),
        .s_axil_rdata   (ram_rdata),
        .s_axil_rresp   (ram_rresp),
        .s_axil_rvalid  (ram_rvalid),
        .s_axil_rready  (ram_rready)
    );

    gpu #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (24),
        .STRB_WIDTH (32/8)
    ) gpu (
        .clk (dclk), // 50 MHz
        .rst (drst),

        .axil_awaddr  (gpu_awaddr),
        .axil_awprot  (gpu_awprot),
        .axil_awvalid (gpu_awvalid),
        .axil_awready (gpu_awready),
        .axil_wdata   (gpu_wdata),
        .axil_wstrb   (gpu_wstrb),
        .axil_wvalid  (gpu_wvalid),
        .axil_wready  (gpu_wready),
        .axil_bresp   (gpu_bresp),
        .axil_bvalid  (gpu_bvalid),
        .axil_bready  (gpu_bready),

        .red   (vga_red),
        .green (vga_green),
        .blue  (vga_blue),

        .hsync (vga_hsync),
        .vsync (vga_vsync),

        .counter (frame_counter)
    );

    peripherals peripherals (
        .clk (dclk),
        .rst (drst),

        .awaddr  (peripherals_awaddr),
        .awprot  (peripherals_awprot),
        .awvalid (peripherals_awvalid),
        .awready (peripherals_awready),
        .wdata   (peripherals_wdata),
        .wstrb   (peripherals_wstrb),
        .wvalid  (peripherals_wvalid),
        .wready  (peripherals_wready),
        .bresp   (peripherals_bresp),
        .bvalid  (peripherals_bvalid),
        .bready  (peripherals_bready),
        .araddr  (peripherals_araddr),
        .arprot  (peripherals_arprot),
        .arvalid (peripherals_arvalid),
        .arready (peripherals_arready),
        .rdata   (peripherals_rdata),
        .rresp   (peripherals_rresp),
        .rvalid  (peripherals_rvalid),
        .rready  (peripherals_rready),

        .uart_tx (uart_tx),
        .uart_rx (uart_rx),

        .gpio_out (gpio_out),
        .gpio_in  (gpio_in),

        .ps2_clk (ps2_clk),
        .ps2_data (ps2_data),
        .ps2_irq (ps2_irq)
    );

    axil_crossbar_wrap_1x4 #(
        .S00_ACCEPT (1),
        .M00_BASE_ADDR (32'h00000000),  // rom
        .M01_BASE_ADDR (32'h10000000),  // ram
        .M02_BASE_ADDR (32'h20000000),  // gpu
        .M03_BASE_ADDR (32'h30000000)   // pheripherals
    ) axil_crossbar_wrap (
        .clk (dclk),
        .rst (drst),

        .s00_axil_awaddr (core_aligner_awaddr),
        .s00_axil_awprot (core_aligner_awprot),
        .s00_axil_awvalid (core_aligner_awvalid),
        .s00_axil_awready (core_aligner_awready),
        .s00_axil_wdata (core_aligner_wdata),
        .s00_axil_wstrb (core_aligner_wstrb),
        .s00_axil_wvalid (core_aligner_wvalid),
        .s00_axil_wready (core_aligner_wready),
        .s00_axil_bresp (core_aligner_bresp),
        .s00_axil_bvalid (core_aligner_bvalid),
        .s00_axil_bready (core_aligner_bready),
        .s00_axil_araddr (core_aligner_araddr),
        .s00_axil_arprot (core_aligner_arprot),
        .s00_axil_arvalid (core_aligner_arvalid),
        .s00_axil_arready (core_aligner_arready),
        .s00_axil_rdata (core_aligner_rdata),
        .s00_axil_rresp (core_aligner_rresp),
        .s00_axil_rvalid (core_aligner_rvalid),
        .s00_axil_rready (core_aligner_rready),

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

        .m01_axil_awaddr (ram_awaddr),
        .m01_axil_awprot (ram_awprot),
        .m01_axil_awvalid (ram_awvalid),
        .m01_axil_awready (ram_awready),
        .m01_axil_wdata (ram_wdata),
        .m01_axil_wstrb (ram_wstrb),
        .m01_axil_wvalid (ram_wvalid),
        .m01_axil_wready (ram_wready),
        .m01_axil_bresp (ram_bresp),
        .m01_axil_bvalid (ram_bvalid),
        .m01_axil_bready (ram_bready),
        .m01_axil_araddr (ram_araddr),
        .m01_axil_arprot (ram_arprot),
        .m01_axil_arvalid (ram_arvalid),
        .m01_axil_arready (ram_arready),
        .m01_axil_rdata (ram_rdata),
        .m01_axil_rresp (ram_rresp),
        .m01_axil_rvalid (ram_rvalid),
        .m01_axil_rready (ram_rready),

        .m02_axil_awaddr (gpu_awaddr),
        .m02_axil_awprot (gpu_awprot),
        .m02_axil_awvalid (gpu_awvalid),
        .m02_axil_awready (gpu_awready),
        .m02_axil_wdata (gpu_wdata),
        .m02_axil_wstrb (gpu_wstrb),
        .m02_axil_wvalid (gpu_wvalid),
        .m02_axil_wready (gpu_wready),
        .m02_axil_bresp (gpu_bresp),
        .m02_axil_bvalid (gpu_bvalid),
        .m02_axil_bready (gpu_bready),
        .m02_axil_araddr (gpu_araddr),
        .m02_axil_arprot (gpu_arprot),
        .m02_axil_arvalid (gpu_arvalid),
        .m02_axil_arready (gpu_arready),
        .m02_axil_rdata (gpu_rdata),
        .m02_axil_rresp (gpu_rresp),
        .m02_axil_rvalid (gpu_rvalid),
        .m02_axil_rready (gpu_rready),

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

    always_comb begin
        gpio_in[0] = btn;
        gpio_in[1] = frame_counter;

        led = gpio_out[0];

        core_irq = gpio_out[1] != gpio_in[1];
    end
endmodule