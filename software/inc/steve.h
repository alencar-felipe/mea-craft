#pragma once

#include "mylib.h"
#include "texture.h"
#include "vec2.h"

#define STEVE_W (16)
#define STEVE_H (80)

void steve_load();
void steve_render(vec2_t p, int walk, int dir);