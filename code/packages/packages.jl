#!/usr/bin/env julia

println("Download/Update Packages")

## Installing the Julia packages for the analysis
packages = [
  "HTTP", 
  "StringEncodings", 
  "CSV",
  "DataFrames",
  "DataFramesMeta",
  "IterTools",
  "CategoricalArrays",
  "HypothesisTests",
  "RCall",
  "MultivariateStats"
  ]

import Pkg
Pkg.add(packages)

println("Job finished")