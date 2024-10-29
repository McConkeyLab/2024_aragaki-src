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

add_emt <- function(cell_rna, emt_scores) {
  colData(cell_rna) <- cbind(colData(cell_rna), t(assay(emt_scores)))
  cell_rna
}

do_gsva <- function(cell_rna, sigs, assay_name) {
  cell_rna |>
    gsvaParam(sigs, assay = assay_name, kcdf = "Gaussian") |>
    gsva()
}

prep_hallmarks <- function() {
  msigdbr(category = "H") |>
    mutate(
      gs_name = gs_name |>
        str_remove("HALLMARK_") |>
        str_replace_all("_", " ") |>
        str_to_title()
    ) |>
    dplyr::rename(gene = gene_symbol) |>
    select(gs_name, gene) |>
    split(~ gs_name) |>
    lapply(\(x) x$gene)
}

wrangle <- function(data) {
  assay(data) |>
    as_tibble(rownames = "signature")
}
