library(targets)
library(tidyverse)
library(ggsci)
library(broom)

source("R/functions/common.R")
tar_make(script = "R/targets/uromol.R", store = "stores/uromol/")

uromol <- tar_read(uromol_plotting_data, store = "stores/uromol/")

wrangle <- function(data) {
  data |>
    select(uromol, SRC, contains("signature")) |>
    pivot_longer(cols = -(uromol:SRC)) |>
    mutate(name = str_remove(name, "[:space:]signature")) |>
    arrange(name)
}

# Calculate correlation between SRC expression and signature values, stratified
# by uromol class
test <- function(data) {
  data$name_uromol <- paste0(data$name, "_", data$uromol)
  data |>
    tapply(~name_uromol, \(x) tidy(cor.test(x$SRC, x$value))) |>
    array2DF() |>
    separate(name_uromol, c("name", "uromol"), sep = "_") |>
    mutate(star = starify(p.value))
}

fig <- function(data) {
  data$name <- fct_reorder(data$name, data$estimate)
  plot <- ggplot(data, aes(color = uromol, y = name, group = uromol)) +
    geom_vline(xintercept = 0, linewidth = 0.2) +
    geom_linerange(
      aes(xmin = conf.low, x = estimate, xmax = conf.high),
      position = position_dodge2(width = 1)
    ) +
    facet_grid(rows = "name", scales = "free", switch = "y") +
    custom_ggplot +
    theme(
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      strip.text.y.left = element_text(angle = 0, hjust = 1),
      legend.position = "right"
    ) +
    labs(x = "R", color = "UROMOL")
  ggsave(
    "02_figures/01-b_extra.png",
    plot,
    width = 4, height = 4, units = "in", dpi = 500
  )
}
fig(test(wrangle(uromol)))
