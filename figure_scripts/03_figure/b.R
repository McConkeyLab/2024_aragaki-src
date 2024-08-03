library(cellebrate)
library(tidyverse)
library(ggsci)
library(broom)

source("R/functions/common.R")

fig <- function() {
  exp <- assay(cell_rna, "rlog_norm_counts")
  src <- exp[rownames(exp) == "SRC", ]
  clades <- cell_rna$clade
  data <- data.frame(clade = clades, src = src)
  tt <- test(data)
  plot <- ggplot(data, aes(clade, src)) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1, linewidth = 0.2) +
    geom_jitter(
      shape = 16, size = 0.75, alpha = 0.75, width = 0.2,
      aes(color = clade)
    ) +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = label_y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 3
    ) +
    custom_ggplot +
    theme(
      legend.position = "none",
      panel.grid.major.x = element_blank()
    ) +
    scale_x_discrete(labels = c("LP", "Ep.", "Mes.", "Unk.")) +
    coord_cartesian(y = c(NA, 15.2)) +
    labs(x = "Clade", y = "SRC", tag = "B")

  ggsave(
    "02_figures/03-b.png", plot,
    width = 2, height = 2.5, units = "in", dpi = 500
  )
}


test <- function(data) {
  data$clade <- as.character(data$clade)
  lp <- filter(data, clade == "Luminal Papillary")
  not_lp <- filter(data, clade != "Luminal Papillary")
  tapply(not_lp, ~ clade, \(x) tidy(t.test(lp$src, x$src))) |>
    array2DF() |>
    mutate(clade = factor(clade, c("Epithelial Other", "Mesenchymal", "Unknown"))) |>
    arrange(clade) |>
    mutate(
      stars = starify(p.value),
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(14, 14.5, 15),
      # "NS" vs "***" heights are different
      label_y = if_else(stars == "NS", y, y - 0.2),
      mid = (x + xend) / 2
    )
}

fig()
