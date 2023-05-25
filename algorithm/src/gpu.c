#include "gpu.h"

fixed_t edge(v4_t *a, v4_t *b, v4_t *c)
{
    return fmul(c->x[0] - a->x[0], b->x[1] - a->x[1]) -
        fmul(c->x[1] - a->x[1], b->x[0] - a->x[0]);
}
    
void render_triangle(
    triangle_t *triangle,
    m4_t *world_to_screen,
    uint8_t *texture,
    uint8_t *raster
)
{
    int i, j;
    fixed_t w, area, z, tu, tv;
    fixed_t xmin, xmax, ymin, ymax;
    fixed_t w0, w1, w2;
    v4_t pixel;
    v4_t v[3];
    v2_t t[3];
    
    for(i = 0; i < 3; i++) {
        // copy data
        v[i].x[0] = triangle->vertices[i].x[0];
        v[i].x[1] = triangle->vertices[i].x[1];
        v[i].x[2] = triangle->vertices[i].x[2];
        t[i] = triangle->texture[i];

        // world to screen
        v[i] = m4_v4_mul(world_to_screen, &v[i]);
        
        // finish perspective
        w = v[i].x[2];
        v[i].x[0] = fdiv(v[i].x[0], w);
        v[i].x[1] = fdiv(v[i].x[1], w);
        v[i].x[2] = -w;

        // to raster space
        v[i].x[0] = (v[i].x[0] + ONE)*(RASTER_WIDTH/2);
        v[i].x[1] = (RASTER_HEIGHT/2)*ONE - v[i].x[1]*(RASTER_WIDTH/2);

        // divide texture coordinate by z
        t[i].x[0] = fdiv(t[i].x[0], v[i].x[2]);
        t[i].x[1] = fdiv(t[i].x[1], v[i].x[2]);
    }

    // compute limits
    xmin = MIN(MIN(v[0].x[0], v[1].x[0]), v[2].x[0]) >> FIXED_BIT;
    xmax = MAX(MAX(v[0].x[0], v[1].x[0]), v[2].x[0]) >> FIXED_BIT;
    ymin = MIN(MIN(v[0].x[1], v[1].x[1]), v[2].x[1]) >> FIXED_BIT;
    ymax = MAX(MAX(v[0].x[1], v[1].x[1]), v[2].x[1]) >> FIXED_BIT;
    
    area = edge(&v[0], &v[1], &v[2]);

    for(j = ymin; j <= ymax; j++) {
        for(i = xmin; i <= xmax; i++) {
            pixel.x[0] = (i*ONE) + 0.5*ONE;
            pixel.x[1] = (j*ONE) + 0.5*ONE;

            w0 = edge(&v[1], &v[2], &pixel);
            w1 = edge(&v[2], &v[0], &pixel);
            w2 = edge(&v[0], &v[1], &pixel);

            // culling
            if (w0 < 0 || w1 < 0 || w2 < 0) {
                continue;
            }

            w0 = fdiv(w0, area);
            w1 = fdiv(w1, area);
            w2 = fdiv(w2, area);

            z = fdiv(ONE, fdiv(w0, v[0].x[2]) + fdiv(w1, v[1].x[2]) + fdiv(w2, v[2].x[2]));

            // interpolate point baricentric coordinates
            tu = fmul(t[0].x[0], w0) + fmul(t[1].x[0], w1) + fmul(t[2].x[0], w2);
            tv = fmul(t[0].x[1], w0) + fmul(t[1].x[1], w1) + fmul(t[2].x[1], w2);
            
            tu = fmul(tu, z);
            tv = fmul(tv, z);

            // fixed to int
            tu = tu >> FIXED_BIT; 
            tv = tv >> FIXED_BIT;

            if (tu >= 0 && tu < TEXTURE_WIDTH && tv >= 0 && tv < TEXTURE_HEIGHT) {
                for(int k = 0; k < 3; k++) {
                    raster[3*(i + j*RASTER_WIDTH) + k] = texture[3*(tu + tv*TEXTURE_WIDTH) + k];
                }
            }
        }
    }
}