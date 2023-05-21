#include <stdint.h>

#include "mem_map.h"

char *msg = "Hello, World\n";

int main()
{

    //WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    while(1) {
        for(int i = 0; msg[i] != '\0'; i++) {
            WRITE_BYTE(UART_DATA, msg[i]);
            WRITE_HALF(GPIO_A, READ_HALF(GPIO_A)); 

            for (volatile int j = 0; j < 100000; j++);
        }          
    }

    return 0;
}