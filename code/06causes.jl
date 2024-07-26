#!/usr/bin/env julia

using
  DataFrames,
  DataFramesMeta,
  CSV,
  RCall

R"""
suppressMessages(suppressWarnings({
  library(tidyverse)
  library(glue)
  library(ggtext)
  library(gt)
  library(htmltools)
}))
"""

processed_data::String = "data/processed/stranding_turtles_processed.csv"
df_turtles = CSV.read(processed_data, DataFrame)

## Let's get the Species values
df_causes = combine(
  groupby(df_turtles, [:Cause]), nrow => :Specie
  )

rename!(
  df_causes,
  :Cause => :cause,
  :Specie => :n
)

df_causes.percentage = round.((df_causes.n / sum(df_causes.n)) * 100, digits = 1) 

## Now the subcauses
df_subcauses = combine(
  groupby(df_turtles, [:Subcause]), nrow => :Specie
  )

rename!(
  df_subcauses,
  :Subcause => :subcause,
  :Specie => :n
)

## Max Percentage values
max_percentage_causes = maximum(df_causes.percentage)

R"""
df_causesR <- $df_causes %>% 
  as_tibble() %>%
  arrange(desc(n))
  

causes_barplot <- df_causesR %>% 
  mutate(cause = factor(
    cause,
    levels = unique(df_causesR$cause)
  )) %>%
  ggplot(aes(cause, percentage, fill = percentage)) +
  geom_col(width = .5, color = "black", show.legend = FALSE) +
  geom_text(
    aes(label = glue("{percentage} %")),
    position = "stack",
    vjust = -.5) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0,$max_percentage_causes + 10)
    ) +
  scale_x_discrete(
    labels = c("Equipo de\npesca",
               "Enfermedad",
               "Otras",
               "Trauma",
               "Plástico",
               "Petróleo\ncrudo",
               "Indeterminada",
               "Muerte\nnatural")
    ) +
  scale_fill_gradient(low = "blue", high = "red") +
  labs(
    title = "Causas de los varamientos de tortugas marinas en Tenerife",
    subtitle = glue("<i>Número total de varamientos registrados: **{sum(df_causesR$n)}</i>**"),
    x = "Cause del variamiento",
    y = "Porcentaje" 
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", hjust = .5),
    plot.subtitle = element_markdown(),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(color = "black"),
    axis.ticks.x = element_blank()
  )

ggsave(
  filename = "./_assets/figures/plots/barplot_causes.png", 
  plot = causes_barplot,
  width = 7,
  height =5 
)  
"""

## =============================== ##
## Study of the subcauses per year
## =============================== ##

df_causes_years = df_turtles[:,[:Cause, :year]]

rename!(
  df_causes_years, 
  :Cause => :cause,
)

df_causes_years.year = string.(df_causes_years.year)

year_causes_grid = DataFrame(
  vec(collect(Base.product(
    string.(levels(df_causes_years.year)),
    string.(levels(df_causes_years.cause))
  )))
)

rename!(
  year_causes_grid,
  :1 => :year,
  :2 => :cause
)

n_df_causes_years = combine(
  groupby(df_causes_years, [:cause, :year]), 
  nrow => :n)

df_summary_year_causes_joined = leftjoin(
  year_causes_grid, 
  n_df_causes_years, 
  on = [:year, :cause]
  )

df_summary_year_causes_joined[!, :n] = ifelse.(
  ismissing.(df_summary_year_causes_joined.n), 0, df_summary_year_causes_joined.n
  )

df_summary_year_causes_joined.year = parse.(Int, df_summary_year_causes_joined.year)

# max_year_arrave = maximum(
#   combine(groupby(
#     df_summary_year_causes_joined, 
#     :year), :n => sum => :n
#     ).n
#   )

## Raw years and causes
R"""
year_causes_barplot <- $df_summary_year_causes_joined %>%
  filter(n > 0) %>%
  ggplot(aes(year, n, fill = reorder(cause,n))) +
  geom_col(color = "black", alpha=.5) +
  geom_text(aes(year, n, label = n), position = position_stack(vjust = .5)) +
  scale_fill_manual(values = c(
    "white", "gray", "yellow", "blue", "forestgreen", "orange", "magenta", "red"
  )) +
  scale_x_continuous(
    breaks = seq(2000,2021,1)
  ) +
  scale_y_continuous(expand = expansion(0)) +
  labs(
    title = "Causas de los varamientos de tortugas cada año",
    x = "Año",
    y = "Número de tortugas",
    fill = "Causas"
  ) +
  theme_classic() +
  theme(
    axis.y.line = element_blank(),
    plot.title = element_text(face = "bold", hjust = .5, size = 15),
    plot.subtitle = element_markdown(),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(angle = 270, hjust = 1, vjust = .5),
    axis.ticks.x = element_blank(),
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 12)
  )

ggsave(
  filename = "./_assets/figures/plots/year_causes_barplot.png", 
  plot = year_causes_barplot,
  width = 11,
  height = 7 
)
"""

## Percentage by the years
R"""
year_causes_percentage_barplot <- $df_summary_year_causes_joined %>%
  filter(n > 0) %>%
  group_by(year) %>%
  mutate(percentage = (n/sum(n))*100) %>%
  ggplot(aes(year, percentage,fill = reorder(cause,percentage))) +
  geom_col(color = "black", alpha=.5) +
  geom_text(
    aes(year, percentage, label = glue("{round(percentage, 1)}")), 
    position = position_stack(vjust = .5)
  ) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0,100),
    breaks = seq(0,100,15)
  ) +
  scale_fill_manual(values = c(
    "white", 
    "gray", 
    "yellow", 
    "blue", 
    "forestgreen", 
    "orange", 
    "magenta", 
    "red"
  )) +
  scale_x_continuous(
    breaks = seq(2000,2021,1)
  ) +
  labs(
    title = "Porcentaje de las causas de los varamientos",
    x = "Año",
    y = "Porcentaje (%)",
    fill = "Causa"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", hjust = .5, size = 15),
    plot.subtitle = element_markdown(),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(angle = 270, hjust = 1, vjust = .5),
    axis.ticks.x = element_blank(),
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 12)
  )

ggsave(
  filename = "./_assets/figures/plots/year_causes_percentage_barplot.png", 
  plot = year_causes_percentage_barplot,
  width = 11,
  height = 7 
)
"""
