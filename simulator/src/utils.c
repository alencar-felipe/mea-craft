#include "utils.h"

bus_t load(int bits, mem_t mem, bus_t addr) 
{   
    bus_t val = 0;

    for(int i = 0; i < bits / 8; i++) {
        val += mem[addr + i] << (8*i);
    }

    return val;
}

void store(int bits, mem_t mem, bus_t addr, bus_t value)
{
    for(int i = 0; i < bits / 8; i++) {
        mem[addr + i] = (value >> (8*i)) & 0xFF;
    }
}