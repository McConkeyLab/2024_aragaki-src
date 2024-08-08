library(targets)
library(tarchetypes)

cell_rna <- tar_read(cell_rna, store = "stores/cell_rna/")

tar_option_set(
  packages = c(
    "readxl", "bladdr", "tidyverse", "SummarizedExperiment",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/tw.R")

list(
  tar_target(tw_ka, wrangle_tw_ka(cell_rna)),
  tar_target(tw_bw, wrangle_tw_bw(cell_rna)),
  tar_target(tw, rbind(tw_ka, tw_bw))
)
