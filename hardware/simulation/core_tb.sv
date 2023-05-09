`include "types.sv"

module core_tb;

    logic clk;
    logic rst;
    
    word_t dout;
    word_t din;
    word_t addr;
    logic write_en;

    byte mem [1023:0];

    core uut (
        .clk (clk),
        .rst (rst),
        .dout (dout),
        .din (din),
        .addr (addr),
        .write_en (write_en)
    );

    initial begin  
        int file, ret;
        file = $fopen("/home/felipe/git/mea-craft/software/build/build.bin", "rb");
        ret = $fread(mem, file);
        $fclose(file);

        clk = 0;
        rst = 1;
        #2 rst = 0;
    end
    
    always #5 clk = ~clk;

    always_ff @(posedge clk) begin
        if (write_en) begin
            mem[addr + 0] <= din[ 7: 0];
            mem[addr + 1] <= din[15: 8];
            mem[addr + 2] <= din[23:16];
            mem[addr + 3] <= din[31:24];
        end
        
        dout[ 7: 0] <= mem[addr + 0];
        dout[15: 8] <= mem[addr + 1];
        dout[23:16] <= mem[addr + 2];
        dout[31:24] <= mem[addr + 3];
    end

endmodule

