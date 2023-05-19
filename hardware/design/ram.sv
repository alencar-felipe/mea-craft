module ram #(
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

    input  logic [ADDR_WIDTH-1:0]  awaddr,
    input  logic [2:0]             awprot,
    input  logic                   awvalid,
    output logic                   awready,
    input  logic [DATA_WIDTH-1:0]  wdata,
    input  logic [STRB_WIDTH-1:0]  wstrb,
    input  logic                   wvalid,
    output logic                   wready,
    output logic [1:0]             bresp,
    output logic                   bvalid,
    input  logic                   bready,
    input  logic [ADDR_WIDTH-1:0]  araddr,
    input  logic [2:0]             arprot,
    input  logic                   arvalid,
    output logic                   arready,
    output logic [DATA_WIDTH-1:0]  rdata,
    output logic [1:0]             rresp,
    output logic                   rvalid,
    input  logic                   rready
);

    parameter ELEM_WIDTH = DATA_WIDTH / STRB_WIDTH;
    parameter MEM_LEN = 2**ADDR_WIDTH;
    genvar i;

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
        logic [STRB_WIDTH-1:0] strb;
    } write_state_t;

    typedef struct packed {
        logic addr_ok;
        logic [ADDR_WIDTH-1:0] addr;
    } read_state_t;

    logic [ELEM_WIDTH-1:0] mem[MEM_LEN-1:0];

    write_state_t write_curr;
    write_state_t write_next;

    read_state_t read_curr;
    read_state_t read_next;

    logic write_en;

    /* Write */
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            write_curr.addr_ok <= 0;
            write_curr.data_ok <= 0;
            write_curr.addr <= 0;
            write_curr.data <= 0;
            write_curr.strb <= 0;
        end
        else begin
            write_curr <= write_next;
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        awready = 0;
        wready = 0;
        bresp = 0;
        bvalid = 0;

        write_next.addr_ok = write_curr.addr_ok;
        write_next.data_ok = write_curr.data_ok;
        write_next.addr = write_curr.addr;

        /* Now, make changes as required on a case-by-case basis. */

        if (write_curr.addr_ok && write_curr.data_ok) begin
            bresp = 0;
            bvalid = 1;

            if (bready) begin
                write_next.addr_ok = 0;
                write_next.data_ok = 0;
            end
        end
        else begin
            awready = !write_curr.addr_ok;
            wready = !write_curr.data_ok;

            write_next.addr_ok = write_curr.addr_ok || awready;
            write_next.data_ok = write_curr.data_ok || wready;
            
            if (!write_curr.addr_ok) begin
                write_next.addr = awaddr;
            end

            if (!write_curr.data_ok) begin
                write_next.data = wdata;
                write_next.strb = wstrb;
            end
        end

    end

    assign write_en = write_curr.addr_ok && write_curr.data_ok;

    generate
        for(i = 0; i < STRB_WIDTH; i++) begin
            always_ff @(posedge clk, posedge rst) begin
                if (rst || !write_en) begin
                    // EMPTY
                end
                else begin
                    if (write_curr.strb[i]) begin
                        mem[write_curr.addr + i] <= 
                            write_curr.data[((i+1)*ELEM_WIDTH)-1:i*ELEM_WIDTH];
                    end
                end
            end
        end
    endgenerate

    /* Read */

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_curr.addr_ok <= 0;
            read_curr.addr <= 0;
        end
        else begin
            read_curr <= read_next;
        end
    end

    always_comb begin
        
        /* First, set everything to the default value. */

        arready = 0;
        rresp = 0;
        rvalid = 0;

        read_next.addr_ok = read_curr.addr_ok;
        read_next.addr = read_curr.addr;

        /* Now, make changes as required on a case-by-case basis. */

        if (!read_curr.addr_ok) begin
            arready = 1;

            read_next.addr_ok = arvalid;
            read_next.addr = araddr;
        end
        else begin
            rvalid = 1;

            if (rready) begin
                read_next.addr_ok = 0;
                read_next.addr = 0;                
            end
        end

    end

    generate
        for(i = 0; i < STRB_WIDTH; i++) begin
            assign rdata[((i+1)*ELEM_WIDTH)-1:i*ELEM_WIDTH] =
                mem[read_curr.addr + i];
        end
    endgenerate

endmodule