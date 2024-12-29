#!/usr/bin/env julia

using
  CSV,
  DataFrames,
  DataFramesMeta

## Counting the total species of the data sets
df_turtles = CSV.read("data/processed/stranding_turtles_processed.csv", DataFrame)
## Filter from 2000 to 2021

## Looking for the turtles of the data-set
#unique(df_turtles.Specie)
## 4-element Vector{String31}:
##  "Caretta caretta"
##  "Chelonia mydas"
##  "Eretmochelys imbricata"
##  "Dermochelys coriacea"
df_species_turtles = combine(groupby(df_turtles, ["Specie", "Common name"]), nrow => :n)

df_species_turtles[:,:percentage] = round.(
  (df_species_turtles.n ./ sum(df_species_turtles.n) * 100), digits=2
  )

rename!(
  df_species_turtles,
  "Specie" => "Especie",
  "Common name" => "Nombre común",
  "n" => "Número de tortugas",
  "percentage" => "Porcentaje"
)

table_turtles = rcopy(
R"""
$df_species_turtles |>
  mutate(
    `Nombre común` = case_when(
      `Nombre común` == "Loggerhead Sea Turtle" ~ "Tortuga Boba",
      `Nombre común` == "Green Sea Turtle" ~ "Tortuga verde",
      `Nombre común` == "Hawksbill Sea Turtle" ~ "Tortuga carey",
      `Nombre común` == "Leatherback Sea Turtle" ~ "Tortuga laúd"
      ),
    Porcentaje = paste(Porcentaje, "%")
  )
"""
)

CSV.write("./_assets/menu1/tableinput/dunn_test_seasons.csv", table_turtles)