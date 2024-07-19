#!/usr/bin/env julia

## Using the Tasks in julia

## Programms:
download_packages = "code/packages/packages.jl"
download_data = "code/01download_data.jl"
process_turtle_data = "code/02process_turtle_data.jl"
time_study_turtles = "code/03time_sturdy.jl"
biometry_study_turtles = "code/04biometria.jl"
causes_of_stranding = "code/05causes.jl"

workflow = @task begin
  run(`julia $download_packages`)
  run(`julia $download_data`)
  run(`julia $process_turtle_data`)
end

schedule(workflow)

yield()