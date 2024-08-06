library(cellebrate)
library(ggsci)
library(tidyverse)
library(classifyBLCA)
library(DESeq2)

source("R/functions/common.R")

fig <- function() {
  consensus <- classify_blca(
    assay(cell_rna, 2), gene_id = "hgnc", classifier = "consensus"
  )

  cd <- as_tibble(colData(cell_rna))

  both <- left_join(consensus, cd, by = c(sample = "cell")) |>
    filter(nearest == class) |>
    mutate(
      class = factor(
        class,
        c("lum_p", "ba_sq", "ne_like"),
        c("LP", "BS", "NE")
      ),
      clade = factor(
        clade,
        c("Luminal Papillary", "Epithelial Other", "Mesenchymal", "Unknown"),
        c("LP", "Ep.", "Mes.", "Unk.")
      )
    )
  plot <- ggplot(both, aes(clade, fill = class)) +
    geom_bar() +
    scale_fill_npg() +
    theme_minimal() +
    custom_ggplot +
    labs(x = "Clade", fill = "TCGA", tag = "C")

  ggsave(
    "02_figures/03-c.png", plot,
    width = 2.5, height = 2.5, units = "in", dpi = 500
  )
}

fig()
