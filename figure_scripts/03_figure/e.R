library(cellebrate)
library(DESeq2)
library(pheatmap)

fig <- function() {
  genes <- c("CDH1", "ZEB1", "ZEB2")
  data <- cell_rna[rownames(cell_rna) %in% genes, ] |>
    assay(2)

  data <- data[, order(colData(cell_rna)$clade)]
  col_annot <- data.frame(
    row.names = colData(cell_rna)$cell, Clade = colData(cell_rna)$clade
  )

  pal <- pal_npg()(4)
  ann_colors <- list(
    Clade = c("Luminal Papillary" = pal[1],
              "Epithelial Other" = pal[2],
              "Mesenchymal" = pal[3],
              "Unknown" = pal[4])
  )
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
fig()
