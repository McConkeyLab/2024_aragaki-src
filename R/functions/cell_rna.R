classify_cells <- function() {
  consensus <- classify_blca(
    assay(cellebrate::cell_rna, 2), gene_id = "hgnc", classifier = "consensus"
  )
  cd <- as_tibble(colData(cellebrate::cell_rna))

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
    ) |>
    select(cell = sample, consensus = class, clade)

  both <- both[match(colnames(cell_rna), both$cell), ]

  colData(cell_rna) <- DataFrame(both)
  colnames(cell_rna) <- colnames(cellebrate::cell_rna)
  cell_rna
}
