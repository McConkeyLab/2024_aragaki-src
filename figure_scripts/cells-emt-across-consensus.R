library(cellebrate)
library(msigdbr)
library(GSVA)
library(ggsci)
library(tidyverse)
library(broom)
library(DESeq2)
tar_make(script = "R/targets/cell_rna.R", store = "stores/cell_rna/")

source("R/functions/common.R")

cell_rna <- tar_read(cell_rna, store = "stores/cell_rna/")

fig <- function(cell_rna) {
  data <- prep_data(cell_rna)
  tt <- test(data)
  aov_sig <- filter(
    tt, aov_p_adj < 0.05, signature == "Epithelial Mesenchymal Transition"
  )
  data <- semi_join(data, aov_sig, by = "signature")

  plot <- ggplot(data, aes(consensus, value, color = consensus)) +
    geom_hline(yintercept = 0, linewidth = 0.3) +
    geom_jitter(shape = 16, size = 0.75, width = 0.2) +
    geom_segment(
      data = aov_sig, aes(x = x, xend = xend, y = y, yend = yend),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = aov_sig, aes(y = label_y, x = mid, label = label),
      vjust = -0.3,
      size = 1.7,
      inherit.aes = FALSE
    ) +
    custom_ggplot +
    theme(
      panel.grid.major.x = element_blank(),
      axis.title.x = element_blank(),
      legend.position = "none",
      plot.margin = unit(c(1.2, 0, 0, 0), "lines"),
      plot.tag.location = "plot"
    ) +
    coord_cartesian(ylim = c(-0.6, 0.6), clip = "off") +
    labs(color = "Consensus", y = "EMT Score", tag = "B")

  ggsave(
    "02_figures/cells-emt-across-consensus.svg", plot,
    width = 38, height = 40, units = "mm"
  )
}

prep_data <- function(cell_rna) {
  do_gsva(cell_rna, prep_hallmarks(), "rlog_norm_counts") |>
    wrangle()
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
    as_tibble(rownames = "signature") |>
    pivot_longer(-signature, names_to = "cell") |>
    left_join(as_tibble(colData(data)), by = "cell")
}

test <- function(data) {
  aov <- tapply(data, ~signature, \(x) tidy(aov(value ~ consensus, x))) |>
    array2DF() |>
    filter(term == "consensus") |>
    mutate(
      aov_p_adj = p.adjust(p.value, method = "BH"),
      aov_stars = starify(aov_p_adj)
    ) |>
    select(signature, aov_p_adj, aov_stars)
  tapply(data, ~signature, t_fun) |>
    array2DF() |>
    mutate(
      tt_p_adj = p.adjust(p.value, method = "BH"),
      tt_stars = format_pval(tt_p_adj),
      .by = signature
    ) |>
    select(signature, test, tt_p_adj, tt_stars) |>
    left_join(aov, by = "signature") |>
    mutate(
      label = if_else(aov_p_adj < 0.05, tt_stars, NA),
      x = match(str_extract(test, "^[^_]*"), c("lp", "e", "m")),
      xend = match(str_extract(test, "[^_]*$"), c("lp", "e", "m")),
      y = case_when(
        x == 1 & xend == 2 ~ 0.7,
        x == 1 & xend == 3 ~ 0.8,
        x == 3 ~ 0.6
      ),
      yend = y,
      label_y = y,
      mid = (x + xend) / 2
    )
}

t_fun <- function(data) {
  lp_v_e <- t.test(value ~ consensus, filter(data, consensus %in% c("LP", "BS"))) |>
    tidy() |>
    mutate(test = "lp_v_e")
  m_v_e <- t.test(value ~ consensus, filter(data, consensus %in% c("NE", "BS"))) |>
    tidy() |>
    mutate(test = "m_v_e")
  lp_v_m <- t.test(value ~ consensus, filter(data, consensus %in% c("LP", "NE"))) |>
    tidy() |>
    mutate(test = "lp_v_m")
  bind_rows(lp_v_e, m_v_e, lp_v_m)
}

fig(cell_rna)
