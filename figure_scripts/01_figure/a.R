library(targets)
library(tidyverse)
library(ggsci)
source("R/functions/common.R")
tar_make(script = "R/targets/lund.R", store = "stores/lund/")

lund <- tar_read(lund_plotting_data, store = "stores/lund/")

fig <- function(data) {
  tt <- test(data)
  plot <- ggplot(data, aes(muscle_invasive, src)) +
    geom_jitter(
      width = 0.2, shape = 16, alpha = 0.5, size = 0.5,
      aes(color = muscle_invasive)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    geom_text(data = tt, aes(x, y, label = label), size = 5) +
    # View, but not error bar, excludes outlier
    coord_cartesian(ylim = c(-2, NA)) +
    labs(x = NULL, y = "SRC", tag = "A") +
    custom_ggplot +
    theme(legend.position = "none")

  ggsave(
    "02_figures/01-a.png", plot,
    width = 1.2, height = 2.5, units = "in", dpi = 500
  )
}

test <- function(data) {
  tt <- t.test(formula = src ~ muscle_invasive, data = data)
  data.frame(label = starify(tt$p.value), x = 1.5, y = max(data$src))
}

fig(lund)
