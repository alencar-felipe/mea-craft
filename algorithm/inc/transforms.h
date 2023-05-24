#pragma once

#include "my_math.h"
#include "types.h"

m4_t rotate(v3_t *vec);
m4_t scale(v3_t *vec);
m4_t translate(v3_t *vec);
m4_t perspective(fixed_t near);
m4_t world_to_screen(camera_t *camera);