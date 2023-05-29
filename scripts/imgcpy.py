#!/usr/bin/env python3
"""
Transforms an image to packed binary data of 12-bit color depth.
"""

import argparse
from itertools import zip_longest
from PIL import Image

def imgcpy(img_path, out_path):
    img = Image.open(img_path)
    img = img.convert('RGB')

    out_data = bytearray()

    nibbles = nibble_gen(img)
    for a, b in zip_longest(nibbles, nibbles, fillvalue=0):
        out_data.append( (b << 4) | (a << 0) )

    with open(out_path, 'wb') as f:
        f.write(out_data)

def nibble_gen(img):
    width, height = img.size
    
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            yield (r >> 4) & 0xF
            yield (g >> 4) & 0xF
            yield (b >> 4) & 0xF

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('img', help='Image file path')
    parser.add_argument('out', help='Output file path')
    args = parser.parse_args()
    imgcpy(args.img, args.out)