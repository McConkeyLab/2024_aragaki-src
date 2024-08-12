library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "bladdr", "gplate", "tidyverse", "mop",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/mtt.R")

list(
  tar_target(mtt_data_raw, get_all_data()),
  tar_target(mtt_data_tidy, tidy(mtt_data_raw))
)
