library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "cellebrate", "classifyBLCA", "DESeq2", "tidyverse",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/cell_rna.R")

list(
  tar_target(cell_rna, classify_cells())
)
