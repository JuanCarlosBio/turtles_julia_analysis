#!/usr/bin/env julia

using Base.Threads

# Define the paths
download_packages        = "code/packages/packages.jl"
create_working_dirs      = "code/01create_dirs.jl"
download_data            = "code/02download_data.jl"
process_turtle_data      = "code/03process_turtle_data.jl"
time_study_of_strandings = "code/04time_study.jl"

# Define the tasks
task_download_packages        = @task run(`julia $download_packages`)
task_create_working_dirs      = @task run(`julia $create_working_dirs`)
task_download_data            = @task run(`julia $download_data`)
task_process_turtle_data      = @task run(`julia $process_turtle_data`)
task_time_study_of_strandings = @task run(`julia $time_study_of_strandings`)

task_list = [
  task_download_packages, task_create_working_dirs, task_download_data,
  task_process_turtle_data, task_time_study_of_strandings 
]

for task in task_list
  schedule(task)
  wait(task)
end

yield()