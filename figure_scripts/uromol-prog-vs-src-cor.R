library(targets)
library(tidyverse)
library(ggsci)
library(broom)

source("R/functions/common.R")
tar_make(script = "R/targets/uromol.R", store = "stores/uromol/")

uromol <- tar_read(uromol_plotting_data, store = "stores/uromol/")

wrangle <- function(data) {
  select(data, uromol, SRC, Progression = `Progression signature score`)
}

# Calculate correlation between SRC expression and signature values, stratified
# by uromol class
test <- function(data) {
  data |>
    tapply(~uromol, \(x) tidy(cor.test(x$SRC, x$Progression))) |>
    array2DF() |>
    mutate(
      p = format_pval(p.value),
      r = paste("R =", round(estimate, 2)),
      label = paste0(p, "\n", r)
    )
}

fig <- function(data) {
  plot <- ggplot(data, aes(SRC, Progression)) +
    geom_point(shape = 16, size = 0.5, aes(color = uromol)) +
    geom_smooth(method = lm, se = FALSE, color = "black", linewidth = 0.3) +
    geom_text(data = test(data), aes(x = 4, y = 0, label = label), hjust = 0, size = 1.7, vjust = 0) +
    facet_grid(~uromol) +
    labs(tag = "C") +
    custom_ggplot +
    theme(
      legend.position = "none",
      plot.tag.location = "plot",
      panel.spacing.x = unit(0.5, "lines"),
      plot.margin = unit(c(0, 0.5, 0, 0), "lines")
    )
  ggsave(
    "02_figures/uromol-prog-vs-src-cor.svg",  plot,
    width = 77, height = 30, units = "mm"
  )
}
fig(wrangle(uromol))
