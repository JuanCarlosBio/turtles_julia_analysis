#!/usr/bin/env python

import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.patches import Patch

#import os
#os.listdir()

islands = gpd.read_file("data/raw/municipios.shp")
turtles_distribution = pd.read_csv("turtle_distribution_turtles.csv")

islands_distributions = islands.merge(turtles_distribution, on="isla", how="left")

turtles_list = turtles_distribution["especie"].unique()
color_list = ["orange", "blue", "yellow", "forestgreen"]

# Configurar el tamaño de la figura (ancho, alto)
plt.figure(figsize=(10, 5))  # Cambia el tamaño a tu preferencia

for specie, color in zip(turtles_list, color_list):
    distribution_specie = islands_distributions[islands_distributions["especie"] == specie]
    
    p = distribution_specie.plot(
        column="is_especie",
        cmap=ListedColormap([color, "lightgray"]),
        edgecolor="black",
        legend=True
    )
    
    plt.title(f"Avistamientos de la {specie} en el Archipiélago")
    p.set_axis_off()
    
    plt.savefig(f"_assets/figures/distribution_{specie}.png", format="png")

    plt.close()  # Cierra la figura después de guardar para evitar sobreposiciones