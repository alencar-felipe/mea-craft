#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define BYTES_PER_PIXEL (3)
#define FILE_HEADER_SIZE (14)
#define INFO_HEADER_SIZE (40)

void save_bitmap(char *file_path, uint32_t *raster, uint32_t width, uint32_t height);