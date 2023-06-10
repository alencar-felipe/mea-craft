#include "mylib.h"
#include "steve.h"
#include "world.h"

void banner_loop();
void game_loop();

void gpu_init();
void banner_init();
void physics_init();
void physics();

const int gravity = 3;
const int walk_speed = 3;
const int jump_speed = 20;
const int walk_prescaler = 4;
const int max_speed = 50;

vec2_t p;
vec2_t v;
vec2_t a;
vec2_t wp;
int walk;
int walk_counter;
int dir;
int hearts;

int last_btn_d;

int main()
{   
    //disable_interrupt();

    while(1) {
        banner_loop();
        game_loop();
    }
}

void banner_loop()
{
    uint8_t btn_d;

    gpu_init();
    world_init();
    banner_init();

    last_btn_d = GPIO_A_IN->btn_d;

    while(1) {
        btn_d = GPIO_A_IN->btn_d;

        if(btn_d == 1 && last_btn_d == 0) break;
    }
}

void game_loop()
{
    uint32_t current;
    uint32_t last;

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

        if(!(GPIO_A_IN->sw & (1 << 15))) {
            world_render(wp);
        }

        steve_render(vec2_sub(p, wp), walk, dir, hearts);

        if(hearts <= 0) {
            break;
        }
    }
}

void gpu_init()
{
    GPIO_A_OUT->texture_lock = 0;  
    world_load_textures();
    steve_load();
    GPIO_A_OUT->texture_lock = 1;    
}

void banner_init()
{
    GPIO_A_OUT->texture_lock = 0;  
    texture_load((void *) GPU->clusters[0].texture, TEXTURE2);
    GPIO_A_OUT->texture_lock = 1; 
    
    GPU->clusters[0].sprites[0].stx = 0;
    GPU->clusters[0].sprites[0].sty = 0;
    GPU->clusters[0].sprites[0].stw = 64;
    GPU->clusters[0].sprites[0].sth = 64;

    GPU->clusters[0].sprites[0].sx = 256;
    GPU->clusters[0].sprites[0].sy = 176;

    for(int i = 1; i < GPU_CL_SIZE; i++) {
        GPU->clusters[0].sprites[i].sx = GPU_W;
        GPU->clusters[0].sprites[i].sy = GPU_H;
    }
}

void physics_init()
{
    p = (vec2_t) {300, -28*BLOCK_SIZE};
    v = (vec2_t) {0, 0};
    a = (vec2_t) {0, 0};
    wp = (vec2_t) {0, 0};
    walk = 0;
    dir = 0;
    hearts = 3;
}

void physics()
{
    vec2_t low, high;
    vec2_t down;
    vec2_t front_high;
    vec2_t back_high;
    vec2_t front_low;
    vec2_t back_low;

    int block;

    uint8_t btn_u = GPIO_A_IN->btn_u;
    uint8_t btn_l = GPIO_A_IN->btn_l;
    uint8_t btn_r = GPIO_A_IN->btn_r;
    uint8_t btn_d = GPIO_A_IN->btn_d;

    block = (GPIO_A_IN->sw >> 0) & 0xFF;

    low         = vec2_add(p    , (vec2_t) {0             , -STEVE_H      });
    high        = vec2_add(p    , (vec2_t) {0             , 0             });
    down        = vec2_add(low  , (vec2_t) {0             , -32           });
    front_high  = vec2_add(high , (vec2_t) {-STEVE_W      , 0             });
    back_high   = vec2_add(high , (vec2_t) {+1            , 0             });
    front_low   = vec2_add(low  , (vec2_t) {-STEVE_W      , 0             });
    back_low    = vec2_add(low  , (vec2_t) {+1            , 0             });

    if(world_get(down) == 0) {
        a.y = gravity;
    } else {
        a.y = 0;

        if(v.y <= -max_speed) {
            hearts -= 1;
        }

        v.y = (down.y % BLOCK_SIZE);

        if(btn_u) {
            v.y = jump_speed;
        }
    }

    if(btn_d == 0 && last_btn_d == 1) {
        if(btn_l) {
            world_set(back_low, block);
        } else if(btn_r) {
            world_set(front_low, block);
        } else {
            world_set(down, block);
        }
    } else if(btn_d == 0) {
        if(btn_l) {
            if(
                (world_get(back_high) == 0) &&
                (world_get(back_low) == 0)
            ) {
                p.x -= walk_speed;
                dir = -1;
            }
        } else if(btn_r) {
            if(
                (world_get(front_high) == 0) &&
                (world_get(front_low) == 0)
            ) {
                p.x += walk_speed;
                dir = +1;
            }
        }

        if(btn_l || btn_r) {
            if(walk_counter % walk_prescaler == 0) walk++; 
            walk_counter++;
        } else {
            walk_counter = 0;
            walk = 0;
        }
    }

    v = vec2_add(v, a);
    p = vec2_add(p, v);

    if(v.x >  max_speed) v.x =  max_speed;
    if(v.x < -max_speed) v.x = -max_speed;
    if(v.y >  max_speed) v.y =  max_speed;
    if(v.y < -max_speed) v.y = -max_speed;

    wp.x = (7*wp.x + (p.x - GPU_W/2))/8;
    wp.y = (7*wp.y + (p.y - GPU_H/2))/8;

    last_btn_d = btn_d;
}

// interrupt handler
void frame_handler()
{
    GPIO_A_OUT->led = GPIO_B_IN->frame_counter;
}