#!/usr/bin/enc julia

using 
  DataFrames,
  DataFramesMeta,
  CSV,
  Tidier,
  RCall

R"""
library(tidyverse)
"""


## R function
selec = rcopy(R"""
select <-data_tortugas_tfg.xlsxselec <-function(ord,lista_tokens,var) {
  paste(lista_tokens[-ord],collapse="|")
  if(!is.na(ord)) return(grepl(lista_tokens[ord],tolower(var)) & !grepl(paste(lista_tokens[-ord],collapse="|"),tolower(var)))
  else return(grepl(paste(lista_tokens,collapse="|"),tolower(var)))
}
""")

## Example Function to process the data in Julia
# data = CSV.read("data/processed/stranding_turtles_processed.csv", DataFrame)
# 
# lista_prueba = [
#   "amput|amputa|amputada",
#   "corte",
#   "enmalla|enreda|enmallamiento|rafia|red|nylon|malla",
#   "anzuelo|anz",
#   "fractur",
#   "parás|paras|gusan",
#   "ahoga",
#   "petrol|hidrocarburo",
#   "herida|golpe|heridas|embarcaci",
#   "Apn|apn|APN"
#   ]
# 
# results = DataFrame[]
# 
# for i in 1:length(lista_prueba)
#   search = selec(i, lista_prueba, data.Observation) 
#   push!(results, data[search, :])
# end
# 
# vcat(results)
# 
# show(results[3])