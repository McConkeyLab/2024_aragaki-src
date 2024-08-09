library(cellebrate)
library(ggsci)
library(tidyverse)
library(classifyBLCA)
library(DESeq2)
tar_make(script = "R/targets/cell_rna.R", store = "stores/cell_rna/")

source("R/functions/common.R")

cell_rna <- tar_read(cell_rna, store = "stores/cell_rna/")

fig <- function(cell_rna) {
  plot <- ggplot(colData(cell_rna), aes(clade, fill = consensus)) +
    geom_bar() +
    scale_fill_npg() +
    theme_minimal() +
    custom_ggplot +
    labs(x = "Clade", fill = "Consensus", y = "Count", tag = "C")

  ggsave(
    "02_figures/03-c.png", plot,
    width = 3, height = 2.5, units = "in", dpi = 500
  )
}

fig(cell_rna)
