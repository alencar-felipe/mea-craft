#!/usr/bin/env python3
"""
Generates mea-craft world
"""
import argparse
import matplotlib.pyplot as plt
import numpy as np

from perlin_noise import PerlinNoise
from random import Random

BLOCK_AIR     =  0
BLOCK_DIRT    =  1
BLOCK_GRASS   =  2
BLOCK_STONE   =  3
BLOCK_COBBLE  =  4
BLOCK_LOG     =  5
BLOCK_LEAFS   =  6
BLOCK_PLANKS  =  7
BLOCK_CRAFT   =  8
BLOCK_COAL    =  9
BLOCK_IRON    = 10
BLOCK_GOLD    = 11
BLOCK_DIAMOND = 12

DELTA_SEA_LEVEL = 10
DELTA_DIRT = 5

def world_gen(width, height, out, seed=1):
    rnd = Random()

    rnd.seed(seed)

    world = np.zeros((height, width), dtype=np.byte)

    noise = PerlinNoise(octaves=15, seed=rnd.randint(0, 2**32))
    
    sea_level = np.asarray([noise([i/width]) for i in range(width)])
    sea_level = np.floor(sea_level * DELTA_SEA_LEVEL).astype(int) + 32

    noise = PerlinNoise(octaves=10, seed=rnd.randint(0, 2**32))

    dirt_height = np.asarray([noise([i/width]) for i in range(width)])
    dirt_height = np.floor(dirt_height * DELTA_DIRT).astype(int) + 5

    for i in range(width):
        sl = sea_level[i]
        dh = dirt_height[i]

        for j in range(height):
            if j < sl - dh:
                world[j][i] = BLOCK_STONE  
            elif j < sl - 1:
                world[j][i] = BLOCK_DIRT
            elif j < sl:
                world[j][i] = BLOCK_GRASS

    for i in range(5, width - 5):
        if rnd.randint(0, 20) == 0:
            make_tree(i, sea_level[i], world)

    with open(out, 'wb') as file:
        file.write(world.tobytes())

def make_tree(i, j, world):
    world[j+0][i+0] = BLOCK_LOG
    world[j+1][i+0] = BLOCK_LOG
    world[j+2][i+0] = BLOCK_LOG
    world[j+3][i+0] = BLOCK_LOG
    world[j+4][i+0] = BLOCK_LOG

    world[j+4][i-2] = BLOCK_LEAFS
    world[j+4][i-1] = BLOCK_LEAFS
    world[j+4][i+1] = BLOCK_LEAFS
    world[j+4][i+2] = BLOCK_LEAFS

    world[j+5][i-2] = BLOCK_LEAFS
    world[j+5][i-1] = BLOCK_LEAFS
    world[j+5][i+0] = BLOCK_LEAFS
    world[j+5][i+1] = BLOCK_LEAFS
    world[j+5][i+2] = BLOCK_LEAFS

    world[j+6][i-1] = BLOCK_LEAFS
    world[j+6][i+0] = BLOCK_LEAFS
    world[j+6][i+1] = BLOCK_LEAFS

    world[j+7][i+0] = BLOCK_LEAFS

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-W', '--width', type=int, default=128,
        help='World width')
    parser.add_argument('-H', '--height', type=int, default=64,
        help='World height')
    parser.add_argument('-s', '--seed', type=int, default=1,
        help='World seed')
    parser.add_argument('-o', '--out', required=True,
        help='Output file path')
    args = parser.parse_args()
    world_gen(**args.__dict__)