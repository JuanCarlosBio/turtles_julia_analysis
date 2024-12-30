#!/usr/bin/env Rscript

library(tidyverse)
library(sf)

sf_turtles_location <- read_sf("data/processed/gc_municipality_turtles.shp") %>%
  mutate(Municipali = str_to_upper(Municipali),
         n = ifelse(!(is.na(n)), n, 0)) %>%
  arrange(desc(n)) 
  

sf_turtles_location %>%
  ggplot() +
  geom_sf(aes(fill = n)) +
  geom_sf_text(aes(label = n)) +
  scale_fill_gradient(low = "white", high = "red") +
  labs(
    title = "Registro de tortugas marinas varadas por municipio",
    subtitle = "Tenerife, Islas Canarias",
    x = "Longitud",
    y = "Latitud",
    fill = NULL
  ) +
  theme_test() +
  theme(
    panel.background = element_rect(fill = "#a9ebfc"),
    plot.title = element_text(face="bold", size = 14, hjust = .5),
    axis.title = element_text(face = "bold", size = 12),
    legend.position = "bottom",
    legend.key.height = unit(0.2, "cm"),
    legend.key.width = unit(2, "cm"),
  )

ggsave(
  filename = "./_assets/figures/plots/mapa_calor.png", 
  plot = last_plot(),
  width = 7,
  height = 6
)
