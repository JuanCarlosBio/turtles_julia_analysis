#!/usr/bin/env julia

using Base.Threads

# Define the tasks
task_download_packages        = @task run(`julia code/packages/packages.jl`)
task_create_working_dirs      = @task run(`julia code/01create_dirs.jl`)
task_download_data            = @task run(`julia code/02download_data.jl`)
task_process_turtle_data      = @task run(`julia code/03process_turtle_data.jl`)
task_time_study_of_strandings = @task run(`julia code/04time_study.jl`)
task_biometry_study           = @task run(`julia code/05biometria.jl`)
task_unzip_locations          = @task run(`unzip data/raw/municipality.zip -d data/raw/`)
task_location_gc_shp          = @task run(`python3 code/01process_shp.py`)
task_location                 = @task run(`Rscript code/01location_stranded_turtles.R`)  
task_causes                   = @task run(`julia code/06causes.jl`)  


task_list = [
  task_download_packages, 
  task_create_working_dirs, 
  task_download_data,
  task_process_turtle_data, 
  task_time_study_of_strandings,
  task_biometry_study, 
  task_unzip_locations, 
  task_location_gc_shp, 
  task_location,
  task_causes 
]

for task in task_list
  schedule(task)
  wait(task)
end

yield()