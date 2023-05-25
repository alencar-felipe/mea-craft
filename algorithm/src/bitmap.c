#include "bitmap.h"

void save_bitmap(char *file_path, uint8_t *raster, uint32_t width, uint32_t height)
{
    int width_in_bytes;
    int padding_size;
    int stride;
    int file_size;
    uint32_t i;
    uint8_t padding[3] = {0};
    uint8_t fileHeader[FILE_HEADER_SIZE] = {0};
    uint8_t infoHeader[INFO_HEADER_SIZE] = {0};
    uint8_t *ptr;
    FILE* file;

    width_in_bytes = width * BYTES_PER_PIXEL;
    padding_size = (4 - width_in_bytes % 4) % 4;
    stride = width_in_bytes + padding_size;

    file_size = FILE_HEADER_SIZE + INFO_HEADER_SIZE + (stride * height);

    fileHeader[0] = (uint8_t) ('B');
    fileHeader[1] = (uint8_t) ('M');
    fileHeader[2] = (uint8_t) (file_size);
    fileHeader[3] = (uint8_t) (file_size >> 8);
    fileHeader[4] = (uint8_t) (file_size >> 16);
    fileHeader[5] = (uint8_t) (file_size >> 24);
    fileHeader[10] = (uint8_t) (FILE_HEADER_SIZE + INFO_HEADER_SIZE);

    infoHeader[0] = (uint8_t) (INFO_HEADER_SIZE);
    infoHeader[4] = (uint8_t) (width);
    infoHeader[5] = (uint8_t) (width >>  8);
    infoHeader[6] = (uint8_t) (width >> 16);
    infoHeader[7] = (uint8_t) (width >> 24);
    infoHeader[8] = (uint8_t) (height);
    infoHeader[9] = (uint8_t) (height >>  8);
    infoHeader[10] = (uint8_t) (height >> 16);
    infoHeader[11] = (uint8_t) (height >> 24);
    infoHeader[12] = (uint8_t) (1);
    infoHeader[14] = (uint8_t) (BYTES_PER_PIXEL*8);

    file = fopen(file_path, "wb");

    fwrite(fileHeader, 1, FILE_HEADER_SIZE, file);
    fwrite(infoHeader, 1, INFO_HEADER_SIZE, file);

    ptr = (uint8_t *) raster;

    for (i = 0; i < height; i++) {
        fwrite(ptr + (i * width_in_bytes), BYTES_PER_PIXEL, width, file);
        fwrite(padding, 1, padding_size, file);
    }

    fclose(file);
}

void load_bitmap(char *file_path, uint8_t *raster, uint32_t width, uint32_t height)
{
    int width_in_bytes;
    int padding_size;
    int stride;
    int file_size;
    uint32_t i;
    uint8_t padding[3] = {0};
    uint8_t fileHeader[FILE_HEADER_SIZE] = {0};
    uint8_t infoHeader[INFO_HEADER_SIZE] = {0};
    uint8_t *ptr;
    FILE* file;

    width_in_bytes = width * BYTES_PER_PIXEL;
    padding_size = (4 - width_in_bytes % 4) % 4;
    stride = width_in_bytes + padding_size;

    file_size = FILE_HEADER_SIZE + INFO_HEADER_SIZE + (stride * height);

    file = fopen(file_path, "rb");

    fread(fileHeader, 1, FILE_HEADER_SIZE, file);
    fread(infoHeader, 1, INFO_HEADER_SIZE, file);

    ptr = (uint8_t *) raster;

    for (i = 0; i < height; i++) {
        fread(ptr + (i * width_in_bytes), BYTES_PER_PIXEL, width, file);
        fread(padding, 1, padding_size, file);
    }

    fclose(file);
}
