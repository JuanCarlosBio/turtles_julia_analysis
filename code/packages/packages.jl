#!/usr/bin/env julia

## Installing the Julia packages for the analysis
packages = [
  "HTTP", 
  "StringEncodings", 
  "CSV",
  "DataFrames",
  "DataFramesMeta",
  "IterTools",
  "Gadfly",
  "Cairo",
  "CategoricalArrays",
  "HypothesisTests",
  "RCall"
  ]

import Pkg
Pkg.add(packages)
