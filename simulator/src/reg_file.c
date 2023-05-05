#include "reg_file.h"

word_t reg_file(
    word_t read_address_a,
    word_t *read_data_a,
    word_t read_address_b,
    word_t *read_data_b,
    word_t write_address,
    word_t write_data,
    word_t write_enable,
    word_t *data
)
{
    word_t ret = ERROR_OK;

    if(write_address < REG_FILE_LEN) {
        if(write_address) {
            data[write_address] = write_data;
        }
    } else {
        ret = ERROR_REG_FILE;
    }

    // x0 is always 0, writes to it are ignored
    data[0] = 0;

    if(read_address_a < REG_FILE_LEN) {
        *read_data_a = data[read_address_a];
    } else {
        ret = ERROR_REG_FILE;
    }

    if(read_address_b < REG_FILE_LEN) {
        *read_data_b = data[read_address_b];
    } else {
        ret = ERROR_REG_FILE;
    }

    return ret;
}