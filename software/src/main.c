#include "mylib.h"
#include "steve.h"
#include "world.h"

#define VMAX (30)

void gpu_init();
void physics_init();
void physics();

vec2_t p;
vec2_t v;
vec2_t a;
int walk;
int dir;

vec2_t wp;

int main()
{   
    uint32_t current;
    uint32_t last;

    disable_interrupt();

    gpu_init();
    world_init();
    physics_init();

    last = GPIO_B_IN->frame_counter;

    while(1) {
        current = GPIO_B_IN->frame_counter;

        while(last < current) {
            physics();
            last++;
        }

        world_render(wp);
        steve_render(vec2_sub(p, wp), walk, dir);

        printf("%d\n", world[31*128 + 0]);
    }

    return 0;
}

void gpu_init()
{
    world_load_textures();
    steve_load();    
}

void physics_init()
{
    p = (vec2_t) {300, -28*BLOCK_SIZE};
    v = (vec2_t) {0, 0};
    a = (vec2_t) {0, 0};
    walk = 0;
    dir = 0;

    wp = (vec2_t) {0, 0};
}

void physics()
{
    vec2_t ground;
    int speed;
    int block;

    speed = (GPIO_A_IN->sw >> 8) & 0xFF;
    block = (GPIO_A_IN->sw >> 0) & 0xFF;

    ground = vec2_sub(p, (vec2_t) {0, -32-STEVE_H});

    if(world_get(ground) == 0) {
        a.y = 3;
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
}

// interrupt handler
void frame_handler()
{
    GPIO_A_OUT->led = GPIO_B_IN->frame_counter;
}