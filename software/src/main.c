#include "mylib.h"
#include "steve.h"
#include "world.h"

void init_gpu();

int main()
{   
    init_gpu();
    world_build();

    //int g = 10;

    int x = 300;
    int y = -28*BLOCK_SIZE;
    int vx = 0;
    int vy = 0;
    int ay = 0;
    int walk = 0;
    int dir = 0;

    int world_x = 300;
    int world_y = -28*BLOCK_SIZE;
    
    int tmp = GPIO_A_IN->sw;

    while(1) {
        tmp = GPIO_A_IN->sw;

        if(GPIO_A_IN->btn_l) {
            x -= tmp;
            dir = -1;
        } else if(GPIO_A_IN->btn_r) {
            x += tmp;
            dir = +1;
        }
        
        if(GPIO_A_IN->btn_u) {
            y -= tmp;
        } else if(GPIO_A_IN->btn_d) {
            y += tmp;
        }

        vy += ay;

        x += vx;
        y += vy;

        walk = x;

        world_x = (15*world_x + (x - GPU_W/2))/16;
        world_y = (15*world_y + (y - GPU_H/2))/16;
        
        world_render(world_x, world_y);
        steve_render(x - world_x, y - world_y, walk, dir);
    }

    return 0;
}

void init_gpu()
{
    world_load_textures();
    steve_load();    
}