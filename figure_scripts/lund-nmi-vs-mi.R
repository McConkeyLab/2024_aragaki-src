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
      width = 0.2, shape = 16, size = 0.5,
      aes(color = muscle_invasive)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1) +
    geom_text(data = tt, aes(x, y, label = label), size = 3) +
    # View, but not error bar, excludes outlier
    coord_cartesian(ylim = c(-2, NA)) +
    labs(x = NULL, y = "SRC", tag = "A") +
    custom_ggplot +
    theme(
      legend.position = "none",
      plot.tag.location = "plot",
      panel.grid.major.x = element_blank()
    )

  ggsave(
    "02_figures/lund-nmi-vs-mi.svg", plot,
    width = 38, height = 50, units = "mm"
  )
}

test <- function(data) {
  tt <- t.test(formula = src ~ muscle_invasive, data = data)
  data.frame(label = format_pval(tt$p.value), x = 1.5, y = max(data$src))
}

fig(lund)
