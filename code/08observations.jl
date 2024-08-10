#!/usr/bin/env julia

using
  DataFrames,
  DataFramesMeta,
  CSV,
  RCall

R"""
library(tidyverse)
library(glue)
"""

processed_data::String = "data/processed/stranding_turtles_processed.csv"
df_turtles = CSV.read(processed_data, DataFrame)

all_words = []

for i in 1:length(df_turtles.Observation)
    if !ismissing(df_turtles.Observation[i])
        # Split the text into words and append them to all_words
        append!(all_words, split(df_turtles.Observation[i]))
    end
end

lower_all_words = lowercase.(all_words)

# Assuming you already have `lower_all_words`
clean_words = replace.(lower_all_words, "," => "")

# Remove any empty strings that may result from cleaning
clean_words = filter(x -> x != "", clean_words)

df_clean_words = DataFrame(data = clean_words)

words = combine(groupby(df_clean_words, :data), nrow => :n)
R"""
tibble(words = $lower_all_words) %>%
  mutate(words = str_replace_all(words, "[:punct:]", "")) %>%
  group_by(words) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  filter(!(words %in% c("in", "and", "with", "the", "a", "on", 
                       "to", "is", "at", "of", "by", "it",
                       "not", "she", "its", "but")) & n >= 10) %>%
  print(n=Inf)
"""


## R parse function:
R"""
selec <-data_tortugas_tfg.xlsxselec <-function(ord,lista_tokens,var) {
  paste(lista_tokens[-ord],collapse="|")
  if(!is.na(ord)) return(grepl(lista_tokens[ord],tolower(var)) & !grepl(paste(lista_tokens[-ord],collapse="|"),tolower(var)))
  else return(grepl(paste(lista_tokens,collapse="|"),tolower(var)))
}
"""

R"""
# Lista de las injuryes de la tortuga
lista_injuryes <- c(
  "amput|remov|blow|up|severe|missing|piece",
  "cut",
  "entang|netted|net|rope|raffia|nylon",
  "anz|anzuelo|hook",
  "fracture|break|broke",
  "paras|worm|moss|algae|barnacles",
  "drown",
  "plastic|oil|crude|hydroc|hidroc",
  "hurt|boat|wound|swollen|bite|propeller",
  "apn|nothing|well|active|good"
  )

# Lista del estado en el que se encuentra la tortuga

lista_estado <- c(
  "dead|death",
  "weak|problem|old|beach|drifting|floating|adrift",
  "mesh|necrosed|blood|necro",
  "skinny|small|thin",
  "moss|infec|swollen",
  "decomposed|decomposition",
  "apn|nothing|well|active|good"
  )


# Lista de las partes del body afectada por la tortuga

lista_body <- c(
  "front|right|left|fin|flipper|wing|fins|flap",
  "shell|carapace|shell.",
  "eye",
  "mouth",
  "neck",
  "apn|nothing|well|active|good"
  )
"""

df_turtles_observations = rcopy(R"""
df_tortugas_obs <- $df_turtles %>% mutate(
  injury = case_when(
    selec(1,lista_injuryes,Observation)  ~ "Amputación" ,
    selec(2,lista_injuryes,Observation)  ~ "Cortes",
    selec(3,lista_injuryes,Observation)  ~ "Enredadas",
    selec(4,lista_injuryes,Observation)  ~ "Anzuelos",
    selec(5,lista_injuryes,Observation)  ~ "Fracturas",
    selec(6,lista_injuryes,Observation)  ~ "Parásitos",
    selec(7,lista_injuryes,Observation)  ~ "Ahogadas",
    selec(8,lista_injuryes,Observation)  ~ "Petroleadas",
    selec(9,lista_injuryes,Observation)  ~ "Herida",
    selec(10,lista_injuryes,Observation) ~ "Nada",
    selec(NA,lista_injuryes,Observation) ~ "Varias injuryes"
    ),
  state = case_when(
    selec(1,lista_estado,Observation)    ~ "Muerta" ,
    selec(2,lista_estado,Observation)    ~ "Débil",
    selec(3,lista_estado,Observation)    ~ "Necrosada",
    selec(4,lista_estado,Observation)    ~ "Flaca",
    selec(5,lista_estado,Observation)    ~ "Infección",
    selec(6,lista_estado,Observation)    ~ "Putrefacta",
    selec(7,lista_estado,Observation)    ~ "Nada"
  ),
  body = case_when(
    selec(1,lista_body,Observation)    ~ "Aleta" ,
    selec(2,lista_body,Observation)    ~ "Caparazón",
    selec(3,lista_body,Observation)    ~ "Ojos",
    selec(4,lista_body,Observation)    ~ "Boca",
    selec(5,lista_body,Observation)    ~ "Cabeza",
    selec(6,lista_body,Observation)    ~ "Cuello",
    selec(7,lista_body,Observation)    ~ "Nada",
    selec(NA,lista_body,Observation)   ~ "Varias"
    )
) %>% as.data.frame() 
""")


R"""
df_turtles_observationsR <- $df_turtles_observations

df_injury.body <- expand.grid(injury=as.character(unique(as.character(df_turtles_observationsR$injury))),
                             body=as.character(unique(as.character(df_turtles_observationsR$body)))) %>% left_join(
                               df_turtles_observationsR %>% group_by(injury,body) %>% summarize(n=n()),
                               by=c("injury","body")
                             ) %>% mutate(n=ifelse(is.na(n),0,n)) 

injury.body_plot <- df_injury.body %>%
  filter(!(injury %in% NA) &  !(body %in% NA)) %>% 
  ggplot(aes(reorder(body, n),reorder(injury, n), fill = n)) +
  geom_tile(col = "black", alpha = .9) +
  geom_text(aes(label = n)) +
  labs(x = "Injury",
       y = "Body",
       title = "Injury vs body",
       caption = "") + 
  scale_fill_gradient(
    name="Nº tortugas",
    low = "skyblue", high = "red") 

ggsave(
  "_assets/figures/plots/injury_body.png",
  plot = injury.body_plot,
  width = 8,
  height = 5
)
"""


R"""
df_turtles_observationsR <- $df_turtles_observations

df_state.body <- expand.grid(state=as.character(unique(as.character(df_turtles_observationsR$state))),
                             body=as.character(unique(as.character(df_turtles_observationsR$body)))) %>% left_join(
                               df_turtles_observationsR %>% group_by(state, body) %>% summarize(n=n()),
                               by=c("state","body")
                             ) %>% mutate(n=ifelse(is.na(n),0,n)) 

state.body_plot <- df_state.body %>%
  filter(!(state %in% NA) &  !(body %in% NA)) %>% 
  ggplot(aes(reorder(state, n), reorder(body, n), fill = n)) +
  geom_tile(col = "black", alpha = .9) +
  geom_text(aes(label = n)) +
  labs(x = "State",
       y = "Body",
       title = "State vs body",
       caption = "") + 
  scale_fill_gradient(
    name="Nº tortugas",
    low = "skyblue", high = "red") 

ggsave(
  "_assets/figures/plots/state_body.png",
  plot = state.body_plot,
  width = 8,
  height = 5
)
"""

R"""
df_turtles_observationsR <- $df_turtles_observations

df_state.injury <- expand.grid(state=as.character(unique(as.character(df_turtles_observationsR$state))),
                               injury=as.character(unique(as.character(df_turtles_observationsR$injury)))) %>% left_join(
                               df_turtles_observationsR %>% group_by(state, injury) %>% summarize(n=n()),
                               by=c("state","injury")
                             ) %>% mutate(n=ifelse(is.na(n),0,n)) 

state.injury_plot <- df_state.injury %>%
  filter(!(state %in% NA) &  !(injury %in% NA)) %>% 
  ggplot(aes(reorder(state, n), reorder(injury, n), fill = n)) +
  geom_tile(col = "black", alpha = .9) +
  geom_text(aes(label = n)) +
  labs(x = "State",
       y = "Body",
       title = "State vs body",
       caption = "") + 
  scale_fill_gradient(
    name="Nº tortugas",
    low = "skyblue", high = "red") 

ggsave(
  "_assets/figures/plots/state_injury.png",
  plot = state.injury_plot,
  width = 8,
  height = 5 
)
"""
