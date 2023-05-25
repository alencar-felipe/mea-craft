#pragma once

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define FIXED_BIT (8)
#define ONE (1 << FIXED_BIT)

typedef int64_t fixed_t;

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

void print_fixed(fixed_t n);
void print_v2(v2_t *m);
void print_v3(v3_t *m);
void print_v4(v4_t *m);
void print_m4(m4_t *m);
