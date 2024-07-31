library(cellebrate)
library(dendextend)
library(fs)
library(ragg)
library(ggsci)
library(classifyBLCA)

make_blca_cells_as_clades_plot <- function(cell_data, out_dir, filename) {
  out_loc <- fs::path(out_dir, paste0(filename, ".png"))

  colors <- pal_npg()(4)
  lp <- colors[1]
  eo <- colors[2]
  me <- colors[3]
  uk <- colors[4]

  agg_png(out_loc, width = 5, height = 3, units = "in", res = 288, background = "#FFFFFF00")

  par(mar = c(4, 1, 1, 1))

  cell_data |>
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
    plot(axes = FALSE)
  dev.off()
  out_loc
}

make_blca_cells_as_clades_plot(cell_rna, ".", "hc.png")

eda_one_gene(cell_rna, "SRC")

consensus <- classify_blca(assay(cell_rna, 2), gene_id = "hgnc", classifier = "consensus")

cd <- as_tibble(colData(cell_rna))

both <- left_join(consensus, cd, by = c(sample = "cell")) |>
  filter(nearest == class) |>
  mutate(class = factor(class, levels = c("lum_p", "ba_sq", "ne_like"))) |>
  arrange(clade, nearest) |>
  mutate(sample = fct_inorder(sample))


table(both$class, both$clade)

ggplot(both, aes(x = sample, y = estimate, color = class)) +
  geom_point() +
  facet_grid(~clade, scales = "free_x", space = "free_x")
