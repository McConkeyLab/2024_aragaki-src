library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "readxl", "bladdr", "cellebrate", "tidyverse", "SummarizedExperiment",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/tw.R")

list(
  tar_target(tw, wrangle_tw())
)
