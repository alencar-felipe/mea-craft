import numpy as np

int_dt = np.int32
real_dt = np.float16
color_dt = np.dtype('uint8')

camera_dt = np.dtype([
    ('pos', real_dt, 3),
    ('rot', real_dt, 3),
    ('near', real_dt)
])

triangle_dt = np.dtype([
    ('vertices', real_dt, (3, 3)),
    ('texture', real_dt, (3, 2))
])