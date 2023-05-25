#include "transforms.h"

m4_t rotate(v3_t *vec)
{
    fixed_t s, c;

    s = fsin(vec->x[0]);
    c = fcos(vec->x[0]);

    m4_t row = {{
        {  ONE,    0,    0,    0},
        {  0  ,    c,   -s,    0},
        {  0  ,    s,    c,    0},
        {  0  ,    0,    0,  ONE}
    }};

    s = fsin(vec->x[1]);
    c = fcos(vec->x[1]);

    m4_t pitch = {{
        {    c,    0,    s,    0},
        {    0,  ONE,    0,    0},
        {   -s,    0,    c,    0},
        {    0,    0,    0,  ONE}
    }};

    s = fsin(vec->x[2]);
    c = fcos(vec->x[2]);

    m4_t yaw = {{
        {    c,   -s,    0,    0},
        {    s,    c,    0,    0},
        {    0,    0,  ONE,    0},
        {    0,    0,    0,  ONE}
    }};

    m4_t tmp = m4_mul(&row, &pitch);
    return m4_mul(&tmp, &yaw);
}

m4_t scale(v3_t *vec)
{
    fixed_t x, y, z;

    x = vec->x[0];
    y = vec->x[1];
    z = vec->x[2];

    m4_t res = {{
        {    x,    0,    0,    0},
        {    0,    y,    0,    0},
        {    0,    0,    z,    0},
        {    0,    0,    0,  ONE}
    }};

    return res;
}

m4_t translate(v3_t *vec)
{
    fixed_t x, y, z;

    x = vec->x[0];
    y = vec->x[1];
    z = vec->x[2];

    m4_t res = {{
        {  ONE,    0,    0,    x},
        {    0,  ONE,    0,    y},
        {    0,    0,  ONE,    z},
        {    0,    0,    0,  ONE}
    }};

    return res;
}

m4_t perspective(fixed_t near)
{
    fixed_t n = near;

    m4_t res = {{
        {    n,    0,    0,    0},
        {    0,    n,    0,    0},
        {    0,    0,  ONE,    0},
        {    0,    0, -ONE,    0}
    }};

    return res;
}   

m4_t world_to_screen(camera_t *camera) {
    m4_t per, tra, rot, tmp;
    v3_t neg;

    neg.x[0] = -camera->position.x[0];
    neg.x[1] = -camera->position.x[1];
    neg.x[2] = -camera->position.x[2];

    per = perspective(camera->near);
    tra = translate(&neg);
    rot = rotate(&camera->rotation);

    tmp = m4_mul(&per, &tra);
    return m4_mul(&tmp, &rot); 
}