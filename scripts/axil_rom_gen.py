#!/usr/bin/env python3
"""
Generates an AXI4-Lite read-only memory from a binary input file
"""

import argparse
from jinja2 import Template
    
template = Template(u"""/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Lite ROM
 */
module {{ module_name }} #
(
    // Width of address bus in bits
    parameter ADDR_WIDTH = {{ address_width }},
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0
)
(
    input  wire                   clk,
    input  wire                   rst,

    input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    input  wire [2:0]             s_axil_arprot,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    output wire [1:0]             s_axil_rresp,
    output wire                   s_axil_rvalid,
    input  wire                   s_axil_rready
);

// Width of data bus in bits
parameter DATA_WIDTH = {{ data_width }}; 
// Width of data bus in words
parameter DATA_WORD_WIDTH = (DATA_WIDTH/8);
// Length of memory in words
parameter MEM_LEN = {{ words | length }};

parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(DATA_WORD_WIDTH);

reg mem_rd_en;

reg s_axil_arready_reg = 1'b0, s_axil_arready_next;
reg [DATA_WIDTH-1:0] s_axil_rdata_reg = {DATA_WIDTH{1'b0}}, s_axil_rdata_next;
reg s_axil_rvalid_reg = 1'b0, s_axil_rvalid_next;
reg [DATA_WIDTH-1:0] s_axil_rdata_pipe_reg = {DATA_WIDTH{1'b0}};
reg s_axil_rvalid_pipe_reg = 1'b0;

// (* RAM_STYLE="BLOCK" *)
reg [DATA_WIDTH-1:0] mem[MEM_LEN-1:0];

wire [VALID_ADDR_WIDTH-1:0] s_axil_araddr_valid = s_axil_araddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);

assign s_axil_arready = s_axil_arready_reg;
assign s_axil_rdata = PIPELINE_OUTPUT ? s_axil_rdata_pipe_reg : s_axil_rdata_reg;
assign s_axil_rresp = 2'b00;
assign s_axil_rvalid = PIPELINE_OUTPUT ? s_axil_rvalid_pipe_reg : s_axil_rvalid_reg;

initial begin{% for word in words %}
    mem[{{ (loop.index - 1) }}] = {{ data_width }}'h{{ '%08x' % word }};{% endfor %}
end

always @* begin
    mem_rd_en = 1'b0;

    s_axil_arready_next = 1'b0;
    s_axil_rvalid_next = s_axil_rvalid_reg && !(s_axil_rready || (PIPELINE_OUTPUT && !s_axil_rvalid_pipe_reg));

    if (s_axil_arvalid && (!s_axil_rvalid || s_axil_rready || (PIPELINE_OUTPUT && !s_axil_rvalid_pipe_reg)) && (!s_axil_arready)) begin
        s_axil_arready_next = 1'b1;
        s_axil_rvalid_next = 1'b1;

        mem_rd_en = 1'b1;
    end
end

always @(posedge clk) begin
    s_axil_arready_reg <= s_axil_arready_next;
    s_axil_rvalid_reg <= s_axil_rvalid_next;

    if (mem_rd_en) begin
        if (s_axil_araddr_valid < MEM_LEN) begin
            s_axil_rdata_reg <= mem[s_axil_araddr_valid];
        end
        else begin
            s_axil_rdata_reg <= 0;
        end
    end

    if (!s_axil_rvalid_pipe_reg || s_axil_rready) begin
        s_axil_rdata_pipe_reg <= s_axil_rdata_reg;
        s_axil_rvalid_pipe_reg <= s_axil_rvalid_reg;
    end

    if (rst) begin
        s_axil_arready_reg <= 1'b0;
        s_axil_rvalid_reg <= 1'b0;
        s_axil_rvalid_pipe_reg <= 1'b0;
    end
end

endmodule

`resetall
""")

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('input_file', help='Input binary file')
    parser.add_argument('-o', '--output-file', default='axil_rom.v',
        help='Output Verilog file')
    parser.add_argument('-m', '--module-name', default='axil_rom',
        help='Verilog module name')
    parser.add_argument('-a', '--address-width', type=int, default=32,
        help='Address width')
    parser.add_argument('-d', '--data-width', type=int, default=32,
        help='Data width in bytes')
    
    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(input_file, output_file='axil_rom.v', module_name='axil_rom',
    address_width=32, data_width=32):
    
    with open(input_file, 'rb') as f:
        data = f.read()

    words = []

    word_width = data_width // 8
    for i in range(0, len(data), word_width):
        word = 0
        for j in range(word_width):
            word += data[i + j] << 8*j
        words += [word]

    verilog = template.render(
        module_name=module_name,
        address_width=address_width,
        data_width=data_width,
        words=words
    )

    with open(output_file, 'w') as f:
        f.write(verilog)
        f.flush()

if __name__ == "__main__":
    main()