#!/usr/bin/env julia

using HTTP 

function main(url::String, filename::String)
  raw_dir::String = "data/raw/" 
  if !isdir(raw_dir) mkdir(raw_dir) end
  response = HTTP.get(url)
  open(filename, "w") do file
    write(file, response.body)
  end
end

## Data of marine turtles from the Research-data from ULL
url_turtles = "https://data.mendeley.com/public-files/datasets/p6wmtv6t5g/files/14372010-e5e5-4257-a784-34b13a6557cb/file_downloaded"
file_path_turtles  ="data/raw/stranding_turtles.csv" 
## Vectorial shapes files from GRAPHCAN ZIP
url_canary_islands = "https://opendata.sitcan.es/upload/unidades-administrativas/gobcan_unidades-administrativas_municipios.zip"
file_path_shp = "data/raw/municipality.zip"


main(url_turtles, file_path_turtles)
main(url_canary_islands, file_path_shp)