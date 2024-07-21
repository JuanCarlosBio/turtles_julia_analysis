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

url_turtles = "https://data.mendeley.com/public-files/datasets/p6wmtv6t5g/files/14372010-e5e5-4257-a784-34b13a6557cb/file_downloaded"
file_path  ="data/raw/stranding_turtles.csv" 

main(url_turtles, file_path)