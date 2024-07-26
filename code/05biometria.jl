#!/usr/bin/env julia

using
  CSV,
  DataFrames,
  DataFramesMeta,
  CategoricalArrays,
  RCall,
  Statistics,
  MultivariateStats

## Librerías de R

R"""
suppressMessages({
  library(tidyverse)
  library(ggtext)
  library(glue)
})
"""

##==================##
## Loading the data ##
##==================##

processed_data::String = "data/processed/stranding_turtles_processed.csv"
df_turtles = CSV.read(processed_data, DataFrame)

##====================================##
## Processing to year and season data ##
##====================================##

## Rename the biometric variables
rename!(
  df_turtles,
  "SCL (cm)" => :scl_cm,
  "SCW(cm)" => :scw_cm,
  "CCL (cm)" => :ccl_cm,
  "CCW (cm)" => :ccw_cm,
  "Weight (kg)" => :weight_kg
)

## selecting the variables:
df_turtles_biometry = df_turtles[
  !,
  [:Specie, :scl_cm, :scw_cm, :ccl_cm, :ccw_cm, :weight_kg],
]

## Drop the missing values, we will study only the data complete
dropmissing!(df_turtles_biometry)
biometrics_variables = ["scl_cm", "scw_cm", "ccl_cm", "ccw_cm", "weight_kg"]
## Replace the "," for "."
for col in biometrics_variables

  ## Let's create a temporary file, to change the "," for "." in the
  ## biometry variables
  temp = replace.(df_turtles_biometry[:,col], "," => ".")

  ## Then let's transform the Strings to Floats
  df_turtles_biometry[!, col] = parse.(Float64, temp)

end

df_turtles_biometry.age = [
  ccl_cm < 20 ? "Hatchling"      :
  ccl_cm < 40 ? "Small Juvenile" :
  ccl_cm < 60 ? "Big Juvenile"   :    
  ccl_cm < 80 ? "Subadult"       : "Adult" for ccl_cm in df_turtles_biometry.ccl_cm
]

filter!(row -> row.weight_kg < 160, df_turtles_biometry)

## Transform the wide data to longer
df_turtles_biometry_long = stack(
  df_turtles_biometry, 
  2:ncol(df_turtles_biometry) -1
  )

rename!(
  df_turtles_biometry_long,
  :variable => :biometry_names,
  :value => :biometry_value
)

##======================##
## STATISTICAL ANALYSIS ##
##======================##

## turtle Ages based on the CCL BTW there is only Caretta caretta 
df_ccl = filter(row -> row.biometry_names == "ccl_cm", df_turtles_biometry_long)

df_ccl_summary = combine(groupby(df_ccl, :age), nrow => :n)

R"""
df_cclR <- $df_ccl_summary
ccaretta_biometry <- df_cclR %>%
  mutate(age = factor(
    age,
    levels = c("Hatchling", "Small Juvenile", "Big Juvenile", "Subadult", "Adult"),
    labels = c("<20cm\nCría", "20-40cm\nJuvenil\nPequeño", 
               "40-60cm\nJuvenil\nGrande", "60-80cm\nSubadulto", 
               ">80\nAdulto"))) %>%
  ggplot(aes(age, n)) +
  geom_col(color = "black", width = .75, fill = "#ffa500") +
  geom_text(aes(label = n), position = "identity", vjust = -.5, fontface="bold") + 
  labs(
    title = "Estimación del ciclo de vida de *Caretta caretta*",
    x = "Ciclo de vida de la tortuga",
    y = "Número de tortugas" 
  ) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0, max(df_cclR$n) + (max(df_cclR$n) * 0.2))
  ) +
  theme_classic() + 
  theme(
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    axis.line.x  = element_line(),
    plot.title = element_markdown(
      size = 13,
      margin = margin(b = .5, unit = "lines"),
      face = "bold", 
      hjust = .5
    ),
    axis.title.x = element_text(
      margin = margin(t = 5),
      size = 10,
      face = "bold"
    ),
    axis.title.y = element_text(
      margin = margin(r = 10), 
      size = 10,
      face = "bold"
    ),
    axis.ticks.x = element_blank(),
    axis.text = element_text(size = 10.5),
    plot.caption =  element_text(hjust = 0, face = "italic")
  ) 

ggsave(
  filename = "./_assets/figures/plots/C.caretta_biometry_age.png", 
  plot = ccaretta_biometry,
  width = 6,
  height = 4 
  )
"""

## Visualize the longer data to see the data distribution in histograms
R"""
df_turtles_biometry_R <- $df_turtles_biometry_long

df_turtles_biometry_R %>%
  ggplot(aes(x = biometry_value, fill = biometry_names)) +
  geom_histogram(color = "black") +
  facet_wrap(~biometry_names, scales="free") 
"""

##============##
##  PCA Model ##
##============##

# Assuming df_turtles_biometry is already loaded with your data
# Example data load (replace with your actual data loading method)
# df_turtles_biometry = DataFrame(...)

# Total number of rows
n_rows = nrow(df_turtles_biometry)

# Calculate the 70% split index
split_idx = round(Int, 0.7 * n_rows)

# Split the data into training and testing sets
train_indices = 1:split_idx
test_indices = (split_idx + 1):n_rows

# Extract training and testing data
Xtr = Matrix(df_turtles_biometry[train_indices, 2:6])'
Xtr_labels = Vector(df_turtles_biometry[train_indices, 7])

Xte = Matrix(df_turtles_biometry[test_indices, 2:6])'
Xte_labels = Vector(df_turtles_biometry[test_indices, 7])

# Fit the PCA model
M = fit(PCA, Xtr; maxoutdim=3)

# Predict using the PCA model
Yte = predict(M, Xte)

# Reconstruct the data
Xr = reconstruct(M, Yte)

# Create DataFrames for PCA results
df_Yte = DataFrame(Yte', :auto)  # Transpose Yte to get samples as rows
rename!(df_Yte, Symbol.("PC" .* string.(1:size(Yte, 1))))

# Add the labels to the transformed data DataFrame
df_Yte.age = Xte_labels

## Reconstruct the data no idea
df_Xr = DataFrame(Xr', :auto)  # Transpose Xr to get samples as rows
rename!(df_Xr, names(df_turtles_biometry)[2:6])  #

## Getting the variance explained by the model of the PC
pc_variance_explained = principalvars(M) 
total_variance_explained = sum(pc_variance_explained) 
pc1_variance_expalained = round((pc_variance_explained[1] / total_variance_explained) * 100, digits = 2)
pc2_variance_expalained = round((pc_variance_explained[2] / total_variance_explained) * 100, digits = 2)

## Plotting the data
R"""
df_YteR <- $df_Yte %>%
  mutate(
    age = factor(
      age,
      levels = c("Hatchling", "Small Juvenile", "Big Juvenile", "Subadult", "Adult"),
      labels = c("Cría", "Juvenil Pequeño", "Juvenil Grande", "Subadulto", "Adulto")
    )
  )

pc1_variance_expalainedR <- $pc1_variance_expalained
pc2_variance_expalainedR <- $pc2_variance_expalained

PCA_biometry <-  df_YteR %>%
  ggplot(aes(PC1, PC2, color = age, fill = age)) + 
  geom_point() +
  stat_ellipse(geom = "polygon", alpha = .25) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(
    values = c("red", "forestgreen", "blue", "orange")
  ) +
  scale_fill_manual(
    values = c("pink", "green", "skyblue", "yellow")
  ) +
  labs(
    title = "Predicción del modelo PCA para las varables biométricas",
    x = glue("PC1 ({pc1_variance_expalainedR} % varianza explicada)"),
    y = glue("PC2 ({pc2_variance_expalainedR} % varianza explicada)"),
    color = "Ciclo de vida",
    fill = "Ciclo de vida"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", margin = margin(b = 10),
                              size = 12),
    axis.title = element_text(face = "bold"),
    legend.title = element_text(face="bold", hjust = .5),
    legend.position = c(.8, .8),
    legend.background = element_rect(color = "black")
  )

ggsave(
  filename = "./_assets/figures/plots/PCA_biometry.png", 
  plot = PCA_biometry,
  width = 6,
  height = 5 
)
"""