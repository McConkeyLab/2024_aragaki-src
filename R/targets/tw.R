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
  tar_target(tw_ka, wrangle_tw_ka()),
  tar_target(tw_bw, wrangle_tw_bw())
)
