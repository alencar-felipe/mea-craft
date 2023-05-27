#include <stdint.h>

#include "mem_map.h"
#include "printf.h"

extern int my_printf(const char *format, ...);

int main()
{
    uint32_t c = 0;

    while(1) {
        WRITE_WORD(GPIO_A, c);
        printf("c: %d\n", (int) c);
        for(volatile int i = 0; i < 10000; i++);
        c++;
    }

    return 0;
}