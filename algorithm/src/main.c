#include <stdio.h>
#include <string.h>

#include "bitmap.h"
#include "gpu.h"
#include "transforms.h"

uint8_t raster[RASTER_WIDTH*RASTER_HEIGHT*3];
uint8_t texture[TEXTURE_WIDTH*TEXTURE_HEIGHT*3];

camera_t camera = {
    {{0, 0, 0}},
    {{0, 0, PI/10}},
    ONE
};

const fixed_t z = 2*ONE;

triangle_t triangle1 = {
    { {{0, 0, z}}, {{ONE, 0, z}}, {{0, ONE, z}} },
    { {{0, 0}}, {{15*ONE, 0}}, {{0, 15*ONE}} }
};

triangle_t triangle2 = {
    { {{ONE, 0, z}}, {{ONE, ONE, z}}, {{0, ONE, z}} },
    { {{15*ONE, 0}}, {{15*ONE, 15*ONE}}, {{0, 15*ONE}} }
};

int main() 
{
    load_bitmap("texture.bmp", texture, TEXTURE_WIDTH, TEXTURE_HEIGHT);

    m4_t w2s = world_to_screen(&camera);

    render_triangle(&triangle1, &w2s, texture, raster);
    render_triangle(&triangle2, &w2s, texture, raster);

    save_bitmap("./build/raster.bmp", raster, RASTER_WIDTH, RASTER_HEIGHT);
    return 0;
}

/*
void cube(v3_t position)
{
    verts = [
        [-1,+1,-1], [+1,+1,-1], [-1,-1,-1], [+1,-1,-1],
        [-1,-1,+1], [+1,-1,+1], [-1,+1,+1], [+1,+1,+1]
    ]

    indexes = [
        [0, 2, 1], [2, 4, 3], [4, 6, 5], [6, 0, 7], [0, 6, 2], [3, 5, 1],
        [1, 2, 3], [3, 4, 5], [5, 6, 7], [7, 0, 1], [2, 6, 4], [1, 5, 7]
    ]

    textures = [[[0, 0], [0, 1], [1, 0]]]*6 + [[[1, 0], [0, 1], [1, 1]]]*6

    triangles = np.zeros(12, dtype=triangle_dt)

    for p, i, t in zip(triangles, indexes, textures):
        d4 = np.asarray([(*verts[j], 1) for j in i])
        d4 = np.asarray([m @ p for p in d4])
        p['vertices'] = d4[:,:3] / d4[:,3]
        p['texture'] = t
        
    return triangles
}
*/
/*
if __name__ == '__main__':
    w = 320
    h = 240

    camera = np.zeros(1, dtype=camera_dt)[0]
    camera['near'] = 1
    camera['pos'] = [0, 0, 0]
    camera['rot'] = [0, 0, 0]

    triangles = cube(
        [0, 0, 5],
        [-np.pi/8, np.pi/8, np.pi],
        [1, 1, 1]
    )

    texture = plt.imread('texture.png')

    raster = np.zeros((h, w, 3), dtype=color_dt)
    zbuf = np.ones((h, w), dtype=real_dt) * np.inf

    for triangle in triangles:
        render_triangle(triangle, texture, camera, raster, zbuf)

    plt.imsave('out.png', raster)
*/