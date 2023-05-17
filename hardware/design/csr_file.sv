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
    output word_t mstatus
);

    word_t data [6:0];
    csr_addr_t map [6:0];

    initial begin
        map[0] = ISA_CSR_ADDR_MSTATUS;
        map[1] = ISA_CSR_ADDR_MIE;
        map[2] = ISA_CSR_ADDR_MTVEC;
        map[3] = ISA_CSR_ADDR_MSCRATCH;
        map[4] = ISA_CSR_ADDR_MEPC;
        map[5] = ISA_CSR_ADDR_MCAUSE;
        map[6] = ISA_CSR_ADDR_MHARTID;
    end
    
    assign mstatus = data[0];

    always_comb begin
        integer i;

        out = 0;
        for(i = 0; i <= 6; i++) begin
            if(addr == map[i]) begin
                out = data[i];
            end
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        integer i;

        if (rst) begin
            for(i = 0; i <= 6; i++) begin
                data[i] <= 0;
            end

            data[6] <= MHARTID;
        end
        else if (write_en) begin
            for(i = 0; i <= 6; i++) begin
                if(addr == map[i]) begin
                    data[i] <= in;
                end
            end
        end
    end
    
endmodule