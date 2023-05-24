#include <stdio.h>

#include "bitmap.h"
#include "gpu.h"

uint32_t raster[RASTER_HEIGHT*RASTER_WIDTH];

int main() 
{
    save_bitmap("test.bmp", raster, 16, 16);
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