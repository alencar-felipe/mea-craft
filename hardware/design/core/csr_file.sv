`include "types.sv"

module csr_file #(
    parameter word_t MHARTID = 0
) (
    input logic clk,
    input logic rst,
    input logic write_en,
    input csr_addr_t addr,
    input word_t in,
    output word_t out,

    output word_t mstatus,
    input word_t mcycle
);
    localparam RW_CNT = 6;
    localparam RO_CNT = 1;

    word_t rw_data [RW_CNT-1:0];
    word_t ro_data [RO_CNT-1:0];

    csr_addr_t rw_map [RW_CNT-1:0];
    csr_addr_t ro_map [RO_CNT-1:0];

    initial begin
        rw_map[0] = ISA_CSR_ADDR_MSTATUS;
        rw_map[1] = ISA_CSR_ADDR_MIE;
        rw_map[2] = ISA_CSR_ADDR_MTVEC;
        rw_map[3] = ISA_CSR_ADDR_MSCRATCH;
        rw_map[4] = ISA_CSR_ADDR_MEPC;
        rw_map[5] = ISA_CSR_ADDR_MCAUSE;

        ro_map[0] = ISA_CSR_ADDR_MHARTID;
    end
    
    always_comb begin
        mstatus = rw_data[0];
    
        ro_data[0] = MHARTID;
    end

    always_comb begin
        integer i;

        out = 0;
        for(i = 0; i < RW_CNT; i++) begin
            if(addr == rw_map[i]) begin
                out = rw_data[i];
            end
        end
        for(i = 0; i < RO_CNT; i++) begin
            if(addr == ro_map[i]) begin
                out = ro_data[i];
            end
        end
    end

    always_ff @(posedge clk) begin
        integer i;

        if (rst) begin
            for(i = 0; i < RW_CNT; i++) begin
                rw_data[i] <= 0;
            end
        end
        else if (write_en) begin
            for(i = 0; i < RW_CNT; i++) begin
                if(addr == rw_map[i]) begin
                    rw_data[i] <= in;
                end
            end
        end
    end
    
endmodule