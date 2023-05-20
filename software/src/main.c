#include <stdint.h>

char *msg = "Hello, World\n";

int main()
{
    while(1) {
        for(int i = 0; i < 13; i++) {
            *((volatile uint8_t *)(0x30000000)) = msg[i];
            for(volatile int i = 0; i < 100000; i++);  
        }          
    }

    return 0;
}