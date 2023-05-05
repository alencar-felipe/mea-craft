#pragma once

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

size_t load_bin(const char* file_path, uint8_t* ptr, size_t max_size);