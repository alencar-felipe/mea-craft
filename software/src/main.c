#include <stdint.h>

#include "mem_map.h"
#include "small_printf.h"

int main()
{
    
    

    uint32_t c = 0;

    WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    while(!READ_WORD(GPIO_A));

    WRITE_WORD(GPIO_A, 0);

    while(1) {
        WRITE_WORD(GPIO_A, c);
        //WRITE_BYTE(UART_DATA,'F');
        
        c++;
        
        printf("%d\n", c);
    }

    return 0;
}