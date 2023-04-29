import matplotlib.pyplot as plt
import numpy as np
import numpy.linalg as npla

from dtypes import *
from transforms import *

def world_to_screen(pos, camera):
    # copy position
    pos = np.copy(pos)

    # vec3 -> vec4
    pos = np.hstack((pos, np.ones((3, 1), dtype=real_dt)))

    # camera transformation matrix
    m = perspective(1) @ rotate(camera['rot']) @ translate(-camera['pos'])

    # apply transformation
    pos = np.asarray([m @ p for p in pos])

    # finish perspective (frustum)
    w = np.copy(pos[:,3])
    pos /= w[:,None]
    pos[:,3] = w

    return pos

def edge(a, b, c):
    return (c[0] - a[0]) * (b[1] - a[1]) - (c[1] - a[1]) * (b[0] - a[0])

def render_triangle(triangle, camera, raster, zbuf):
    v = triangle['vertices']
    
    v = world_to_screen(v, camera)
    
    # remove w
    v = np.delete(v, 3, 1)

    # to raster space
    h, w, _ = raster.shape
    v[:,0] = (v[:,0] + 1) * (w/2)
    v[:,1] = (v[:,1] + 1) * (h/2)

    # compute the inverse of the z coordinate
    v[:,2] = 1 / v[:,2]

    st0 = np.asarray([0, 0, 0], dtype=real_dt)
    st1 = np.asarray([0, 10, 0], dtype=real_dt)
    st2 = np.asarray([10, 0, 0], dtype=real_dt)

    area = edge(v[0], v[1], v[2])

    for j in range(h):
        for i in range(w):
            pixel = np.asarray([i + 0.5, j + 0.5], dtype=real_dt)

            w0 = edge(v[1], v[0], pixel)
            w1 = edge(v[0], v[2], pixel)
            w2 = edge(v[2], v[1], pixel)

            if (w0 < 0 or w1 < 0 or w2 < 0):
                continue

            w0 /= area
            w1 /= area
            w2 /= area
            
            # the z coordinates has already been inverted
            z = 1 / ( v[0][2]*w0 + v[1][2]*w1 + v[2][2]*w2 )

            if z < zbuf[j][i]:
                zbuf[j][i] = z

                st = st0*w0 + st1*w1 + st2*w2
                st *= z 

                # interpolate point using baricentric coordinates
                px = v[0][0]*w0 + v[1][0]*w1 + v[2][0]*w2
                py = v[0][1]*w0 + v[1][1]*w1 + v[2][1]*w2
                pt = np.asarray([px*z, py*z, -z], dtype=real_dt)
                
                # compute normal
                normal = np.cross(v[1] - v[0], v[2] - v[0])
                normal /= npla.norm(normal)

                # compute view direction
                view = -pt
                view /= npla.norm(view)
                
                dot = max(0, np.dot(normal, view))
                
                checker = bool(st[0] % 1.0 > 0.5) != bool(st[1] % 1.0 < 0.5)

                dot *= 255*checker

                raster[j][i][0] = int(dot * 255)
                raster[j][i][1] = int(dot * 255)
                raster[j][i][2] = int(dot * 255)
                

if __name__ == '__main__':
    w = 640
    h = 480

    camera = np.zeros(1, dtype=camera_dt)[0]
    camera['pos'] = [0, 0, 0]
    #camera['rot'] = [np.pi/10e3, 0, np.pi/2]

    triangle = np.zeros(1, dtype=triangle_dt)[0]
    triangle['vertices'] = [
        [1, -1, 2],
        [0, 1, 5],
        [-1, -1, 2]
    ]

    raster = np.zeros((h, w, 3), dtype=color_dt)
    zbuf = np.ones((h, w), dtype=real_dt) * np.inf

    render_triangle(triangle, camera, raster, zbuf)

    plt.imsave('out.png', raster)