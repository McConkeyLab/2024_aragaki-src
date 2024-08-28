library(cellebrate)
library(tidyverse)
library(ggsci)
library(DESeq2)
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
      panel.grid.major.x = element_blank(),
      plot.tag.location = "plot",
      plot.margin = unit(c(2, 0, 0, 0), "lines")

    ) +
    scale_x_discrete(labels = c("LP", "BS", "NE")) +
    coord_cartesian(y = c(NA, 14), clip = "off") +
    labs(x = NULL, y = "SRC", tag = "A")

  ggsave(
    "02_figures/cells-src-across-consensus.png", plot,
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
      stars = format_pval(p.value),
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(14.5, 15),
      # "NS" vs "***" heights are different
      label_y = y,
      mid = (x + xend) / 2
    )
}

fig(cell_rna)
