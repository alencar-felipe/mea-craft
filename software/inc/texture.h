#pragma once

#include "mylib.h"

extern char _stextures;

#define TEXTURE0 ((void *) (&_stextures + 0x00000000))
#define TEXTURE1 ((void *) (&_stextures + 0x00001800))
#define TEXTURE2 ((void *) (&_stextures + 0x00003000))

void texture_load(void *dest, void *src);