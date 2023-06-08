#include "mylib.h"
#include "steve.h"
#include "world.h"

#define VMAX (30)

void init_gpu();

int main()
{   
    init_gpu();
    world_build();

    vec2_t p = {300, -28*BLOCK_SIZE};
    vec2_t v = {0, 0};
    vec2_t a = {0, 0};
    int walk = 0;
    int dir = 0;

    vec2_t wp = {300, -28*BLOCK_SIZE};
    
    vec2_t ground;

    int speed;
    int block;

    while(1) {
        speed = (GPIO_A_IN->sw >> 8) & 0xFF;
        block = (GPIO_A_IN->sw >> 0) & 0xFF;

        ground = vec2_add(p, (vec2_t) {0, -STEVE_H-64});

        if(world_get(ground) == 0) {
            a.y = 4;
        } else {
            a.y = 0;

            v.y = (ground.y % BLOCK_SIZE);

            if(GPIO_A_IN->btn_u) {
                v.y = 20;
            }
        }

        if(GPIO_A_IN->btn_d) {
            world_set(ground, block);
        }

        if(GPIO_A_IN->btn_l) {
            p.x -= speed;
            dir = -1;
            walk++;
        } else if(GPIO_A_IN->btn_r) {
            p.x += speed;
            dir = +1;
            walk++;
        } else {
            walk = 0;
        }
    
        v = vec2_add(v, a);
        p = vec2_add(p, v);

        if(v.x >  VMAX) v.x =  VMAX;
        if(v.x < -VMAX) v.x = -VMAX;
        if(v.y >  VMAX) v.y =  VMAX;
        if(v.y < -VMAX) v.y = -VMAX;

        wp.x = (7*wp.x + (p.x - GPU_W/2))/8;
        wp.y = (7*wp.y + (p.y - GPU_H/2))/8;
        
        world_render(wp);
        steve_render(vec2_sub(p, wp), walk, dir);

        //GPIO_A_OUT->led = (int16_t) GPIO_B_IN->frame_counter;
    }

    return 0;
}

void init_gpu()
{
    world_load_textures();
    steve_load();    
}