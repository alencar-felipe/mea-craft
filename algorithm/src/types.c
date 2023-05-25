#include "types.h"

void print_fixed(fixed_t n)
{
    float res = ((float) n) / ((float) ONE);
    printf("%.4f", res);
}

void print_v2(v2_t *v) 
{
    for(int i = 0; i < 2; i++) {
        print_fixed(v->x[i]);
        printf(" ");
    }
    printf("\n");
}

void print_v3(v3_t *v) {
    for(int i = 0; i < 3; i++) {
        print_fixed(v->x[i]);
        printf(" ");
    }
    printf("\n");
}

void print_v4(v4_t *v)
{
    for(int i = 0; i < 4; i++) {
        print_fixed(v->x[i]);
        printf(" ");
    }
    printf("\n");
}

void print_m4(m4_t *m)
{
    for(int j = 0; j < 4; j++) {
        for(int i = 0; i < 4; i++) {
            print_fixed(m->x[i][j]);
            printf(" ");
        }
        printf("\n");
    }
    printf("\n");
}
