#!/usr/bin/env julia

println("Download/Update Packages")

## Installing the Julia packages for the analysis
packages = [
  "HTTP", 
  "StringEncodings",
  "TranscodingStreams",
  "CodecZlib", 
  "CSV",
  "DataFrames",
  "DataFramesMeta",
  "IterTools",
  "CategoricalArrays",
  "HypothesisTests",
  "RCall",
  "MultivariateStats",
  "PooledArrays",
  "Franklin",
  "Shapefile",
  "Tidier"
  ]

import Pkg
Pkg.add(packages)

println("Job finished")