#!/usr/bin/env julia

## Using the Tasks in julia

## Programms:
download_packages   = "code/packages/packages.jl"
create_working_dirs = "code/01create_dirs.jl"
download_data       = "code/02download_data.jl"
process_turtle_data = "code/03process_turtle_data.jl"
time_study_of_strandings = "code/04time_study.jl"

workflow = @task begin
  run(`julia $download_packages`)
  run(`julia $create_working_dirs`)
  run(`julia $download_data`)
  run(`julia $process_turtle_data`)
  run(`julia $time_study_of_strandings`)
end

schedule(workflow)

yield()