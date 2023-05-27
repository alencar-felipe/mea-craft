#include <stdint.h>

#include "mem_map.h"
#include "printf.h"

extern int my_printf(const char *format, ...);

int main()
{
    while(!READ_BYTE(GPIO_A));

    uint32_t c = 0;
    uint32_t sts = 0;
    uint8_t frame = 0;

    while(1) {
        WRITE_WORD(GPIO_A, c++);

        sts = READ_WORD(PS2_STS);
        //printf("sts: %x\n", sts);

        if(sts) {
            frame = READ_BYTE(PS2_FRAME);
            printf("frame: %x\n", frame);
        }

        for(volatile int i = 0; i < 10000; i++);
    }

    return 0;
}