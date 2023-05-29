#include "mylib.h"

extern char _stextures;

void texture_load(void *dest, void *src)
{
    size_t i = 0;
    size_t j = 32;
    size_t k = 0;

    uint32_t *read_ptr  = (uint32_t *) src;
    uint32_t *write_ptr = (uint32_t *) dest;

    uint32_t read_buf  = 0;
    uint32_t write_buf = 0;

    for(i = 0; i < 3*TEXTURE_WIDTH*TEXTURE_HEIGHT; i++) {
        if(j >= 32) {
            read_buf = *(read_ptr++);
            j = 0;
        }

        if(k >= 12) {
            *(write_ptr++) = write_buf;
            write_buf = 0;
            k = 0;
        }

        write_buf |= (read_buf & 0xF) << k;
        read_buf = read_buf >> 4;

        j += 4;
        k += 4;
    }
}

int main()
{   
    while(!GPIO_A_IN->btn_u);
    printf("Hello, World!\n");

    memset( (void *) GPU->clusters, 0, CLUSTER_COUNT*sizeof(cluster_t));

    texture_load((void *) GPU->clusters[1].texture, &_stextures);

/*
    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t r = (16 * i) / 64;
            uint32_t g = (16 * j) / 64;
            uint32_t b = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            GPU->clusters[0].texture[j][i] = color;
        }
    }
*/
    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t b = (16 * i) / 64;
            uint32_t r = (16 * j) / 64;
            uint32_t g = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            GPU->clusters[0].texture[j][i] = color;
        }
    }

    WRITE_WORD(GPIO_A, 0xFFFFFFFF);

    for(int j = 0; j < 4; j++) {
        for(int i = 0; i < 4; i++) {
            GPU->clusters[0].sprites[i + j*4].sx = i*64;
            GPU->clusters[0].sprites[i + j*4].sy = j*64;
            GPU->clusters[0].sprites[i + j*4].stx = 0;
            GPU->clusters[0].sprites[i + j*4].sty = 0;
            GPU->clusters[0].sprites[i + j*4].stw = 64;
            GPU->clusters[0].sprites[i + j*4].sth = 64;
        }
    }

    for(int j = 0; j < 4; j++) {
        for(int i = 0; i < 4; i++) {
            GPU->clusters[1].sprites[i + j*4].sx = 300 + i*64;
            GPU->clusters[1].sprites[i + j*4].sy = j*64;
            GPU->clusters[1].sprites[i + j*4].stx = 15; //(i % 2) ? 0 : 16;
            GPU->clusters[1].sprites[i + j*4].sty = 0; //(j % 2) ? 0 : 16;
            GPU->clusters[1].sprites[i + j*4].stw = 16; //32;
            GPU->clusters[1].sprites[i + j*4].sth = 16; //32;
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

        GPU->clusters[0].sprites[0].sx = i;
        GPU->clusters[0].sprites[0].sy = j;

        c = GPIO_A_IN->sw;

        for(volatile int k = 0; k < c; k++);
    }

    return 0;
}