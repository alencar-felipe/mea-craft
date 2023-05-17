`include "types.sv"

module core_tb;

    logic clk;
    logic rst;
    logic irq;

    logic [31: 0] awaddr;
    logic [ 2: 0] awprot;
    logic         awvalid;
    logic         awready;
    logic [31: 0] wdata;
    logic [ 3: 0] wstrb;
    logic         wvalid;
    logic         wready;
    logic [ 1: 0] bresp;
    logic         bvalid;
    logic         bready;
    logic [31: 0] araddr;
    logic [ 2: 0] arprot;
    logic         arvalid;
    logic         arready;
    logic [31: 0] rdata;
    logic [ 1: 0] rresp;
    logic         rvalid;
    logic         rready;

    core uut (
        .clk (clk),
        .rst (rst),
        .irq (irq),

        .awaddr (awaddr),
        .awprot (awprot),
        .awvalid (awvalid),
        .awready (awready),
        .wdata (wdata),
        .wstrb (wstrb),
        .wvalid (wvalid),
        .wready (wready),
        .bresp (bresp),
        .bvalid (bvalid),
        .bready (bready),
        .araddr (araddr),
        .arprot (arprot),
        .arvalid (arvalid),
        .arready (arready),
        .rdata (rdata),
        .rresp (rresp),
        .rvalid (rvalid),
        .rready (rready)
    );

    file_ram #(
        .FILE_PATH ("/home/felipe/git/mea-craft/software/build/build.bin")
    ) file_ram (
        .clk (clk),
        .rst (rst),

        .s_axil_awaddr (awaddr[15:0]),
        .s_axil_awprot (awprot),
        .s_axil_awvalid (awvalid),
        .s_axil_awready (awready),
        .s_axil_wdata (wdata),
        .s_axil_wstrb (wstrb),
        .s_axil_wvalid (wvalid),
        .s_axil_wready (wready),
        .s_axil_bresp (bresp),
        .s_axil_bvalid (bvalid),
        .s_axil_bready (bready),
        .s_axil_araddr (araddr[15:0]),
        .s_axil_arprot (arprot),
        .s_axil_arvalid (arvalid),
        .s_axil_arready (arready),
        .s_axil_rdata (rdata),
        .s_axil_rresp (rresp),
        .s_axil_rvalid (rvalid),
        .s_axil_rready (rready)
);

    initial begin  
        clk = 0;
        rst = 1;
        irq = 0;
        #2;
        rst = 0;
        #15000;
        irq = 1;
        #1000;
        irq = 0;
    end
    
    always #5 clk = ~clk;

endmodule

