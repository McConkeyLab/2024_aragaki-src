library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "tidyverse", "readxl", "DESeq2", "GenomicDataCommons", "TCGAutils",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/tcga.R")

list(
  # This script requires running the general_tcga submodule
  tar_target(tcga, readRDS("general_tcga/01_data/blca/dds.rds")),
  tar_target(supplemental, get_supplemental()),
  tar_target(tcga_plotting_data, wrangle(tcga, supplemental)),
  tar_target(rppa, get_rppa()),
  tar_target(rppa_plotting_data, wrangle_rppa(tcga_plotting_data, rppa))
)
