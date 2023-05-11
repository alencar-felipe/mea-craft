`include "types.sv"

module core_tb;

    logic clk;
    logic rst;
    
    word_t dout;
    word_t din;
    word_t addr;
    mem_ctrl_t ctrl;

    byte mem [4095:0];

    core uut (
        .clk (clk),
        .rst (rst),
        .mem_dout(dout),
        .mem_din(din),
        .mem_addr(addr),
        .mem_ctrl(ctrl)
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
        case (ctrl)
            MEM_CTRL_READ_BYTE: begin
                dout[ 7: 0] <= mem[addr + 0];
                dout[15: 8] <= 0;
                dout[23:16] <= 0;
                dout[31:24] <= 0;
            end
            MEM_CTRL_READ_HALF: begin
                dout[ 7: 0] <= mem[addr + 0];
                dout[15: 8] <= mem[addr + 1];
                dout[23:16] <= 0;
                dout[31:24] <= 0;
            end
            MEM_CTRL_READ_WORD: begin
                dout[ 7: 0] <= mem[addr + 0];
                dout[15: 8] <= mem[addr + 1];
                dout[23:16] <= mem[addr + 2];
                dout[31:24] <= mem[addr + 3];
            end
            MEM_CTRL_STORE_BYTE: begin
                mem[addr + 0] <= din[ 7: 0];
            end
            MEM_CTRL_STORE_HALF: begin
                mem[addr + 0] <= din[ 7: 0];
                mem[addr + 1] <= din[15: 8];
            end
            MEM_CTRL_STORE_WORD: begin
                mem[addr + 0] <= din[ 7: 0];
                mem[addr + 1] <= din[15: 8];
                mem[addr + 2] <= din[23:16];
                mem[addr + 3] <= din[31:24];
            end
        endcase 
    end

endmodule

