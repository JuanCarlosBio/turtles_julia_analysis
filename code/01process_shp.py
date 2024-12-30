#!/usr/bin/env python3

## Forgive me gods of Julia, 
# not for what i have done, 
# but for what i am about to do

import geopandas as gpd
import pandas as pd

## Reading the data 
canary_islands_municipality = gpd.read_file("data/raw/municipios.shp")
df_turtles = pd.read_csv("data/processed/stranding_turtles_processed.csv")

## Filtering the Gran Canaria Municipality
gc_municipality = canary_islands_municipality[
  canary_islands_municipality["isla"] == "TENERIFE"
]

gc_municipality.municipio = gc_municipality.municipio.str.lower()
gc_municipality = gc_municipality[["municipio", "geometry"]]
gc_municipality = (
  gc_municipality
    .rename(columns={
      "municipio": "Municipality", 
      "geometry": "geometry"
    })
  )

df_turtles.Municipality = (
  df_turtles
    .Municipality
    .str
    .lower()
  )

df_turtles_muni_summary = (
  df_turtles
    .groupby(["Municipality"])
    .size()
    .reset_index(name="n")
  )

merged_df = (
  pd
    .merge(gc_municipality, 
           df_turtles_muni_summary, 
           on="Municipality", 
           how="left")
  )

## To view in a map the results
#import matplotlib.pyplot  as plt
#merged_df.plot()
#plt.show()
merged_df.to_file("data/processed/gc_municipality_turtles.shp")

