#!/usr/bin/env julia

using
  CSV,
  DataFrames,
  DataFramesMeta,
  Statistics,
  RCall,
  Tidier

R"""
suppressMessages(suppressWarnings({
  library(tidyverse)
  library(glue)
  library(ggtext)
  library(cowplot)
}))
"""

processed_data::String = "data/processed/stranding_turtles_processed.csv"
df_turtles = CSV.read(processed_data, DataFrame)

df_turtles_condition = df_turtles[!, [
  "Initial Conditions", 
  "Release (Yes/No)", 
  "Dead (Yes/No)",
  "year"
  ]]

rename!(
  df_turtles_condition,
  "Initial Conditions" => "initial_condition",
  "Release (Yes/No)" => "release",
  "Dead (Yes/No)" => "dead"
)

## Turtles comming alive / Dead
df_summary_condition = combine(
  groupby(df_turtles_condition, [
    :initial_condition,
    :release,
    :dead
  ]),
  nrow => :n
)

## Translate it to spanish
df_summary_condition = @chain df_summary_condition begin 
  @mutate(
    initial_condition = case_when(
      initial_condition == "Alive" => "Con vida",
      initial_condition == "Dead" => "Muertas"
    ),
    release = ifelse.(release == "Yes", "SI", "NO"),
    dead = ifelse.(release == "Yes", "SI", "NO")
  )
end

R"""
$df_summary_condition %>%
  group_by(initial_condition) %>%
  summarise(n = sum(n)) -> temp1

max_initial_condition <- max(temp1$n)

$df_summary_condition %>%
  group_by(initial_condition) %>%
  summarise(n = sum(n)) %>%
  mutate(sum = sum(n)) %>%
  ggplot(aes(initial_condition, n, fill = initial_condition)) +
  geom_col(show.legend = FALSE, width = .25, color = "black") +
  geom_text(
    aes(label = n), 
    position = "identity",
    vjust = -.5) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0, max_initial_condition + max_initial_condition * .2)
  ) +
  scale_fill_manual(values = c("lightgray", "black")) +
  labs(
    title = "Condición de las tortugas",
    x = NULL,
    y = "Número de tortugas"
  ) +
  theme_classic() +
  theme(
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    axis.line.x  = element_line(),
    title = element_text(size = 11, face = "bold"),
    plot.title = element_text(margin = margin(b = 1, unit = "lines"), hjust = .5),
    axis.title.x = element_text(margin = margin(t = 10),size = 13),
    axis.title.y = element_text(margin = margin(r = 10), size = 13),
    axis.ticks.x = element_blank(),
    axis.text = element_text(size = 10.5),
    plot.caption =  element_text(hjust = 0, face = "italic")
  ) -> plot_initial_condition
"""

R"""
$df_summary_condition %>%
  group_by(release) %>%
  summarise(n = sum(n)) -> temp2

max_release <- max(temp1$n)

$df_summary_condition %>%
  mutate(
    release = factor(
      release,
      levels = c("SI", "NO"),
      labels = c("Liberadas", "No liberadas")
    )
  ) %>%
  group_by(release) %>%
  summarise(n = sum(n)) %>%
  ggplot(aes(release, n, fill = release)) +
  geom_col(show.legend = FALSE, width = .25, color = "black") +
  geom_text(
    aes(label = n), 
    position = "identity",
    vjust = -.5) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0, max_release + max_release * .2)
  ) +
  scale_fill_manual(values = c("lightgray", "black")) +
  labs(
    title = "Tortugas liberadas/No liberadas",
    x = NULL,
    y = "Número de tortugas"
  ) +
  theme_classic() +
  theme(
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    axis.line.x  = element_line(),
    title = element_text(size = 11, face = "bold"),
    plot.title = element_text(margin = margin(b = 1, unit = "lines"), hjust = .5),
    axis.title.x = element_text(margin = margin(t = 10),size = 13),
    axis.title.y = element_text(margin = margin(r = 10), size = 13),
    axis.ticks.x = element_blank(),
    axis.text = element_text(size = 10.5),
    plot.caption =  element_text(hjust = 0, face = "italic")
  ) -> plot_release
"""

R"""
$df_summary_condition %>%
  group_by(dead) %>%
  summarise(n = sum(n)) -> temp3

max_dead <- max(temp1$n)

$df_summary_condition %>%
  group_by(dead) %>%
  summarise(n = sum(n)) %>%
  mutate(dead = factor(
    dead,
    levels = c("SI", "NO")
  )) %>%
  ggplot(aes(dead, n, fill = dead)) +
  geom_col(show.legend = FALSE, width = .25, color = "black") +
  geom_text(
    aes(label = n), 
    position = "identity",
    vjust = -.5) +
  scale_y_continuous(
    expand = expansion(0),
    limits = c(0, max_dead + max_dead * .2)
  ) +
  scale_fill_manual(values = c("lightgray", "black")) +
  labs(
    title = "Tortugas Vivas/Muertas",
    x = NULL,
    y = "Número de tortugas"
  ) +
  theme_classic() +
  theme(
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    axis.line.x  = element_line(),
    title = element_text(size = 11, face = "bold"),
    plot.title = element_text(margin = margin(b = 1, unit = "lines"), hjust = .5),
    axis.title.x = element_text(margin = margin(t = 10),size = 13),
    axis.title.y = element_text(margin = margin(r = 10), size = 13),
    axis.ticks.x = element_blank(),
    axis.text = element_text(size = 10.5),
    plot.caption =  element_text(hjust = 0, face = "italic")
  ) -> plot_dead 
"""

R"""
all_plots <- plot_grid(
  plot_initial_condition, plot_release, plot_dead
)

ggsave(
  filename = "./_assets/figures/plots/turtle_condition.png", 
  plot = all_plots,
  width = 8,
  height = 6
)
"""

