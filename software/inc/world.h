#pragma once

#include "mylib.h"
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

extern uint8_t world[WORLD_H][WORLD_W];

void world_load_textures();
void world_build();
void world_render();