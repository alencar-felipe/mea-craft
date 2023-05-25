#pragma once

#include "my_math.h"
#include "types.h"

#define RASTER_WIDTH (320)
#define RASTER_HEIGHT (240)
#define TEXTURE_WIDTH (16)
#define TEXTURE_HEIGHT (16)

void render_triangle(
    triangle_t *triangle,
    m4_t *world_to_screen,
    uint8_t *texture,
    uint8_t *raster
);