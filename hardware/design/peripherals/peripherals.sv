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
    parameter UART_ADDR = 24'h000000;

    typedef enum logic [1:0] {
        RESP_OKAY = 2'b00,
        RESP_DECERR = 2'b01,
        RESP_SLVERR = 2'b10,
        RESP_EXOKAY = 2'b11
    } resp_t;

    typedef enum {
        WRITE_STEP_ADDR,
        WRITE_STEP_DATA,
        WRITE_STEP_EXEC,
        WRITE_STEP_RESP
    } write_step_t;

    typedef struct packed {
        write_step_t step;
        logic [23: 0] addr;
        logic [31: 0] data;
        logic [ 3: 0] strb;
        logic [ 1: 0] resp;
    } write_state_t;

    typedef enum {
        READ_STEP_ADDR,
        READ_STEP_EXEC,
        READ_STEP_DATA
    } read_step_t;

    typedef struct packed {
        read_step_t step;
        logic [23: 0] addr;
        logic [31: 0] data;
        logic [ 1: 0] resp;
    } read_state_t;

    logic [7:0] uart_din;
    logic uart_din_valid;
    logic uart_din_ready;
    logic [7:0] uart_dout;
    logic uart_dout_valid;
    logic uart_dout_ready;

    write_state_t write_curr;
    write_state_t write_next;

    read_state_t read_curr;
    read_state_t read_next;

    uart uart (
        .clk (clk),
        .rst (rst),
        .din (uart_din),
        .din_valid (uart_din_valid),
        .din_ready (uart_din_ready),
        .dout (uart_dout),
        .dout_valid (uart_dout_valid),
        .dout_ready (uart_dout_ready),
        .tx (uart_tx),
        .rx (uart_rx)
    );

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            write_curr.step <= WRITE_STEP_ADDR;
            write_curr.addr <= 0;
            write_curr.data <= 0;
            write_curr.strb <= 0;
            write_curr.resp <= 0;
        end
        else begin
            write_curr <= write_next;
        end
    end

    always_comb begin

        /* First, set everything to the default value. */

        awready = 0;
        wready = 0;
        bvalid = 0;
        bresp = 0;

        write_next.step = write_curr.step;
        write_next.addr = write_curr.addr;
        write_next.data = write_curr.data;
        write_next.strb = write_curr.strb;
        write_next.resp = write_curr.resp;

        uart_din = 0;
        uart_din_valid = 0;

        /* Now, make changes as required on a case-by-case basis. */

        case (write_curr.step)
            
            // WRITE_STEP_ADDR
            default: begin
                awready = 1;
                
                write_next.addr = awaddr;

                if (awvalid) begin
                    write_next.step = WRITE_STEP_DATA;
                end
            end

            WRITE_STEP_DATA: begin
                wready = 1;

                write_next.data = wdata;
                write_next.strb = wstrb;

                if (wvalid) begin
                    write_next.step = WRITE_STEP_EXEC;
                end
            end

            WRITE_STEP_EXEC: case (write_curr.addr)
                    
                UART_ADDR: begin
                    uart_din = write_curr.data;
                    uart_din_valid = 1;
                    
                    write_next.resp = RESP_OKAY;

                    if (uart_din_ready) begin
                        write_next.step = WRITE_STEP_RESP;
                    end
                end

                default: begin
                    write_next.step = WRITE_STEP_RESP;
                    write_next.resp = RESP_DECERR;
                end

            endcase

            WRITE_STEP_RESP: begin
                bvalid = 1;
                bresp = write_curr.resp;

                if (bready) begin
                    write_next.step = WRITE_STEP_ADDR;
                end
            end

        endcase

    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            read_curr.step <= READ_STEP_ADDR;
            read_curr.addr <= 0;
            read_curr.data <= 0;
            read_curr.resp <= 0;
        end
        else begin
            read_curr <= read_next;
        end
    end

    always_comb begin

        /* First, set everything to the default value. */

        arready = 0;
        rdata = 0;
        rresp = 0;
        rvalid = 0;

        read_next.step = read_curr.step;
        read_next.addr = read_curr.addr;
        read_next.data = read_curr.data;
        read_next.resp = read_curr.data;

        uart_dout_ready = 0;

        /* Now, make changes as required on a case-by-case basis. */

        case (read_curr.step)

            // READ_STEP_ADDR
            default: begin
                arready = 1;
                
                read_next.addr = araddr;

                if (arvalid) begin
                    read_next.step = READ_STEP_EXEC;
                end
            end

            READ_STEP_EXEC: case (read_curr.addr)
                    
                UART_ADDR: begin
                    uart_dout_ready = 1;

                    read_next.data = uart_dout;
                    read_next.resp = RESP_OKAY;

                    if (uart_dout_valid) begin
                        read_next.step = READ_STEP_DATA;
                    end
                end

                default: begin
                    read_next.step = READ_STEP_DATA;
                    read_next.resp = RESP_DECERR;
                end

            endcase

            WRITE_STEP_DATA: begin
                rvalid = 1;
                rdata = read_curr.data;
                rresp = read_curr.resp;

                if (rready) begin
                    read_next.step = READ_STEP_ADDR;
                end
            end

        endcase

    end

endmodule