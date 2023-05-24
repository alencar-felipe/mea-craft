#pragma once

#include <stdint.h>

typedef int32_t fixed_t;

typedef struct __attribute__((packed)) {
    fixed_t x[2];
} v2_t;

typedef struct __attribute__((packed)) {
    fixed_t x[3];
} v3_t;

typedef struct __attribute__((packed)) {
    fixed_t x[4];
} v4_t;

typedef struct __attribute__((packed)) {
    fixed_t x[4][4];
} m4_t;

typedef struct __attribute__((packed)) {
    v3_t position;
    v3_t rotation;
    fixed_t near;
} camera_t;

typedef struct __attribute__((packed)) {
    v3_t vertices[3];
    v2_t texture[3];
} triangle_t;