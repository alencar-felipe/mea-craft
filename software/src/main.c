#include "mylib.h"
#include "steve.h"
#include "texture.h"

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

void init_gpu();
void build_world();
void render_world();

uint8_t world[WORLD_H][WORLD_W];

int main()
{   
    init_gpu();
    build_world();

    int offset_x = 300;
    int offset_y = -28*BLOCK_SIZE;
    int walk = 0;
    int dir = 0;

    while(1) {
        if(GPIO_A_IN->btn_l) {
            offset_x -= GPIO_A_IN->sw;
            dir = -1;
        }

        if(GPIO_A_IN->btn_r) {
            offset_x += GPIO_A_IN->sw;
            dir = +1;
        }

        if(GPIO_A_IN->btn_u) {
            offset_y -= GPIO_A_IN->sw;
        }

        if(GPIO_A_IN->btn_d) {
            offset_y += GPIO_A_IN->sw;
        }

        walk = offset_x;

        render_world(offset_x, offset_y);
        steve_render(100, 100, walk, dir);
    }

    return 0;
}

void init_gpu()
{
    int i, j;

    memset((void *) GPU, 0, sizeof(*GPU));
    
    /* Blocks */

    for(i = 1; i < GPU_CL_COUNT; i++) {
        texture_load((void *) GPU->clusters[i].texture, TEXTURE0);
        for(j = 0; j < GPU_CL_SIZE; j++) {
            GPU->clusters[i].sprites[j].sx = 480;
            GPU->clusters[i].sprites[j].sy = 640;
            GPU->clusters[i].sprites[j].stx = (i*16)%64;
            GPU->clusters[i].sprites[j].sty = 0;
            GPU->clusters[i].sprites[j].stw = 16;
            GPU->clusters[i].sprites[j].sth = 16;
        }
    }

    steve_load();    
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
    int j = WORLD_H-1;
    int c = 1;
    int s = 0;
    int block = 0;

    while(j >= 0) {
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
            j--;
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