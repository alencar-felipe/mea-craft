#include "mylib.h"

typedef struct __attribute__((packed)) {
    uint32_t sx;
    uint32_t sy;
    uint32_t stx;
    uint32_t sty;
    uint32_t stw;
    uint32_t sth;
} position_t;

#define POSITIONS ( (volatile position_t *) (0x20000000) )
#define TEXTURE   ( (volatile uint32_t *) (0x20000000 + 20*6*4) )

int main()
{   
    WRITE_WORD(GPIO_A, 0xAAAAAAAA);

    POSITIONS[0].sx = 150;
    POSITIONS[0].sy = 150;
    POSITIONS[0].stx = 0;
    POSITIONS[0].sty = 0;
    POSITIONS[0].stw = 64;
    POSITIONS[0].sth = 64;

    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t r = (16 * i) / 64;
            uint32_t g = (16 * j) / 64;
            uint32_t b = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            TEXTURE[i + j*64] = color;
        }
    }

    WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    
    while(1);

    return 0;
}