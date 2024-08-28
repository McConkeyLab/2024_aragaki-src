library(bladdr)
library(gplate)
library(tidyverse)
library(mop)
tar_make(script = "R/targets/mtt.R", store = "stores/mtt/")

source("R/functions/common.R")

mtt <- tar_read(mtt_data_tidy, store = "stores/mtt/")

fig <- function(data) {
  data$type <- factor(data$type, c("NT", "004"), c("NT", "iKD"))
  plot <- ggplot(data, aes(conc, div, color = type)) +
    geom_hline(yintercept = c(0.5, 1), linewidth = 0.2) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2, position = position_dodge2(width = 0.2)) +
    facet_grid(cell_line ~ drug) +
    scale_x_log10(breaks = c(0.1, 1, 100, 10000), labels = c("0", "1", "100", "10000")) +
    scale_y_continuous(breaks = seq(0, 1, length.out = 3)) +
    custom_ggplot +
    labs(color = "Cell Line Type", x = "[Drug]", y = "Relative OD") +
    theme(
      panel.spacing.x = unit(1, "line"),
      legend.position = "bottom"
    )
  ggsave(
    "02_figures/uc6-rt112-prolif-src-ikd-dox-bos.png", plot,
    width = 4, height = 3, units = "in", dpi = 500
  )
}

fig(mtt)
