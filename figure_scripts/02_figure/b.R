library(targets)
library(tidyverse)
library(broom)
library(ggsci)
source("R/functions/common.R")
tar_make(script = "R/targets/tcga.R", store = "stores/tcga/")

tcga <- tar_read(tcga_plotting_data, store = "stores/tcga/")

fig <- function(data) {
  tt <- test(data)
  plot <- ggplot(data, aes(subtype, src)) +
    geom_jitter(
      width = 0.2, shape = 16, alpha = 0.5, size = 0.5, aes(color = subtype)
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
    labs(y = "SRC", x = "TCGA", tag = "B") +
    custom_ggplot +
    theme(
      legend.position = "none",
      panel.grid.major.x = element_blank()
    )
  ggsave(
    "02_figures/02-b.png", plot,
    width = 2, height = 2.5, units = "in", dpi = 500
  )
}

test <- function(data) {
  data$subtype <- as.character(data$subtype)
  lp <- filter(data, subtype  == "LP")
  not_lp <- filter(data, subtype != "LP")
  tapply(not_lp, ~ subtype, \(x) tidy(t.test(lp$src, x$src))) |>
    array2DF() |>
    arrange(estimate) |>
    mutate(
      stars = starify(p.value),
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(15.5, 16, 16.5, 17),
      # "NS" vs "***" heights are different
      label_y = if_else(stars == "NS", y, y - 0.2),
      mid = (x + xend) / 2
    )
}

fig(tcga)
