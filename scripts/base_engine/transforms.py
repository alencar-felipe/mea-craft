import numpy as np

from dtypes import *

def rotate(vec):
    s = np.sin(vec[0])
    c = np.cos(vec[0])

    row_matrix = np.asarray([
        [ 1,  0,  0,  0],
        [ 0,  c, -s,  0],
        [ 0,  s,  c,  0],
        [ 0,  0,  0,  1]
    ], dtype=real_dt)

    s = np.sin(vec[1])
    c = np.cos(vec[1])

    pitch_matrix = np.asarray([
        [ c,  0,  s,  0],
        [ 0,  1,  0,  0],
        [-s,  0,  c,  0],
        [ 0,  0,  0,  1]
    ], dtype=real_dt)

    s = np.sin(vec[2])
    c = np.cos(vec[2])

    yaw_matrix = np.asarray([
        [ c, -s,  0,  0],
        [ s,  c,  0,  0],
        [ 0,  0,  1,  0],
        [ 0,  0,  0,  1]
    ], dtype=real_dt)
    
    return yaw_matrix @ pitch_matrix @ row_matrix

def scale(vec):
    x, y, z = vec

    return np.asarray([
        [x, 0, 0, 0],
        [0, y, 0, 0],
        [0, 0, z, 0],
        [0, 0, 0, 1]
    ], dtype=real_dt)

def translate(vec):
    x, y, z = vec

    return np.asarray([
        [1, 0, 0, x],
        [0, 1, 0, y],
        [0, 0, 1, z],
        [0, 0, 0, 1]
    ], dtype=real_dt)

def perspective(near):

    n = near

    return np.asarray([
        [ n,  0,  0,  0],
        [ 0,  n,  0,  0],
        [ 0,  0,  1,  0],
        [ 0,  0, -1,  0]
    ])