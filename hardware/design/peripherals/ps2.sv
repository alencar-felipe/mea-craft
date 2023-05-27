module ps2(
    input  logic clk,
    input  logic rst,

    input  logic [0:0]  araddr,
    input  logic [2:0]  arprot,
    input  logic        arvalid,
    output logic        arready,
    output logic [31:0] rdata,
    output logic [1:0]  rresp,
    output logic        rvalid,
    input  logic        rready,

    output logic irq,

    input  logic ps2_clk,
    input  logic ps2_data
);
    localparam AXIL_DATA_WIDTH = 32;
    localparam AXIL_ADDR_WIDTH = 1;

    typedef struct packed {
        logic addr_ok;
        logic data_ok;
        logic resp_ok;
        logic [AXIL_ADDR_WIDTH-1:0] addr;
        logic [AXIL_DATA_WIDTH-1:0] data;
    } read_state_t;

    logic ps2_clk_clean;
    logic ps2_data_clean;

    logic ps2_clk_reg;
    logic [3:0] data_counter;
    logic [7:0] next_frame;
    logic [7:0] curr_frame;
    logic frame_valid;
    logic frame_ready;

    logic [AXIL_DATA_WIDTH-1:0] status;

    read_state_t r_curr;
    read_state_t r_next;

    debouncer #(
        .N (10)
    ) ps2_clk_debouncer (
        .clk (clk),
        .rst (rst),
        .in (ps2_clk),
        .out (ps2_clk_clean)
    );

    debouncer #(
        .N (10)
    ) ps2_data_debouncer (
        .clk (clk),
        .rst (rst),
        .in (ps2_data),
        .out (ps2_data_clean)
    );

    assign status = {{AXIL_DATA_WIDTH-1{1'b0}}, frame_valid};
    assign irq = frame_valid;

    /* Receive */

    always_ff @(posedge clk) begin
        if (rst) begin
            ps2_clk_reg <= 1;
            data_counter <= 0;
            next_frame <= 0;
            curr_frame <= 0;
            frame_valid <= 0;
        end
        else begin

            // on negedge
            if (ps2_clk_clean == 0 && ps2_clk_reg == 1) begin 
                case(data_counter)
                    0: ; // start bit
                    1: next_frame[0] <= ps2_data_clean;
                    2: next_frame[1] <= ps2_data_clean;
                    3: next_frame[2] <= ps2_data_clean;
                    4: next_frame[3] <= ps2_data_clean;
                    5: next_frame[4] <= ps2_data_clean;
                    6: next_frame[5] <= ps2_data_clean;
                    7: next_frame[6] <= ps2_data_clean;
                    8: next_frame[7] <= ps2_data_clean;
                    9: ;
                    10: ;
                endcase
                
                if (data_counter < 10) begin
                    data_counter <= data_counter + 1;
                end
                else begin
                    data_counter <= 0;
                    curr_frame <= next_frame;
                    frame_valid <= 1;
                end
            end
            
            ps2_clk_reg <= ps2_clk_clean;

            if(frame_valid && frame_ready) begin
                frame_valid <= 0;
            end
            
        end
    end

    /* AXIL Read */

    always_ff @(posedge clk) begin
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

        frame_ready = 0;

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
                    frame_ready = !r_curr.data_ok;

                    r_next.data_ok = r_curr.data_ok || frame_valid;

                    if(!r_curr.data_ok) begin
                        r_next.data[7:0] = curr_frame;
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