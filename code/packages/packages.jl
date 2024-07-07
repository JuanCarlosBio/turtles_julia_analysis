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
  ]

import Pkg
Pkg.add(packages)