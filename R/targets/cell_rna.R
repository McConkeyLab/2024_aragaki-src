library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "cellebrate", "classifyBLCA", "DESeq2", "tidyverse", "GSVA", "msigdbr",
    "conflicted" # MUST be loaded last
  )
)

source("./R/functions/cell_rna.R")

list(
  tar_target(cell_rna, classify_cells()),
  tar_target(
    emt_scores, do_gsva(cell_rna, prep_hallmarks(), "rlog_norm_counts")
  ),
  tar_target(
    w_emt, add_emt(cell_rna, emt_scores)
  )
)
