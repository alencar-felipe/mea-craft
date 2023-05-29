#include "mylib.h"

#define CLUSTER_COUNT  (3)
#define CLUSTER_SIZE   (20)
#define TEXTURE_WIDTH  (64)
#define TEXTURE_HEIGHT (64)

typedef struct __attribute__((packed)) {
    uint32_t sx;
    uint32_t sy;
    uint32_t stx;
    uint32_t sty;
    uint32_t stw;
    uint32_t sth;
} sprite_t;

typedef struct __attribute__((packed)) {
    sprite_t sprites[CLUSTER_SIZE];
    uint32_t texture[TEXTURE_HEIGHT][TEXTURE_WIDTH];
} cluster_t;

#define CLUSTERS ( (volatile cluster_t *) (0x20000000) )

int main()
{   
    memset( (void *) CLUSTERS, 0, CLUSTER_COUNT*sizeof(cluster_t));

    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t r = (16 * i) / 64;
            uint32_t g = (16 * j) / 64;
            uint32_t b = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            CLUSTERS[0].texture[j][i] = color;
        }
    }

    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t b = (16 * i) / 64;
            uint32_t r = (16 * j) / 64;
            uint32_t g = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            CLUSTERS[1].texture[j][i] = color;
        }
    }

    WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    for(int j = 0; j < 4; j++) {
        for(int i = 0; i < 4; i++) {
            CLUSTERS[0].sprites[i + j*4].sx = i*64;
            CLUSTERS[0].sprites[i + j*4].sy = j*64;
            CLUSTERS[0].sprites[i + j*4].stx = (i % 2) ? 0 : 16;
            CLUSTERS[0].sprites[i + j*4].sty = (j % 2) ? 0 : 16;
            CLUSTERS[0].sprites[i + j*4].stw = 32;
            CLUSTERS[0].sprites[i + j*4].sth = 32;
        }
    }

    for(int j = 0; j < 4; j++) {
        for(int i = 0; i < 4; i++) {
            CLUSTERS[1].sprites[i + j*4].sx = 300 + i*64;
            CLUSTERS[1].sprites[i + j*4].sy = j*64;
            CLUSTERS[1].sprites[i + j*4].stx = 0; //(i % 2) ? 0 : 16;
            CLUSTERS[1].sprites[i + j*4].sty = 0; //(j % 2) ? 0 : 16;
            CLUSTERS[1].sprites[i + j*4].stw = 64; //32;
            CLUSTERS[1].sprites[i + j*4].sth = 64; //32;
        }
    }

    int i = 0;
    int j = 0;
    int dx = 1;
    int dy = 1;
    int c = 0;

    while(1) {
        if(i >= 640 - 32) dx = -1;
        if(i <= 0) dx = 1;
        
        if(j >= 480 - 32) dy = -1;
        if(j <= 0) dy = 1;

        i += dx;
        j += dy;

        CLUSTERS[0].sprites[0].sx = i;
        CLUSTERS[0].sprites[0].sy = j;

        c = READ_WORD(GPIO_A);

        for(volatile int k = 0; k < c; k++);
    }

    return 0;
}