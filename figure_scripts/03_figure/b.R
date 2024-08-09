library(cellebrate)
library(tidyverse)
library(ggsci)
library(broom)
tar_make(script = "R/targets/cell_rna.R", store = "stores/cell_rna/")

source("R/functions/common.R")

cell_rna <- tar_read(cell_rna, store = "stores/cell_rna/")

fig <- function(cell_rna) {
  exp <- assay(cell_rna, "rlog_norm_counts")
  src <- exp[rownames(exp) == "SRC", ]
  data <- data.frame(consensus = cell_rna$consensus, src = src)
  tt <- test(data)
  plot <- ggplot(data, aes(consensus, src)) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1, linewidth = 0.2) +
    geom_jitter(
      shape = 16, size = 0.75, alpha = 0.75, width = 0.2,
      aes(color = consensus)
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
    scale_x_discrete(labels = c("LP", "BS", "NE")) +
    coord_cartesian(y = c(NA, 15.2)) +
    labs(x = "Consensus", y = "SRC", tag = "B")

  ggsave(
    "02_figures/03-b.png", plot,
    width = 2, height = 2.5, units = "in", dpi = 500
  )
}


test <- function(data) {
  data$consensus <- as.character(data$consensus)
  lp <- filter(data, consensus == "LP")
  not_lp <- filter(data, consensus != "LP")
  tapply(not_lp, ~ consensus, \(x) tidy(t.test(lp$src, x$src))) |>
    array2DF() |>
    mutate(consensus = factor(consensus, c("BS", "NE"))) |>
    arrange(consensus) |>
    mutate(
      stars = starify(p.value),
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(14.5, 15),
      # "NS" vs "***" heights are different
      label_y = if_else(stars == "NS", y, y - 0.2),
      mid = (x + xend) / 2
    )
}

fig(cell_rna)
