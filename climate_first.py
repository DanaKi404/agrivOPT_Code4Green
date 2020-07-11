#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Make climate great again
"""


import os
import numpy as np

import rasterio as rio
from rasterio.plot import show
from rasterio.plot import show_hist

import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import matplotlib.colors as colors

file = './data/PVGIS/gh_opt_year.asc'

# Open the file:
    
with rio.open(file) as src:
    raster = src.read(1, masked=True)
    sjer_ext = rio.plot.plotting_extent(src)

#plot raster
# Define the colors you want
cmap = ListedColormap(["white", "tan", "springgreen", "darkgreen"])
# Define a normalization from values -> colors
norm = colors.BoundaryNorm([0, 2, 10, 20, 30], 5)

fig, ax = plt.subplots(figsize=(12, 8))

chm_plot = ax.imshow(raster)
ax.set_title("Lidar Canopy Height Model (CHM)", fontsize=16)
#ep.colorbar(chm_plot)
ax.set_axis_off()
plt.show()

