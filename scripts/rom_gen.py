#!/usr/bin/env python3
"""
Generates an AXI4-Lite read-only memory from a binary input file
"""

import argparse
from jinja2 import Template
    
template = Template(u"""
module {{ module_name }} (
    input  logic clk,
    input  logic rst,

    input  logic [{{ addr_width - 1 }}:0] araddr,
    input  logic [2:0] arprot,
    input  logic arvalid,
    output logic arready,
    output logic [{{ data_width - 1 }}:0] rdata,
    output logic [1:0] rresp,
    output logic rvalid,
    input  logic rready
);
    parameter DATA_WIDTH = {{ data_width }};
    parameter ADDR_WIDTH = {{ addr_width }};
    parameter STRB_WIDTH = {{ strb_width }};

    parameter ELEM_WIDTH = DATA_WIDTH / STRB_WIDTH;
    parameter MEM_LEN = 2**ADDR_WIDTH;
    genvar i;

    typedef struct packed {
        logic addr_ok;
        logic [ADDR_WIDTH-1:0] addr;
    } read_state_t;

    logic [ELEM_WIDTH-1:0] mem[MEM_LEN-1:0];

    read_state_t read_curr;
    read_state_t read_next;

    initial begin{% for elem in elems %}
        mem[{{ (loop.index - 1) }}] = {{ elem_width }}'h{{ '%0*x' % (elem_width//4, elem) }};{% endfor %}
    end

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
""")

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('input_file', help='Input binary file')
    parser.add_argument('-o', '--output-file', default='axil_rom.v',
        help='Output Verilog file')
    parser.add_argument('-m', '--module-name', default='axil_rom',
        help='Verilog module name')
    parser.add_argument('-a', '--address-width', type=int, default=16,
        help='Address width')
    parser.add_argument('-d', '--data-width', type=int, default=32,
        help='Data width in bytes')
    
    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(input_file, output_file='rom.sv', module_name='rom',
    address_width=16, data_width=32):
    
    with open(input_file, 'rb') as f:
        data = f.read()

    verilog = template.render(
        module_name=module_name,
        addr_width=address_width,
        data_width=data_width,
        strb_width=data_width//8,
        elem_width=8,
        elems=data
    )

    with open(output_file, 'w') as f:
        f.write(verilog)
        f.flush()

if __name__ == "__main__":
    main()