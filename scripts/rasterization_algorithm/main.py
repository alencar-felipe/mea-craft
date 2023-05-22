import matplotlib.pyplot as plt
import numpy as np
import numpy.linalg as npla

from dtypes import *
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

def range_triangle(vs):
    x1, x2, x3 = vs[0][0], vs[1][0], v[2][0]
    y1, y2, y3 = vs[0][0], vs[1][0], v[2][0]

    # Sort vertices by y-coordinate
    if y1 > y2:
        y1, y2 = y2, y1
        x1, x2 = x2, x1
    if y2 > y3:
        y2, y3 = y3, y2
        x2, x3 = x3, x2
    if y1 > y2:
        y1, y2 = y2, y1
        x1, x2 = x2, x1

    # Calculate slopes of the three edges
    slope1 = (x2 - x1) / (y2 - y1) if y2 != y1 else 0
    slope2 = (x3 - x2) / (y3 - y2) if y3 != y2 else 0
    slope3 = (x3 - x1) / (y3 - y1) if y3 != y1 else 0

    # Initialize x-coordinates of edges at top vertex
    x_top = x1
    x_bottom_left = x1
    x_bottom_right = x2

    # Draw scanlines
    for y in range(y1, y3 + 1):
        # Draw pixels between left and right edges
        for x in range(round(x_bottom_left), round(x_bottom_right) + 1):
            yield (x, y)

        # Update x-coordinates of edges for next scanline
        if y < y2:
            x_top += slope1
            x_bottom_left += slope3
        else:
            x_top += slope2
            x_bottom_right += slope3

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
    
    # divide texture coordinate by z
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

    for j in range(int(ymin), int(ymax+1)):
        for i in range(int(xmin), int(xmax+1)):
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

            if z < zbuf[j][i] or True:
                zbuf[j][i] = z
                
                # interpolate point baricentric coordinates
                uvt = t[0]*w0 + t[1]*w1 + t[2]*w2
                uvt = uvt * z * [tw, th]
                uvt = uvt.astype(int)

                if uvt[1] >= 0 and uvt[1] < th and uvt[0] >= 0 and uvt[0] < tw:
                    raster[j][i] = texture[uvt[1]][uvt[0]]*255
         
def cube(pos, rot, scl):
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

    m = translate(pos) @ rotate(rot) @ scale(scl)

    for p, i, t in zip(triangles, indexes, textures):
        d4 = np.asarray([(*verts[j], 1) for j in i])
        d4 = np.asarray([m @ p for p in d4])
        p['vertices'] = d4[:,:3] / d4[:,3]
        p['texture'] = t
        
    return triangles
    
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