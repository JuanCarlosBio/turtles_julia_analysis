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

## turtle Ages based on the CCL
df_ccl = filter(row -> row.biometry_names == "ccl_cm", df_turtles_biometry_long)

df_ccl_summary = combine(groupby(df_ccl, :age), nrow => :biometry_names)

R"""
df_cclR <- $df_ccl_summary
df_cclR %>%
  mutate(age = factor(
    age,
    levels = c("Hatchling", "Small Juvenile", "Big Juvenile", "Subadult", "Adult"
  ))) %>%
  ggplot(aes(age, biometry_names)) +
  geom_col() 
"""

## Visualize the longer data to see the data distribution in histograms
R"""
df_turtles_biometry_R <- $df_turtles_biometry_long

df_turtles_biometry_R %>%
  ggplot(aes(x = biometry_value, fill = biometry_names)) +
  geom_histogram(color = "black") +
  facet_wrap(~biometry_names, scales="free") 
"""

## split half to trainig sets (Machine learning b*)
X = Matrix(df_turtles_biometry[:,2:ncol(df_turtles_biometry)-2])
Xtr_labels = Vector(df_turtles_biometry[:, ncol(df_turtles_biometry)])
# Fit the PCA model allowing 3 dimensions
Model = fit(PCA, X; maxoutdim = 3)

proj = projection(Model) 

df_PCA = DataFrame(proj, :auto)
rename!(
  df_PCA,
  :x1 => :PC1,
  :x2 => :PC2,
  :x3 => :PC3
)

df_PCA[!,"age"] = Xtr_labels

R"""
df_PCAR <- $df_PCA %>%
  mutate(
    age = factor(
      age,
      levels = c("Hatchling", "Small Juvenile", "Big Juvenile", "Subadult", "Adult"),
    )
  )

df_PCAR %>%
  ggplot(aes(PC1, PC2, color = age, fill = age)) + 
  geom_point() +
  stat_ellipse(geom = "polygon", alpha = .25)
"""