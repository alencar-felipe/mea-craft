#include "utils.h"

word_t load(int bits, mem_t mem, word_t addr) 
{   
    word_t val = 0;

    for(int i = 0; i < bits / 8; i++) {
        val += mem[addr + i] << (8*i);
    }

    return val;
}

void store(int bits, mem_t mem, word_t addr, word_t value)
{
    for(int i = 0; i < bits / 8; i++) {
        mem[addr + i] = (value >> (8*i)) & 0xFF;
    }
}