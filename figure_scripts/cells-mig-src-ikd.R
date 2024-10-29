library(targets)
library(ggsci)
library(tidyverse)
library(broom)
library(ggrepel)
source("R/functions/common.R")
tar_make(script = "R/targets/tw.R", store = "stores/tw/")

tw <- tar_read(tw, store = "stores/tw/")

fig <- function(data) {
  d <- prep_data(data)
  tt <- test(d)

  plot <- ggplot(d, aes(x = name, y = adj_count, group = date)) +
    geom_line(linewidth = 0.3) +
    geom_point(shape = 16) +
    facet_grid(~cell_line) +
    scale_y_log10() +
    geom_text(data = tt, aes(x, y, label = stars, group = NULL), size = 1.7) +
    custom_ggplot +
    labs(y = "Cells/hr", tag = "B") +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank()
    ) +
    coord_cartesian(ylim = c(NA, 1000), clip = "off")
  ggsave(
    "02_figures/cells-mig-src-ikd.svg", plot,

    width = 38, height = 30, units = "mm"
  )
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character == "ikd 004",
      cell_line %in% c("uc6", "rt112"),
      transwell == "uncoated",
      concentration_uM %in% c(0, 1),
      time_hr == 20,
      loading_number == 100000
    ) |>
    select(date, cell_line, loading_number, drug, count) |>
    mutate(name = if_else(drug == "dox", "+", "-")) |>
    mutate(
      adj_count = (count + 1) / 20,
      cell_line = str_to_upper(cell_line)
    )
}

test <- function(data) {
  data |>
    select(-count, -drug) |>
    pivot_wider(names_from = name, values_from = adj_count) |>
    tapply(~cell_line, \(x) tidy(t.test(x$`+`, x$`-`, paired = TRUE, data = x))) |>
    array2DF() |>
    mutate(stars = format_pval(p.value), x = 1.5, y = 1000)
}

fig(tw)
