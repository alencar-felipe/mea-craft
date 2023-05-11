#include <stdint.h>

int main()
{
    int a, b, tmp;

    a = 0;
    b = 1;

    for(int i = 2; i < 10; i++) {
        tmp = b;
        b = a + b;
        a = tmp;    
    }

    *((volatile uint32_t *)(4095)) = b;
    
    return b;
}