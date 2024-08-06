library(cellebrate)
library(msigdbr)
library(GSVA)
library(ggsci)
library(tidyverse)
library(broom)

source("R/functions/common.R")

fig <- function() {
  data <- prep_data()
  tt <- test(data)
  aov_sig <- filter(tt, aov_p_adj < 0.05)
  data <- semi_join(data, aov_sig, by = "signature") |>
    mutate(signature = str_replace_all(signature, " ", "\n"))
  aov_sig <- mutate(aov_sig, signature = str_replace_all(signature, " ", "\n"))

  plot <- ggplot(data, aes(clade, value, color = clade)) +
    geom_jitter(shape = 16, size = 0.75, alpha = 0.75, width = 0.2) +
    facet_grid(~signature) +
    geom_segment(
      data = aov_sig, aes(x = x, xend = xend, y = y, yend = yend),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = aov_sig, aes(y = label_y, x = mid, label = label),
      vjust = -0.3,
      size = 2.5,
      inherit.aes = FALSE
    ) +
    custom_ggplot +
    theme(
      panel.grid.major.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank(),
      legend.position = "bottom"
    ) +
    coord_cartesian(ylim = c(NA, 1)) +
    labs(color = "Clade", y = "Score", tag = "D")

  ggsave(
    "02_figures/03-d.png", plot,
    width = 6.5, height = 2, units = "in", dpi = 500
  )
}

prep_data <- function() {
  do_gsva(prep_hallmarks(), "rlog_norm_counts") |>
    wrangle()
}

do_gsva <- function(sigs, assay_name) {
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
    left_join(as_tibble(colData(data)), by = "cell") |>
    mutate(
      clade = factor(
        clade,
        levels = c("Luminal Papillary", "Epithelial Other", "Mesenchymal", "Unknown"),
        labels = c("LP", "Ep. Other", "Mes.", "Unk")
      )
    )
}

test <- function(data) {
  aov <- tapply(data, ~signature, \(x) tidy(aov(value ~ clade, x))) |>
    array2DF() |>
    filter(term == "clade") |>
    mutate(
      aov_p_adj = p.adjust(p.value, method = "BH"),
      aov_stars = starify(aov_p_adj)
    ) |>
    select(signature, aov_p_adj, aov_stars)
  tapply(data, ~signature, t_fun) |>
    array2DF() |>
    mutate(
      tt_p_adj = p.adjust(p.value, method = "BH"),
      tt_stars = starify(tt_p_adj),
      .by = signature
    ) |>
    select(signature, test, tt_p_adj, tt_stars) |>
    left_join(aov, by = "signature") |>
    mutate(
      label = if_else(aov_p_adj < 0.05, tt_stars, NA),
      x = match(str_extract(test, "^[^_]*"), c("lp", "e", "m")),
      xend = match(str_extract(test, "[^_]*$"), c("lp", "e", "m")),
      y = case_when(
        x == 1 & xend == 2 ~ 0.6,
        x == 1 & xend == 3 ~ 0.8,
        x == 3 ~ 0.5
      ),
      yend = y,
      label_y = if_else(tt_stars == "NS", y, y - 0.075),
      mid = (x + xend) / 2
    )
}

t_fun <- function(data) {
  lp_v_e <- t.test(value ~ clade, filter(data, clade %in% c("LP", "Ep. Other"))) |>
    tidy() |>
    mutate(test = "lp_v_e")
  m_v_e <- t.test(value ~ clade, filter(data, clade %in% c("Mes.", "Ep. Other"))) |>
    tidy() |>
    mutate(test = "m_v_e")
  lp_v_m <- t.test(value ~ clade, filter(data, clade %in% c("LP", "Mes."))) |>
    tidy() |>
    mutate(test = "lp_v_m")
  bind_rows(lp_v_e, m_v_e, lp_v_m)
}

fig()
