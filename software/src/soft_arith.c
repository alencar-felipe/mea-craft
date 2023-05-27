unsigned int __mulsi3 (unsigned int a, unsigned int b)
{
    unsigned int r = 0;

    while (a) {
        if (a & 1) {
	        r += b;
        }
        
        a >>= 1;
        b <<= 1;
    }

    return r;
}

#include "mem_map.h"

unsigned int __udivsi3 (unsigned int a, unsigned int b)
{
    unsigned int quotient;

    if (b == 0) return 0xFFFFFFFF;

    quotient = 0;

    while (a >= b) {
        a -= b;
        quotient++;
    }

    return quotient;
}
