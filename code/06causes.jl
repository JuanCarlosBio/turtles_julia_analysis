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

df_causes.percentage = round.((df_causes.n / sum(df_causes.n)) * 100, digits = 2) 

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

## Categorization of the subcauses 
## HR == Human related
## ANHR == Apparently Not Human Related 
## UND == Undeterminated

R"""
$df_subcauses %>%
  as_tibble() %>%
  mutate(
   categorized_subcause = case_when(
    subcause == "Nets" 
    | subcause == "Entangled"
    | subcause == "Boat collision"
    | subcause == "Fish and shrimp trap"
    | subcause == "Harpoon" 
    | subcause == "Ropes"
    | subcause == "Hook"
    | subcause == "Crude oil"
    | subcause == "Nylon"
    | subcause == "Scientific capture" ~ "HR",
    subcause == "Apparently healthy"
    | subcause == "Buoyancy problems"
    | subcause == "Shark bite"
    | subcause == "Malformation"
    | subcause == "Malnutrition"
    | subcause == "Respiratory difficulty"
    | subcause == "Epizoites"
    | subcause == "Cachexia"
    | subcause == "Septicaemia"
    | subcause == "Weakness and exhaustion"
    | subcause == "Disorientation" ~ "ANHR",
    subcause == "Fracture"
    | subcause == "NA"
    | subcause == "Various injuries"
    | subcause == "Shock and fractures"
    | subcause == "Shock and various injuries" ~ "UND"
   ) 
  ) %>%
  arrange(desc(n)) %>%
  drop_na() -> df_subcausesR
"""

R"""
## Lo ideal sería cambiar esta versión por una tabla del paquete gt
df_subcauses_hr <- df_subcausesR %>%
  filter(categorized_subcause == "HR") %>%
  pivot_wider(
    id_cols = subcause, 
    names_from = categorized_subcause, 
    values_from = n
    ) %>%
  mutate(subcause = case_when(
    HR <= 5 ~ "Others",
    HR >  5 ~ as.character(subcause)
  )) %>%
  group_by(subcause) %>%
  summarise(HR = sum(HR)) %>%
  arrange(desc(HR))

df_subcauses_anhr <- df_subcausesR %>%
  filter(categorized_subcause == "ANHR") %>%
  pivot_wider(
    id_cols = subcause, 
    names_from = categorized_subcause, 
    values_from = n
    )%>%
  mutate(subcause = case_when(
    ANHR <= 5 ~ "Others",
    ANHR >  5 ~ as.character(subcause)
  )) %>%
  group_by(subcause) %>%
  summarise(ANHR = sum(ANHR)) %>%
  arrange(desc(ANHR))

df_subcauses_und <- df_subcausesR %>%
  filter(categorized_subcause == "UND") %>%
  pivot_wider(
    id_cols = subcause, 
    names_from = categorized_subcause, 
    values_from = n
    ) %>%
  mutate(subcause = case_when(
    UND <= 5 ~ "Others",
    UND >  5 ~ as.character(subcause)
  )) %>%
  group_by(subcause) %>%
  summarise(UND = sum(UND)) %>%
  arrange(desc(UND))
"""

## Creating the GT tables to represent the data before
R"""
subcauses_human_related <- df_subcauses_hr %>%
  gt() %>%
  tab_header(
    title = md("**Subcauses classified as:<br><u>Related to Humans</u>**")
  ) %>%
  cols_label(
    subcause = md("**Subcause**"),
    HR = md("**Nº turtles stranding**")
  )

subcauses_non_human_related <- df_subcauses_anhr %>%
  gt() %>%
  tab_header(
    title = md("**Subcauses classified as:<br><u>Apparently non Related<br>to Humans</u>**")
  ) %>%
  cols_label(
    subcause = md("**Subcause**"),
    ANHR = md("**Nº turtles stranding**")
  )

subcauses_undeterminated <- df_subcauses_und %>%
  gt() %>%
  tab_header(
    title = md("**Subcauses classified as:<br><u>Undeterminated</u>**")
  ) %>%
  cols_label(
    subcause = md("**Subcause**"),
    UND = md("**Nº turtles stranding**")
  )
"""

R"""
html_table_1 <- as.tags(subcauses_human_related)
html_table_2 <- as.tags(subcauses_non_human_related)
html_table_3 <- as.tags(subcauses_undeterminated)

# Combine the HTML tables into a single HTML document
combined_html <- tagList(
  html_table_1,
  html_table_2,
  html_table_3
)

save_html(combined_html, file = "images/tables/sucauses_tables.html")
"""

## =============================== ##
## Study of the subcauses per year
## =============================== ##

df_causes_years = df_turtles[:,[:Cause, :year]]
rename!(
  df_causes_years,
  :Cause => :cause
)
n_df_causes_years = combine(groupby(df_causes_years, [:cause, :year]), nrow => :n)

## Raw years and causes
R"""
$n_df_causes_years %>%
  ggplot(aes(year, n, fill = reorder(cause,n))) +
  geom_col(color = "black", alpha=.5) +
  geom_text(aes(year, n, label = n), position = position_stack(vjust = .5)) +
  scale_fill_manual(values = c(
    "white", "gray", "yellow", "blue", "forestgreen", "orange", "magenta", "red"
  )) +
  scale_x_continuous(
    breaks = seq(2000,2021,1)
  )
"""

## Percentage by the years
R"""
$n_df_causes_years %>%
  group_by(year) %>%
  mutate(percentage = (n/sum(n))*100) %>%
  ggplot(aes(year, percentage, fill = reorder(cause,percentage))) +
  geom_col(color = "black", alpha=.5) +
  geom_text(aes(year, percentage, label = glue("{round(percentage, 2)} %")), position = position_stack(vjust = .5)) +
  scale_fill_manual(values = c(
    "white", "gray", "yellow", "blue", "forestgreen", "orange", "magenta", "red"
  )) +
  scale_x_continuous(
    breaks = seq(2000,2021,1)
  )
"""

## Subcauses categorized as HR, ANHR and UND
df_subcauses_years = combine(
  groupby(df_turtles, [:Subcause, :year]), nrow => :n
  )

rename!(
  df_subcauses_years,
  :Subcause => :subcause
)

## Filtering the last year with incomplete data
filter!(row -> row.year < 2021, df_subcauses_years)

R"""
$df_subcauses_years %>%
  as_tibble() %>%
  mutate(
   categorized_subcause = case_when(
    subcause == "Nets" 
    | subcause == "Entangled"
    | subcause == "Boat collision"
    | subcause == "Fish and shrimp trap"
    | subcause == "Harpoon" 
    | subcause == "Ropes"
    | subcause == "Hook"
    | subcause == "Crude oil"
    | subcause == "Nylon"
    | subcause == "Scientific capture" ~ "HR",
    subcause == "Apparently healthy"
    | subcause == "Buoyancy problems"
    | subcause == "Shark bite"
    | subcause == "Malformation"
    | subcause == "Malnutrition"
    | subcause == "Respiratory difficulty"
    | subcause == "Epizoites"
    | subcause == "Cachexia"
    | subcause == "Septicaemia"
    | subcause == "Weakness and exhaustion"
    | subcause == "Disorientation" ~ "ANHR",
    subcause == "Fracture"
    | subcause == "NA"
    | subcause == "Various injuries"
    | subcause == "Shock and fractures"
    | subcause == "Shock and various injuries" ~ "UND"
   ) 
  ) %>% 
  group_by(categorized_subcause, year) %>%
  count() %>%
  arrange(desc(n)) %>%
  drop_na() %>%
  write_csv("data/processed/subcauses_and_years.csv") 
"""

df_subcauses_proprocessed = CSV.read("data/processed/subcauses_and_years.csv", DataFrame)

## Creating a grid to fill the years with 0 values!
#subcauses_years_grid
df_subcauses_proprocessed_grid = DataFrame(
  vec(collect(Base.product(
    string.(levels(df_subcauses_proprocessed[!,:categorized_subcause])),
    string.(levels(df_subcauses_proprocessed[!,:year]))
  )))
)

rename!(
  df_subcauses_proprocessed_grid,
  :1 => :categorized_subcause,
  :2 => :year
)

df_subcauses_proprocessed.year = string.(df_subcauses_proprocessed.year)

df_subcauses_proprocessed = leftjoin(
  df_subcauses_proprocessed_grid,
  df_subcauses_proprocessed,
  on = [:categorized_subcause, :year]
)

df_subcauses_proprocessed.year = parse.(Int, df_subcauses_proprocessed.year)

df_subcauses_proprocessed.n = ifelse.(
  ismissing.(df_subcauses_proprocessed.n), 0, df_subcauses_proprocessed.n
)

R"""
$df_subcauses_proprocessed %>%
  mutate(categorized_subcause = factor(
    categorized_subcause,
    levels = c("UND", "ANHR", "HR"),
    labels = c("Undeterminated", "Apparently NON Human Related", "Human Related") 
  )) %>% 
  ggplot(aes(year, n, color = categorized_subcause)) +
  geom_line(linewidth = 1)
"""