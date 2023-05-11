`include "types.sv"

module csr_file (
    input clk,
    input rst,
    input write_en,
    input csr_addr_t addr,
    input word_t din,
    output word_t dout
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
        map[6] = ISA_CSR_ADDR_MIP;
    end

    always_comb begin
        integer i;

        dout = 0; // default value

        for(i = 0; i <= 6; i++) begin
            if(addr == map[i]) begin
                dout = data[i];
            end
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        integer i;

        if (rst) begin
            for(i = 0; i <= 6; i++) begin
                data[i] <= 0;
            end
        end
        else if (write_en) begin
            for(i = 0; i <= 6; i++) begin
                if(addr == map[i]) begin
                    data[i] <= din;
                end
            end
        end
    end
    
endmodule