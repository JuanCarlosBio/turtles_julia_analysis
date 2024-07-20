#!/usr/bin/env julia

directories = [
  "data/",
  "data/raw/",
  "data/processed/",
  "data/statistics/",
  "images/",
  "images/tables/",
  "images/figures/"
]

function main(dirercories_list::Vector)
  for dir in dirercories_list
    if !isdir(dir)
      println("> El directorio $dir, no existe, se creará")
      mkdir(dir) 
      println("> Directorio $dir creado")
    else
      println("> El directorio $dir ya existe")
    end
  end
end

main(directories)