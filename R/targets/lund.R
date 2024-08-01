library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "GEOquery", "Biobase", "tidyverse",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/lund.R")

list(
  tar_target(lund, getGEO("GSE32894")[[1]]),
  tar_target(lund_plotting_data, wrangle(lund))
)
