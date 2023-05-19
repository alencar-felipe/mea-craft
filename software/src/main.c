#include <stdint.h>

char *msg = "Felipe";

int main()
{
    char *ptr = msg;

    while(*ptr != '\0') {
        *((volatile uint8_t *)(0x30000000)) = *ptr;
        ptr++;     
    }

    return 0;
}