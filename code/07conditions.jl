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
  nrow => :n,
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

df_initial_condition = @chain combine(
  groupby(df_summary_condition, :initial_condition),
  :n .=> sum
) begin
  @mutate(
    percentage = round((n_sum / sum(n_sum) * 100), digits = 2)
  )
end

df_release = @chain combine(
  groupby(df_summary_condition, :release),
  :n .=> sum
) begin
  @mutate(
    percentage = round((n_sum / sum(n_sum) * 100), digits = 2)
  )
end

df_survival = @chain combine(
  groupby(df_summary_condition, :dead),
  :n .=> sum
) begin
  @mutate(
    percentage = round((n_sum / sum(n_sum) * 100), digits = 2)
  )
end

df_condition_final = DataFrame(
  center = vcat(repeat(["Condición al llegar al CRFS"], 2), 
                repeat(["Condición tras llegar al CRFS"], 4)),
  condition = vcat(repeat(["Condición Inicial"], 2), 
                   repeat(["Liberadas"], 2),
                   repeat(["Supervivencia"], 2)),
  groups   = vcat("Vivas", "Muertas", repeat(["Si", "No"], 2)),
  values   = vcat(df_initial_condition.percentage[1], 
                  df_initial_condition.percentage[2],
                  df_release.percentage[2],
                  df_release.percentage[1],
                  df_survival.percentage[2],
                  df_survival.percentage[1])
  )

R"""
$df_condition_final %>% 
  mutate(
    condition = factor(
      condition,
        levels = c(
          "Condición Inicial",
          "Supervivencia",
          "Liberadas"
        ),
        labels = c(
          "<i>Condición inicial</i><br><span style='color: #ff7575'>Muertas</span> / <span style='color: #72ff8c'>Vivas</span>",
          "<i>Supervivencia</i><br><span style='color: #ff7575'>No</span> / <span style='color: #72ff8c'>Si</span>",
          "<i>Liberdas</i><br><span style='color: #ff7575'>No</span> / <span style='color: #72ff8c'>Si</span>"
        )
      ),
    groups = factor(
      groups,
        levels = c(
          "Vivas",
          "Muertas",
          "Si",
          "No"
      )
    )
  ) %>%
  ggplot(aes(values, reorder(condition, values))) +
  geom_col(aes(fill = groups),
           position = "stack",
           show.legend = FALSE,
           width = .5) +
  geom_text(aes(label = paste0(values, "%")), hjust = 1) +
  facet_wrap(~center, ncol = 1, scales = "free") +
  scale_fill_manual(values = c("#72ff8c", "#ff7575", "#72ff8c", "#ff7575")) +
  labs(
    title = "Condición de las tortugas al llegar y estancia en el centro",
    y = NULL
  ) +
  theme(
    plot.background = element_rect(color = "white", fill = "white"),
    panel.background = element_rect(color = "white", fill = "white"),
    plot.title = element_text(face = "bold", size = 16, hjust = 1),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_markdown(face = "bold", size = 14, hjust = 0, color = "black"),
    strip.text = element_text(face = "bold.italic", size = 12, color = "#404040"),
    strip.background = element_blank()
  )

ggsave(
  filename = "./_assets/figures/plots/turtle_condition.png", 
  plot = last_plot(),
  width = 8,
  height = 4 
)
"""

