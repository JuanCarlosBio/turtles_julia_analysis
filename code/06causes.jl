#!/usr/bin/env julia

using
  DataFrames,
  DataFramesMeta,
  CSV,
  Statistics,
  Tidier,
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

## Translate this becouse the webpage is spanish from ESPAÑA
df_turtles = @chain df_turtles begin
  @mutate(
    Cause = case_when(
      Cause == "Fishing gear"   => "Equipo\nde pesca",
      Cause == "Disease"        => "Enfermedad",
      Cause == "Others"         => "Otras",
      Cause == "Trauma"         => "Traumatismo",
      Cause == "Plastic"        => "Plástico",
      Cause == "Undetermined" => "Indeterminada",
      Cause == "Crude oil"      => "Petróleo",
      Cause == "Natural Death"  => "Muerte\nnatural"),
    Subcause = case_when(
      Subcause == "Nets" => "Red de pesca", 
      Subcause == "Septicaemia" => "Septicaemia", 
      Subcause == "Entangled" => "Enredada", 
      Subcause == "NA" => "NA", 
      Subcause == "Hook" => "Anzuelo", 
      Subcause == "Cachexia" => "Caquexia", 
      Subcause == "Crude oil" => "Petróleo", 
      Subcause == "Boat collision" => "Choque con bote", 
      Subcause == "Apparently healthy" => "Aparenta sana", 
      Subcause == "Shark bite" => "Mordida tiburón", 
      Subcause == "Fracture" => "Fractura", 
      Subcause == "Various injuries" => "Lesiones varias", 
      Subcause == "Ingestion" => "Ingestión", 
      Subcause == "Malformation" => "Malformación", 
      Subcause == "Weakness and exhaustion" => "Debilitada y agotada", 
      Subcause == "Buoyancy problems" => "Problemas para flotar", 
      Subcause == "Shock and various injuries" => "Shock/Lesiones varias", 
      Subcause == "Shock and fractures" => "Shock/Fracturas", 
      Subcause == "Epizoites" => "Epizoítos", 
      Subcause == "Malnutrition" => "Malnutrición", 
      Subcause == "Disorientation" => "Desorientación", 
      Subcause == "Fish and shrimp trap" => "Trampas para peces y camarones", 
      Subcause == "Nylon" => "Nylon", 
      Subcause == "Harpoon" => "Arpón", 
      Subcause == "Ropes" => "Cuerda", 
      Subcause == "Scientific capture" => "Captura científica", 
      Subcause == "Respiratory difficulty" => "Dificultad para respirar" 
      )
  )
end

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
  groupby(df_turtles, [:Cause, :Subcause]), nrow => :n
  )

rename!(
  df_subcauses,
  :Cause => :cause,
  :Subcause => :subcause
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

## ============================= ##
## Study of the causes per year
## ============================= ##

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
    fill = "Causas:"
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
    legend.text = element_text(size = 12),
    legend.position = "top",
    legend.direction = "horizontal"
  ) +
  guides(fill = guide_legend(nrow=1))

ggsave(
  filename = "./_assets/figures/plots/year_causes_barplot.png", 
  plot = year_causes_barplot,
  width = 12,
  height = 9
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
    limits = c(0,105),
    breaks = seq(0,100,25),
    labels = paste(glue("{seq(0,100,25)}%"))

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
    y = "Porcentaje",
    fill = "Causas:"
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
    legend.text = element_text(size = 12),
    legend.position = "top",
    legend.direction = "horizontal"
  ) +
  guides(fill = guide_legend(nrow=1))

ggsave(
  filename = "./_assets/figures/plots/year_causes_percentage_barplot.png", 
  plot = year_causes_percentage_barplot,
  width = 12,
  height = 9 
)
"""

## ============================= ##
## Study of the causes per year
## ============================= ##

## We will study the subcauses of most common causes

R"""
causes_tile <- $df_subcauses %>%
  mutate(
    subcause = case_when(
      n < 10 | n == "NA" ~ "Otras",
      n >= 10 ~ as.character(subcause)
    )) %>%
  group_by(cause, subcause) %>%
  summarise(n = sum(n)) %>% 
  filter(cause != "Indeterminada") %>%
  ggplot(aes(reorder(cause, n), reorder(subcause, n), fill = n)) +
  geom_tile(color = "black") +
  geom_text(aes(label = n)) +
  scale_fill_gradient(low = "white", high = "red") +
  scale_x_discrete(
    labels = c(
      "Muerte\nnatral", 
      "Traumatismo", 
      "Plástico",
      "Petróleo",
      "Otras",
      "Enfermedad",
      "Equipo\nde pesca")
  ) +
  labs(
    title = "Relación entre causas y subcausas",
    x = "Causa",
    y = "Subcausa",
    fill = "Número\nde tortugas"
  ) +
  theme(
    panel.background = element_rect(fill = "white"),
    panel.grid = element_line(color = "#999ce5", linetype = "dashed"),
    plot.title = element_text(face = "bold", size = 12, hjust = .5, margin = margin(b = 10)),
    axis.title = element_text(face = "bold", size = 11),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    legend.key.height = unit(0.2, "cm"),
    legend.key.width = unit(2, "cm")
  )

ggsave(
  filename = "./_assets/figures/plots/causes_tile.png", 
  plot = causes_tile,
  width = 8,
  height = 6
)
"""