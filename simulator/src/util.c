#include "util.h"

size_t load_bin(const char* file_path, uint8_t* ptr, size_t max_size) 
{
    FILE* file;
    long file_size;
    size_t bytes_read;

    /* Open file. */

    file = fopen(file_path, "rb");
    if (file == NULL) {
        perror("Error opening file.");
        return 0;
    }

    /* Get the file size. */
    
    if (fseek(file, 0, SEEK_END) != 0) {
        perror("Error seeking to end of file.");
        fclose(file);
        return 0;
    }

    file_size = ftell(file);
    if (file_size < 0) {
        perror("Error getting file size.");
        fclose(file);
        return 0;
    }

    rewind(file);

    /* Verify size. */

    if(file_size > max_size) {
        printf("File will not fit destination.\n");
        fclose(file);
        return 0;
    }

    /* Read the file contents. */
    
    bytes_read = fread(ptr, sizeof(uint8_t), file_size, file);
    if (bytes_read != file_size) {
        perror("Error reading file.");
        fclose(file);
        return 0;
    }

    /* Close file. */

    if (fclose(file) != 0) {
        perror("Error closing file.");
        return 0;
    }

    return file_size;
}