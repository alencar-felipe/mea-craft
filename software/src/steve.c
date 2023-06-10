#include "steve.h"

void steve_load()
{
    int i;

    texture_load((void *) GPU->clusters[0].texture, TEXTURE1);

    for(i = 0; i < GPU_CL_SIZE; i++) {
        GPU->clusters[0].sprites[i].sx = GPU_W;
        GPU->clusters[0].sprites[i].sy = GPU_H;
    }

    // Head right
    GPU->clusters[0].sprites[ 0].stx = 40;
    GPU->clusters[0].sprites[ 0].sty = 32;
    GPU->clusters[0].sprites[ 0].stw = 16;
    GPU->clusters[0].sprites[ 0].sth = 16;

    // Head left
    GPU->clusters[0].sprites[ 1].stx = 40;
    GPU->clusters[0].sprites[ 1].sty = 48;
    GPU->clusters[0].sprites[ 1].stw = 16;
    GPU->clusters[0].sprites[ 1].sth = 16;

    // Arm 0
    GPU->clusters[0].sprites[ 2].stx = 32;
    GPU->clusters[0].sprites[ 2].sty = 16;
    GPU->clusters[0].sprites[ 2].stw =  8;
    GPU->clusters[0].sprites[ 2].sth = 24;

    // Arm 7
    GPU->clusters[0].sprites[ 3].stx = 20;
    GPU->clusters[0].sprites[ 3].sty = 16;
    GPU->clusters[0].sprites[ 3].stw = 12;
    GPU->clusters[0].sprites[ 3].sth = 24;

    // Arm 15
    GPU->clusters[0].sprites[ 4].stx = 0;
    GPU->clusters[0].sprites[ 4].sty = 16;
    GPU->clusters[0].sprites[ 4].stw = 20;
    GPU->clusters[0].sprites[ 4].sth = 24;

    // Body
    GPU->clusters[0].sprites[ 5].stx = 56;
    GPU->clusters[0].sprites[ 5].sty = 40;
    GPU->clusters[0].sprites[ 5].stw =  8;
    GPU->clusters[0].sprites[ 5].sth = 24;

    // Leg 0
    GPU->clusters[0].sprites[ 6].stx = 32;
    GPU->clusters[0].sprites[ 6].sty = 40;
    GPU->clusters[0].sprites[ 6].stw =  8;
    GPU->clusters[0].sprites[ 6].sth = 24;

    // Leg 7
    GPU->clusters[0].sprites[ 7].stx = 20;
    GPU->clusters[0].sprites[ 7].sty = 40;
    GPU->clusters[0].sprites[ 7].stw = 12;
    GPU->clusters[0].sprites[ 7].sth = 24;

    // Leg 15
    GPU->clusters[0].sprites[ 8].stx =  0;
    GPU->clusters[0].sprites[ 8].sty = 40;
    GPU->clusters[0].sprites[ 8].stw = 20;
    GPU->clusters[0].sprites[ 8].sth = 24;

    // Heart 1
    GPU->clusters[0].sprites[ 9].stx = 40;
    GPU->clusters[0].sprites[ 9].sty = 22;
    GPU->clusters[0].sprites[ 9].stw = 10;
    GPU->clusters[0].sprites[ 9].sth = 10;

    // Heart 2
    GPU->clusters[0].sprites[10].stx = 40;
    GPU->clusters[0].sprites[10].sty = 22;
    GPU->clusters[0].sprites[10].stw = 10;
    GPU->clusters[0].sprites[10].sth = 10;

    // Heart 3
    GPU->clusters[0].sprites[11].stx = 40;
    GPU->clusters[0].sprites[11].sty = 22;
    GPU->clusters[0].sprites[11].stw = 10;
    GPU->clusters[0].sprites[11].sth = 10;
}

void steve_render(vec2_t p, int walk, int dir, int hearts)
{
    walk = walk % 6;
    
    if(walk >= 3) {
        walk = 5 - walk;
    }

    // Head right
    if(dir >= 0) {
        GPU->clusters[0].sprites[ 0].sx = p.x;
        GPU->clusters[0].sprites[ 0].sy = p.y;
    } else {
        GPU->clusters[0].sprites[ 0].sx = GPU_W;
        GPU->clusters[0].sprites[ 0].sy = GPU_H;
    }

    // Head left
    if(dir < 0) {
        GPU->clusters[0].sprites[ 1].sx = p.x;
        GPU->clusters[0].sprites[ 1].sy = p.y;
    } else {
        GPU->clusters[0].sprites[ 1].sx = GPU_W;
        GPU->clusters[0].sprites[ 1].sy = GPU_H;
    }
    
    // Arm 0
    if(walk == 0) {
        GPU->clusters[0].sprites[ 2].sx = p.x +  8;
        GPU->clusters[0].sprites[ 2].sy = p.y + 32;
    } else {
        GPU->clusters[0].sprites[ 2].sx = GPU_W;
        GPU->clusters[0].sprites[ 2].sy = GPU_H;
    }

    // Arm 7
    if(walk == 1) {
        GPU->clusters[0].sprites[ 3].sx = p.x +  4;
        GPU->clusters[0].sprites[ 3].sy = p.y + 32;
    } else {
        GPU->clusters[0].sprites[ 3].sx = GPU_W;
        GPU->clusters[0].sprites[ 3].sy = GPU_H;
    }

    // Arm 15
    if(walk == 2) {
        GPU->clusters[0].sprites[ 4].sx = p.x -  4;
        GPU->clusters[0].sprites[ 4].sy = p.y + 32;
    } else {
        GPU->clusters[0].sprites[ 4].sx = GPU_W;
        GPU->clusters[0].sprites[ 4].sy = GPU_H;
    }

    // Body
    GPU->clusters[0].sprites[ 5].sx = p.x +  8;
    GPU->clusters[0].sprites[ 5].sy = p.y + 32;
    
    // Leg 0
    if(walk == 0) {
        GPU->clusters[0].sprites[ 6].sx = p.x +  8;
        GPU->clusters[0].sprites[ 6].sy = p.y + 32 + 24;
    } else {
        GPU->clusters[0].sprites[ 6].sx = GPU_W;
        GPU->clusters[0].sprites[ 6].sy = GPU_H;
    }

    // Leg 7
    if(walk == 1) {
        GPU->clusters[0].sprites[ 7].sx = p.x +  4;
        GPU->clusters[0].sprites[ 7].sy = p.y + 32 + 24;
    } else {
        GPU->clusters[0].sprites[ 7].sx = GPU_W;
        GPU->clusters[0].sprites[ 7].sy = GPU_H;
    }

    // Leg 15
    if(walk == 2) {
        GPU->clusters[0].sprites[ 8].sx = p.x -  4;
        GPU->clusters[0].sprites[ 8].sy = p.y + 32 + 24;
    } else {
        GPU->clusters[0].sprites[ 8].sx = GPU_W;
        GPU->clusters[0].sprites[ 8].sy = GPU_H;
    }

    // Heart 1
    if(hearts >= 1) {
        GPU->clusters[0].sprites[ 9].sx = 280;
        GPU->clusters[0].sprites[ 9].sy = 20;
    } else {
        GPU->clusters[0].sprites[ 9].sx = GPU_W;
        GPU->clusters[0].sprites[ 9].sy = GPU_H;
    }

    // Heart 2
    if(hearts >= 2) {
        GPU->clusters[0].sprites[10].sx = 310;
        GPU->clusters[0].sprites[10].sy = 20;
    } else {
        GPU->clusters[0].sprites[10].sx = GPU_W;
        GPU->clusters[0].sprites[10].sy = GPU_H;
    }

    // Heart 3
    if(hearts >= 3) {
        GPU->clusters[0].sprites[11].sx = 340;
        GPU->clusters[0].sprites[11].sy = 20;
    } else {
        GPU->clusters[0].sprites[11].sx = GPU_W;
        GPU->clusters[0].sprites[11].sy = GPU_H;
    }
}