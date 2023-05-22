#include <stdint.h>

#include "mem_map.h"

char *msg = "Hello, World\n";

int main()
{

    //WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    while(1) {
        uint32_t k = VGA_BASE;
        for(int j = 0; j < 240; j++) {
            for(int i = 0; i < 320; i++, k += 4) {
                if ((i % 8 >= 4) ^ (j % 8 >= 4)) {
                    WRITE_WORD(k, 0x000000F0);
                } else {
                    WRITE_WORD(k, 0x00000F00);
                }
            }
        }

        WRITE_HALF(GPIO_A, READ_HALF(GPIO_A));

        for(int i = 0; msg[i] != '\0'; i++) {
            WRITE_BYTE(UART_DATA, msg[i]);
            for (volatile int j = 0; j < 1000; j++);
        }          
    }

    return 0;
}