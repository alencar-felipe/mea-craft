#include "world.h"

extern uint8_t _sworld_data;

uint8_t *world;

void world_load_textures()
{
    int i, j;

    memset((void *) GPU, 0, sizeof(*GPU));
    
    for(i = 1; i < GPU_CL_COUNT; i++) {
        texture_load((void *) GPU->clusters[i].texture, TEXTURE0);
        for(j = 0; j < GPU_CL_SIZE; j++) {
            GPU->clusters[i].sprites[j].sx = GPU_W;
            GPU->clusters[i].sprites[j].sy = GPU_H;
            GPU->clusters[i].sprites[j].stx = 0;
            GPU->clusters[i].sprites[j].sty = 0;
            GPU->clusters[i].sprites[j].stw = 16;
            GPU->clusters[i].sprites[j].sth = 16;
        }
    }
}

void world_init()
{
    world = &_sworld_data;
}

void world_render(vec2_t p)
{
    int i = 0;
    int j = 0;
    int c = 1;
    int s = 0;
    int block = 0;

    while(j < WORLD_H) {
        int sx = i*BLOCK_SIZE - p.x;
        int sy = (GPU_H - (j+1)*BLOCK_SIZE) - p.y;

        if(
            (world[WORLD_W*j + i] != 0) &&
            (sx >= -BLOCK_SIZE && sx < GPU_W) &&
            (sy >= -BLOCK_SIZE && sy < GPU_H) 
        ) {
            GPU->clusters[c].sprites[s].sx = sx;
            GPU->clusters[c].sprites[s].sy = sy;

            block = world[WORLD_W*j + i] - 1;

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

int world_get(vec2_t screen)
{
    vec2_t w;

    w.x = screen.x/BLOCK_SIZE;
    w.y = (GPU_H - screen.y)/BLOCK_SIZE;  

    if(
        (w.x >= 0 && w.x < WORLD_W) &&
        (w.y >= 0 && w.y < WORLD_H)
    ) {
        return world[WORLD_W*w.y + w.x];
    } else {
        return 0;
    }
}

void world_set(vec2_t screen, int value)
{
    vec2_t w;

    w.x = screen.x/BLOCK_SIZE;
    w.y = (GPU_H - screen.y)/BLOCK_SIZE;  

    if(
        (w.x >= 0 && w.x < WORLD_W) &&
        (w.y >= 0 && w.y < WORLD_H)
    ) {
        world[WORLD_W*w.y + w.x] = value;
    }
}