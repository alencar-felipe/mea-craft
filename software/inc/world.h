#pragma once

#include "mylib.h"
#include "texture.h"
#include "vec2.h"

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

extern uint8_t *world;

void world_load_textures();
void world_init();
void world_render();
int world_get(vec2_t screen);
void world_set(vec2_t screen, int value);