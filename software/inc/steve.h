#pragma once

#include "mylib.h"
#include "texture.h"
#include "vec2.h"

#define STEVE_W (32)
#define STEVE_H (104)

void steve_load();
void steve_render(vec2_t p, int walk, int dir);