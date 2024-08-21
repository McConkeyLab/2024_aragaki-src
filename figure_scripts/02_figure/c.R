library(targets)
library(tidyverse)
library(broom)
library(ggsci)
source("R/functions/common.R")
tar_make(script = "R/targets/tcga.R", store = "stores/tcga/")

rppa <- tar_read(rppa_plotting_data, store = "stores/tcga/")

fig <- function(data) {
  tt <- test(data)
  plot <- ggplot(data, aes(subtype, value)) +
    geom_jitter(
      width = 0.2, alpha = 0.5, shape = 16, size = 0.5,
      aes(color = subtype)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1) +
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
    facet_wrap(~peptide, strip.position = "bottom") +
    custom_ggplot +
    theme(
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      plot.tag.location = "plot",
      plot.margin = unit(c(2.5, 0, 0, 0), "lines")
    ) +
    coord_cartesian(ylim = c(NA, 3), clip = "off") +
    labs(y = "Expression", x = NULL, tag = "B", color = "Subtype")
  ggsave(
    "02_figures/02-c.png", plot,
    width = 4, height = 2.5, units = "in", dpi = 500
  )
}

test <- function(data) {
  levels <- levels(data$subtype)
  data$subtype <- as.character(data$subtype)
  split(data, ~peptide) |>
    lapply(\(x) sc(x, "subtype", "LP")) |>
    bind_rows(.id = "peptide") |>
    mutate(
      stars = format_pval(p.value),
      subtype = factor(subtype, levels = levels)
    ) |>
    arrange(subtype) |>
    mutate(
      x = 1,
      xend = rep(seq_len(4), each = 3) + 1,
      y = rep(c(2.5, 3, 3.5, 4), each = 3),
      label_y = y,
      mid = (x + xend) / 2
    )
}

# single comparison
sc <- function(data, stratifier, ref) {
  in_data <- data[data[[stratifier]] == ref, ]
  out_data <- data[data[[stratifier]] != ref, ]
  tapply(
    out_data,
    reformulate(stratifier),
    \(x) tidy(t.test(in_data$value, x$value))
  ) |>
    array2DF()
}

fig(rppa)
