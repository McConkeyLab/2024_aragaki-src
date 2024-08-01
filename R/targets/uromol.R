library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "tidyverse", "readxl", "bladdr",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/uromol.R")

list(
  tar_target(expression, get_expression()),
  tar_target(clinical, get_clinical()),
  tar_target(uromol_plotting_data, wrangle(expression, clinical))
)
