import numpy as np

real_dt = np.float32
color_dt = np.dtype('uint8')

camera_dt = np.dtype([
    ('pos', real_dt, 3),
    ('rot', real_dt, 3),
    ('near', real_dt)
])

triangle_dt = np.dtype([
    ('vertices', real_dt, (3, 3))
])