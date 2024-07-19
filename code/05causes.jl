#!/usr/bin/env julia

processed_data::String = "data/processed/stranding_turtles_processed.csv"
df_turtles = CSV.read(processed_data, DataFrame)

## Let's get the Species values
df_causes = combine(
  groupby(df_turtles, [:Cause]), nrow => :Specie
  )

rename!(
  df_causes,
  :Cause => :cause,
  :Specie => :specie
)

## Now the subcauses
df_subcauses = combine(
  groupby(df_turtles, [:Subcause]), nrow => :Specie
  )

rename!(
  df_subcauses,
  :Subcause => :subcause,
  :Specie => :specie
)
