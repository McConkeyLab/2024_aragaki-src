library(cellebrate)
library(dendextend)
library(fs)
library(ragg)
library(ggsci)
library(DESeq2)

fig <- function() {
  colors <- pal_npg()(4)
  lp <- colors[1]
  eo <- colors[2]
  me <- colors[3]
  uk <- colors[4]

  agg_png(
    "02_figures/03-a.png",
    width = 2.5, height = 5.2, units = "in", res = 500,
    background = "#FFFFFF00"
  )

  par(mar = c(0.5, 1, 0.5, 4))

  cellebrate::cell_rna |>
    assay("rlog_norm_counts") |>
    t() |>
    dist() |>
    hclust(method = "average") |>
    as.dendrogram() |>
    set(
      "labels_col",
      value = c(
        rep(1, 6), rep(lp, 5),
        1, lp, 1, lp, lp, 1, 1, 1, lp,
        rep(1, 8), lp, 1
      )
    ) |>
    set(
      "by_labels_branches_col",
      value = c("UC4", "253JP", "BV"),
      TF_values = uk
    ) |>
    set(
      "by_labels_branches_col",
      value = c("UC17", "UC6", "RT4", "RT4V6", "UC5", "UC14", "UC1", "RT112", "SW780"),
      TF_values = lp
    ) |>
    set(
      "by_labels_branches_col",
      value = c("HT1197", "HT1376", "UC9", "UC15", "UC10", "UC7", "SCaBER", "UC16", "1A6", "5637"),
      TF_values = eo
    ) |>
    set(
      "by_labels_branches_col",
      value = c("UC12", "UC3", "TCCSup", "UC11", "UC13", "T24", "J82", "UC18"),
      TF_values = me
    ) |>
    set("branches_lwd", 2) |>
    set("labels_cex", 1) |>
    plot(axes = FALSE, horiz = TRUE)
  mtext("A", side = 3, line = -2, at = 300, cex = 2.5)
  dev.off()
  "02_figures/03-a.png"
}

fig()
