library(cellebrate)
library(DESeq2)
library(pheatmap)
tar_make(script = "R/targets/cell_rna.R", store = "stores/cell_rna/")

cell_rna <- tar_read(cell_rna, store = "stores/cell_rna/")

fig <- function(cell_rna) {
  genes <- c("CDH1", "ZEB1", "ZEB2")
  data <- cell_rna[rownames(cell_rna) %in% genes, ] |>
    assay(2)

  data <- data[, order(colData(cell_rna)$consensus)]
  col_annot <- data.frame(
    row.names = colData(cell_rna)$cell, Consensus = colData(cell_rna)$consensus
  )

  pal <- pal_npg()(3)
  ann_colors <- list(Clade = c("LP" = pal[1], "BS" = pal[2], "NE" = pal[3]))
  png("02_figures/03-e.png", width = 6, height = 2.4, units = "in", res = 500)
  pheatmap(
    data, scale = "row", annotation_col = col_annot,
    cluster_cols = FALSE, cluster_rows = FALSE,
    border_color = NA,
    color = colorRampPalette(c("green", "black", "red"))(100),
    annotation_colors = ann_colors,
    main = "E                                                                     " #nolint lol
  )
  dev.off()
}
fig(cell_rna)
