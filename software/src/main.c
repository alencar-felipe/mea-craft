#include "mylib.h"

#define WORLD_W (128)
#define WORLD_H (64)
#define BLOCK_SIZE (64)

#define BLOCK_DIRT    ( 1)
#define BLOCK_GRASS   ( 2)
#define BLOCK_STONE   ( 3)
#define BLOCK_COBBLE  ( 4)
#define BLOCK_LOG     ( 5)
#define BLOCK_LEAFS   ( 6)
#define BLOCK_PLANKS  ( 7)
#define BLOCK_CRAFT   ( 8)
#define BLOCK_COAL    ( 9)
#define BLOCK_IRON    (10)
#define BLOCK_GOLD    (11)
#define BLOCK_DIAMOND (12)

extern char _stextures;

void texture_load(void *dest, void *src);
void init_gpu();
void build_world();
void render_world();

uint8_t world[WORLD_H][WORLD_W];

int main()
{   
    init_gpu();
    build_world();

    int offset_x = 0;
    int offset_y = 0;

    while(1) {
        if(GPIO_A_IN->btn_l) {
            offset_x += GPIO_A_IN->sw;
        }

        if(GPIO_A_IN->btn_r) {
            offset_x -= GPIO_A_IN->sw;
        }

        if(GPIO_A_IN->btn_u) {
            offset_y += GPIO_A_IN->sw;
        }

        if(GPIO_A_IN->btn_d) {
            offset_y -= GPIO_A_IN->sw;
        }

        render_world(offset_x, offset_y);
    }

    return 0;
}

void texture_load(void *dest, void *src)
{
    size_t i = 0;
    size_t j = 32;
    size_t k = 0;

    uint32_t *read_ptr  = (uint32_t *) src;
    uint32_t *write_ptr = (uint32_t *) dest;

    uint32_t read_buf  = 0;
    uint32_t write_buf = 0;

    for(i = 0; i < 3*GPU_TEXT_W*GPU_TEXT_H; i++) {
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

void init_gpu()
{
    memset((void *) GPU, 0, sizeof(*GPU));
    
    for(int i = 1; i < GPU_CL_COUNT; i++) {
        texture_load((void *) GPU->clusters[i].texture, &_stextures);
        for(int j = 0; j < GPU_CL_SIZE; j++) {
            GPU->clusters[i].sprites[j].sx = 480;
            GPU->clusters[i].sprites[j].sy = 640;
            GPU->clusters[i].sprites[j].stx = (i*16)%64;
            GPU->clusters[i].sprites[j].sty = 0;
            GPU->clusters[i].sprites[j].stw = 16;
            GPU->clusters[i].sprites[j].sth = 16;
        }
    }
}

void build_world()
{
    int i, j;

    memset((void *) world, 0, sizeof(world));

    uint8_t levels[WORLD_H];

    levels[0] = BLOCK_DIAMOND;

    for(j = 1; j < 27; j++) {
        levels[j] = BLOCK_STONE;
    }

    for(j = 27; j < 31; j++) {
        levels[j] = BLOCK_DIRT;
    }

    levels[31] = BLOCK_GRASS;

    for(j = 0; j < WORLD_H; j++) {
        for(i = 0; i < WORLD_W; i++) {
            world[j][i] = levels[j];

            if(i % 10 == 0) world[j][i] = ((i/10) % 12)+1;
        }
    }
}

void render_world(int ox, int oy)
{
    int i = 0;
    int j = 0;
    int c = 1;
    int s = 0;
    int block = 0;

    while(j < WORLD_H) {
        int sx = i*BLOCK_SIZE - ox;
        int sy = (GPU_H - (j+1)*BLOCK_SIZE) - oy;

        if(
            (world[j][i] != 0) &&
            (sx >= -BLOCK_SIZE && sx < GPU_W) &&
            (sy >= -BLOCK_SIZE && sy < GPU_H) 
        ) {
            GPU->clusters[c].sprites[s].sx = sx;
            GPU->clusters[c].sprites[s].sy = sy;

            block = world[j][i] - 1;

            GPU->clusters[c].sprites[s].stx = (block % 4)*16;
            GPU->clusters[c].sprites[s].sty = (block / 4)*16;

            s++;

            if(s >= GPU_CL_SIZE) {
                s = 0;
                c++;
            }

            if(c >= GPU_CL_COUNT) {
                break;
            }
        }

        i++;

        if(i >= WORLD_W) {
            i = 0;
            j++;
        }
    }

    // Hide unused sprites
    while(c < GPU_CL_COUNT) {
        GPU->clusters[c].sprites[s].sx = GPU_W;
        GPU->clusters[c].sprites[s].sy = GPU_H;
        s++;

        if(s >= GPU_CL_SIZE) {
            s = 0;
            c++;
        }
    }
}