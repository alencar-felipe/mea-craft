import matplotlib.pyplot as plt
import numpy as np
import numpy.linalg as npla

from dtypes import *
from numba import jit
from transforms import *

def world_to_screen(pos, camera):
    # copy position
    pos = np.copy(pos)

    # vec3 -> vec4
    pos = np.hstack((pos, np.ones((3, 1))))

    # camera transformation matrix
    m = perspective(camera['near'])
    m = m @ translate(-camera['pos'])
    m = m @ rotate(camera['rot'])
    
    # apply transformation
    pos = np.asarray([m @ p for p in pos])

    # finish perspective (frustum)
    w = np.copy(pos[:,3])
    pos /= -w[:,None]
    pos[:,2] = -w

    return pos

def edge(a, b, c):
    return (c[0] - a[0]) * (b[1] - a[1]) - (c[1] - a[1]) * (b[0] - a[0])

def render_triangle(triangle, texture, camera, raster, zbuf):
    v = np.copy(triangle['vertices'])
    t = np.copy(triangle['texture'])
    th, tw, _ = texture.shape

    v = world_to_screen(v, camera)
    
    # remove w
    v = np.delete(v, 3, 1)

    # to raster space
    h, w, _ = raster.shape
    v[:,0] = (v[:,0] + 1) * (w/2)
    v[:,1] = (h/2) - v[:,1]*(w/2)

    # compute the inverse of the z coordinate
    v[:,2] = 1 / v[:,2]
    
    # compute the inverse of the texture coordinate
    t[:,0] *= v[:,2]
    t[:,1] *= v[:,2]

    xmin = min(v[:, 0])
    ymin = min(v[:, 1])
    xmax = max(v[:, 0])
    ymax = max(v[:, 1])
        
    # the triangle is out of screen
    if xmin > w - 1 or xmax < 0 or ymin > h - 1 or ymax < 0:
        return

    area = edge(v[0], v[1], v[2])

    for j in range(h):
        for i in range(w):
            pixel = np.asarray([i + 0.5, j + 0.5], dtype=real_dt)

            w0 = edge(v[1], v[2], pixel)
            w1 = edge(v[2], v[0], pixel)
            w2 = edge(v[0], v[1], pixel)

            # culling
            if (w0 < 0 or w1 < 0 or w2 < 0):
                continue
            
            w0 /= area
            w1 /= area
            w2 /= area
            
            # the z coordinates has already been inverted
            z = 1 / ( v[0][2]*w0 + v[1][2]*w1 + v[2][2]*w2 )

            if z < zbuf[j][i]:
                zbuf[j][i] = z
                
                # interpolate point baricentric coordinates
                uvt = t[0]*w0 + t[1]*w1 + t[2]*w2
                uvt = uvt * z * [tw, th]
                uvt = uvt.astype(int)

                if uvt[1] > 0 and uvt[1] < th and uvt[0] > 0 and uvt[0] < tw:
                    raster[j][i] = texture[uvt[1]][uvt[0]]*255
         
def cube(pos, rot, scl):
    verts = [
        [-1,+1,-1], [+1,+1,-1], [-1,-1,-1], [+1,-1,-1],
        [-1,-1,+1], [+1,-1,+1], [-1,+1,+1], [+1,+1,+1]
    ]

    indexes = [
        [0, 2, 1], [2, 4, 3], [4, 6, 5], [6, 0, 7], [0, 6, 2], [3, 5, 1],
        [1, 2, 3], [3, 4, 5], [5, 6, 7], [7, 0, 1], [2, 6, 4], [7, 5, 1]
    ]

    textures = [[[0, 0], [0, 1], [1, 0]]]*6 + [[[1, 0], [0, 1], [1, 1]]]*6

    triangles = np.zeros(8, dtype=triangle_dt)

    m = translate(pos) @ rotate(rot) @ scale(scl)

    for p, i, t in zip(triangles, indexes, textures):
        d4 = np.asarray([(*verts[j], 1) for j in i])
        d4 = np.asarray([m @ p for p in d4])
        p['vertices'] = d4[:,:3] / d4[:,3]
        p['texture'] = t
        
    return triangles
    
if __name__ == '__main__':
    w = 640
    h = 480

    camera = np.zeros(1, dtype=camera_dt)[0]
    camera['near'] = 1
    camera['pos'] = [0, 0, 0]
    camera['rot'] = [0, 0, 0]

    triangles = cube(
        [0, 0, 5],
        [-np.pi/8, np.pi/8, 0],
        [1, 1, 1]
    )

    texture = plt.imread('texture.png')

    raster = np.zeros((h, w, 3), dtype=color_dt)
    zbuf = np.ones((h, w), dtype=real_dt) * np.inf

    for triangle in triangles:
        render_triangle(triangle, texture, camera, raster, zbuf)

    plt.imsave('out.png', raster)