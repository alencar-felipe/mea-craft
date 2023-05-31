#pragma once

typedef struct {
    int x;
    int y;
} vec2_t;

inline vec2_t vec2_add(vec2_t a, vec2_t b)
{
    return (vec2_t) {a.x - b.x, a.y - b.y};
}

inline vec2_t vec2_sub(vec2_t a, vec2_t b)
{
    return (vec2_t) {a.x - b.x, a.y - b.y};
}