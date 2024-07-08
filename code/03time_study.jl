#!/usr/bin/env julia

using 
  CSV,
  DataFrames,
  DataFramesMeta,
  CategoricalArrays,
  Gadfly,
  Cairo,
  RCall

## Librerías de R
R"""
suppressMessages({
  library(tidyverse)
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

## Using R, remember installing the packages
R"""
df_turtles_per_yearR <- $df_turtles_per_year

df_turtles_per_yearR %>% 
  ggplot(aes(year, n_sum)) +
  geom_bar(stat = "identity", position = position_stack(),
           alpha = .8, width = .5) +
  scale_fill_manual(values = c("red4","red3","red","gray35","gray55",
                               "gray","blue4","blue",
                               "skyblue","yellow4","yellowgreen","yellow")) +
  labs(
    title = "Turtles arrival every year",
    x = "Year",
    y = "Num.turtles",
    fill = NULL) +
  scale_y_continuous(expand = expansion(0),
                     limits = c(0,100)) +
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
        plot.caption =  element_text(hjust = 0, face = "italic")) 

"""

df_summary_joined[!, :year] = parse.(Int, df_summary_joined.year)

## Line plot for season arrival
line_plot = plot(
  layer(
    df_summary_joined,
    x = :year,
    y = :n,
    color = :season,
    Geom.line
  ),
  Guide.title("Rescue turtles per year over the seasons"),
  Guide.xlabel("Year"),
  Guide.ylabel("Number of turtles"),
  Guide.colorkey(title = "Season"),
  Scale.color_discrete_manual(["#28bad7","#c7cd32", "#bc33cc", "#d88a27"]..., order=[4,2,3,1]),
  Coord.cartesian(
    xmin = minimum(df_summary_joined.year), 
    xmax = maximum(df_summary_joined.year) + 1
    ),
  Theme(
    background_color = "white",
    panel_fill = "white",
    panel_stroke = "black",
#    grid_color= "transparent",
    minor_label_color = "black",
    major_label_color = "black",
    key_position = :top
  )
)

## Saving the images
images_dir = "data/images/" 
if !isdir(images_dir) mkdir(images_dir) end

draw(PNG("$images_dir/rescue_years.png", 25cm, 15cm), bar_plot)
draw(PNG("$images_dir/rescue_years_seasons.png", 25cm, 15cm), line_plot)


##======================##
## Statistical Analysis ##
##======================##

# plotting the distribution of the data

function hist_plot(season::String)
  hist = plot(
    layer(
      filter(row -> row.season == season,df_summary_joined),
      x = :n,
      Geom.histogram
    ),
    Guide.title("Distribution data $season"),
    Guide.xlabel("Number of turtles"),
    Guide.ylabel("Count"),
  Theme(
    bar_highlight=color("black"),
    background_color = "white",
    panel_fill = "white",
    panel_stroke = "black",
    grid_color= "transparent",
    minor_label_color = "black",
    major_label_color = "black",
    key_position = :top
    )
  )
  return hist
end

vstack(
  hstack(hist_plot("Fall"), hist_plot("Spring")),
  hstack(hist_plot("Winter"), hist_plot("Summer"))
  )


