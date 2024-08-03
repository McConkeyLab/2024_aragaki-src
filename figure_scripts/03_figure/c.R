library(cellebrate)
library(ggsci)
library(classifyBLCA)

source("R/functions/common.R")

fig <- function() {
  consensus <- classify_blca(
    assay(cell_rna, 2), gene_id = "hgnc", classifier = "consensus"
  )

  cd <- as_tibble(colData(cell_rna))

  both <- left_join(consensus, cd, by = c(sample = "cell")) |>
    filter(nearest == class) |>
    mutate(class = factor(class, ))
    mutate(
      class = case_when(
        class == "lum_p" ~ "LP",
        class == "ba_sq" ~ "BS",
        class == "ne_like" ~ "NE",
        .default = NA
      ),
      clade = case_when(

      )
    )

  ggplot(both, aes(clade, fill = nearest)) +
    geom_bar() +
    scale_fill_npg() +
    theme_minimal() +
    custom_ggplot +
    labs(x = "TCGA")
}

fig()
