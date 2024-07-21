#!/usr/bin/env julia

using 
  CSV,
  DataFrames,
  DataFramesMeta,
  CategoricalArrays,
  RCall,
  HypothesisTests

## Librerías de R
R"""
suppressMessages({
  library(tidyverse)
  library(glue)
  library(ggtext)
  library(rstatix)
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

## Selecting the variables
df_turtles_time = df_turtles[!, [:year, :season]]
## Transforming the year into string
df_turtles_time[!, :year] = string.(df_turtles_time[!,:year])

## Fixing the gaps of year and season when there is no turtles registered
## The idea of this code is getting the next grid
#         Row │ year    season  
#        ─────┼─────────────────
#           1 │ 2000    Fall
#           2 │ 2000    Winter
#           3 │ 2000    Spring
#           4 │ 2000    Summer
#          ⋮  │   ⋮        ⋮
#          86 │ 2022    Fall
#          87 │ 2022    Winter
#          88 │ 2022    Spring
#          89 │ 2022    Summer

# Creating the grid
year_season_grid = DataFrame(
  vec(collect(Base.product(
    string.(levels(df_turtles_time[!,:year])),
    string.(levels(df_turtles_time[!,:season])) 
    )))
  )

# Changing the column names
rename!(
  year_season_grid, 
  :1 => :year,
  :2 => :season
  )

## Getting the sum of the year and season arrival: 
## when turtles do not arrive to a specific year - season it forms gaps (no 0 or missing values)
df_summary = combine(
  groupby(df_turtles_time, [:year, :season]
    ), nrow => :n)

## To fill the gaps of the previous dataframe we joined the df_summary and the year_season_grid
df_summary_joined = leftjoin(
  year_season_grid, 
  df_summary, 
  on = [:year, :season]
  )

## Changing the missing values to 0  
df_summary_joined[!, :n] = ifelse.(
  ismissing.(df_summary_joined.n), 0, df_summary_joined.n
  )

##======================##
##  Plotting  the data  ##
##======================##
 
df_turtles_per_year = combine(groupby(df_summary_joined, [:year]), :n => sum)
max_f_turtles_per_year = maximum(df_turtles_per_year.n_sum)

## Using R, remember installing the packages
R"""
df_turtles_per_yearR <- $df_turtles_per_year

bar_plot_years <- df_turtles_per_yearR %>% 
  ggplot(aes(year, n_sum)) +
  geom_bar(stat = "identity", position = position_stack(),
           alpha = .8, width = .5) +
  geom_text(aes(year, n_sum, label = n_sum),
            position = "identity",
            color = "black",
            fontface = "bold",
            show.legend = F,
            vjust = -.5) +
  scale_fill_manual(values = c("red4","red3","red","gray35","gray55",
                               "gray","blue4","blue",
                               "skyblue","yellow4","yellowgreen","yellow")) +
  labs(
    title = "Tortugas marinas varadas en el tiempo en Tenerife (2000-2021)",
    x = "Año",
    y = "Número de tortugas",
    fill = NULL) +
  scale_y_continuous(expand = expansion(0),
                     ## This way it would be easier to reuse in the futures
                     limits = c(0, $max_f_turtles_per_year + $max_f_turtles_per_year * .2)) +
  theme(
    #panel.background = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    #plot.background = element_rect(fill = "lightblue", color = "lightblue"),
    axis.line.x  = element_line(),
    title = element_text(size = 11, face = "bold"),
    plot.title = element_text(margin = margin(b = 1, unit = "lines"), hjust = .5),
    axis.ticks.x = element_blank(),
    axis.text.x = element_text(angle = 270, hjust = 1, vjust = .5),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(r = 10), size = 13),
    axis.text = element_text(size = 10.5),
    plot.caption =  element_text(hjust = 0, face = "italic")
  ) 

ggsave(
  filename = "turtles_julia_analysis/_assets/figures/plots/number_turtles_per_year.png", 
  plot = bar_plot_years,
  width = 7,
  height = 5
  )
"""

df_summary_joined[!, :year] = parse.(Int, df_summary_joined.year)

R"""
df_summary_joinedR <- $df_summary_joined 

line_plot_seasons <- df_summary_joinedR %>%
  ggplot(aes(year, n, col = season, group = season)) +
  geom_point(size = 2) +
  geom_line(size = .75) +
  scale_color_manual(
    breaks  = c("Spring","Summer","Fall","Winter"),
    values = c("yellowgreen","darkmagenta","orangered", "cyan3"),
    labels = c("Primavera", "Verano", "Otoño", "Invierno")
    ) +
  labs(title = "Tortugas marinas varadas según la estación en Tenerife (2000-2021)",
       x = "Año",
       y = "Número de tortugas",
       col="Estación") +
  theme_classic() +
  theme(
    title = element_markdown(size = 12, face = "bold"),
    panel.grid = element_blank(),
    #panel.background = element_rect(fill = "white", color = "azure"),
    #plot.background = element_rect(fill = "lightblue", color = "lightblue"),
    plot.title = element_markdown(margin = margin(b = 1, unit = "lines"),
                                  hjust = .5),
    axis.text = element_text(size = 10.5),
    #axis.ticks.x = element_blank(),
    axis.text.x = element_markdown(angle = 270, vjust = .4),
    axis.title.x = element_text(margin = margin(t = 10),size = 13),
    axis.title.y = element_text(margin = margin(r = 10), size = 13),
    plot.caption =  element_markdown(hjust = 0, face = "italic"),
    legend.background =  element_rect(fill = "white"),
    #legend.key = element_rect(fill = "white"),
    legend.position = "top"
  )

ggsave(
  filename = "turtles_julia_analysis/_assets/figures/plots/number_turtles_per_season.png", 
  plot = line_plot_seasons,
  width = 8,
  height = 5
  )
"""

##======================##
## Statistical Analysis ##
##======================##

# plotting the distribution of the data
R"""
hist_data_seasons <- df_summary_joinedR %>%
  mutate(
    estacion=factor(
      season, 
      levels=c("Spring","Summer","Fall","Winter")
      )) %>% 
  ggplot(aes(n,fill=season)) +
  geom_histogram(bins = 25,col="black", show.legend = F) +
  facet_wrap(~season, ncol=2) +
  labs(
    title = "Distribution of the data",
    x= "Number of turtles",
    y = "Frecuency",
    subtitle = ""
  ) +
  scale_fill_manual(breaks = c("Spring", "Summer", "Fall", "Winter"),
                    values = c("yellowgreen","darkmagenta","orangered",
                               "cyan3")) +
  scale_y_continuous(expand = expansion(0)) +
  theme_test() +
  theme(
    plot.title = element_text(size = 13,
                             #margin = margin(b=1, unit = "lines"),
                             face = "bold",
                             hjust = .5),
   panel.grid = element_blank(),
   panel.background = element_rect(fill = "white", color = "white"),
   plot.subtitle = element_text(size = 9),
   axis.title = element_text(face = "bold", size = 13),
   axis.title.x = element_text(margin = margin(t=10)),
   axis.title.y = element_text(margin = margin(r=10)),
   strip.background = element_blank(),
   strip.text = element_markdown(face = "bold")
  )

ggsave(
  filename = "turtles_julia_analysis/_assets/figures/plots/histogram_season_data.png", 
  plot = hist_data_seasons,
  width = 7,
  height = 5
  )
"""

## Also doing a shapiro test to be sure that the data is indeed not normal
## there is not a shapiro-wilks function in Julia easily available :/
R"tapply(df_summary_joinedR$n, df_summary_joinedR$season, shapiro.test)"
R"shapiro.test(df_summary_joinedR$n)"

## Becouse the data is not normal we will use a Kruskall-Wallis Test
function filter_season(df::DataFrame, season::String) 
  filter(
    row -> row.season == season, df
    )
end

rcopy(
  R"""
  df_summary_joinedR %>%
    kruskal_test(n~season)
  """)

dunn_test_results = rcopy(
  R"""
  df_summary_joinedR %>%
    dunn_test(n~season, p.adjust = "bonf") %>%
    mutate(across(where(is.numeric), ~ round(., 4))) %>%
    rename(
      Grupo1 = group1,
      Grupo2 = group2,
      Estadístico = statistic,
      `p ajustado` = p.adj,
      Significativo = p.adj.signif
    )
  """
)[:,[2,3,6,7,8,9]]


CSV.write("turtles_julia_analysis/_assets/menu2/tableinput/dunn_test_seasons.csv", dunn_test_results) 

R"""
boxplot_seasons <- df_summary_joinedR %>%
  ggplot(aes(season, n, fill = season)) +
    geom_jitter(pch = 21, position = position_jitterdodge(.5, seed = 20101997),
                alpha = .8,show.legend = F) +
    geom_boxplot(alpha=.5,width=.5,show.legend = F)

ggsave(
  filename = "turtles_julia_analysis/_assets/figures/plots/boxplot_seasons.png", 
  plot = boxplot_seasons,
  width = 7,
  height = 5
)
"""