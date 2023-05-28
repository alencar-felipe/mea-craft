#pragma once

#include <stdarg.h>
#include <stdint.h>

#include "mem_map.h"

typedef uint32_t size_t;

void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);

int putchar(int c);
int puts(const char *str);
int printf(const char *format, ...);
int sprintf(char *out, const char *format, ...);

unsigned int __mulsi3(unsigned int a, unsigned int b);
unsigned int __udivsi3(unsigned int a, unsigned int b);
int __divsi3(int dividend, int divisor);
unsigned int __umodsi3(unsigned int dividend, unsigned int divisor);