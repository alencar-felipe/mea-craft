#!/usr/bin/env python3
"""
Transforms list of images to packed binary data of 12-bit color depth.
"""

import argparse
from itertools import zip_longest
from PIL import Image

def imgcopy(img_paths, out_path):
    out_data = bytearray()

    for img_path in img_paths:
        offset = len(out_data)
        img_data = get_bytearray(img_path)
        out_data.extend(img_data)
        print(f'{img_path} at 0x{offset:08x}')    
        
    with open(out_path, 'wb') as f:
        f.write(out_data)

def get_bytearray(img_path):
    img = Image.open(img_path)
    img = img.convert('RGB')

    res = bytearray()
    nibbles = nibble_gen(img)
    for a, b in zip_longest(nibbles, nibbles, fillvalue=0):
        res.append( (b << 4) | (a << 0) )

    return res

def nibble_gen(img):
    width, height = img.size
    
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            yield (b >> 4) & 0xF
            yield (g >> 4) & 0xF
            yield (r >> 4) & 0xF

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('img', nargs='+', help='Image file path')
    parser.add_argument('-o', '--out', required=True, help='Output file path')
    args = parser.parse_args()
    imgcopy(args.img, args.out)