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
  tt$panel <- factor(tt$panel, levels = levels(d$panel))

  plot <- ggplot(d, aes(x = name, y = adj_count, group = date)) +
    geom_line(linewidth = 0.2) +
    geom_point(aes(color = name), shape = 16, alpha = 0.75) +
    facet_grid(cell_line ~ panel) +
    scale_y_log10() +
    geom_text(data = tt, aes(x, y, label = stars, group = NULL), size = 3) +
    custom_ggplot +
    labs(y = "Cells/hr") +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank()
    ) +
    coord_cartesian(ylim = c(NA, 100), clip = "off")
  ggsave(
    "02_figures/s01-a.png", plot,
    width = 4, height = 2, units = "in", dpi = 500
  )
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character == "parental",
      cell_line %in% c("uc6", "rt112"),
      transwell == "uncoated",
      drug %in% c("dmso", "bosutinib", "saracatinib", "galunisertib", "galunisertib; bosutinib"),
      concentration_uM %in% c(0, 1),
      time_hr == 20,
      loading_number == 100000
    ) |>
    select(date, cell_line, loading_number, drug, count, operator) |>
    pivot_wider(names_from = drug, values_from = count) |>
    pivot_longer(cols = c(saracatinib, bosutinib, galunisertib, `galunisertib; bosutinib`)) |>
    mutate(name = if_else(name == "galunisertib; bosutinib", "Gal. + Bos.", name)) |>
    filter(!is.na(value)) |>
    mutate(panel = name) |>
    pivot_wider() |>
    pivot_longer(cols = c(dmso, saracatinib, bosutinib, galunisertib, `Gal. + Bos.`)) |>
    mutate(name = case_when(name == "dmso" ~ "-",
                            name == panel ~ "+",
                            .default = NA)) |>
    filter(!is.na(name)) |>
    mutate(
      adj_count = (value + 1) / 20,
      cell_line = str_to_upper(cell_line),
      panel = str_to_title(panel) |>
        paste0("\n") |>
        factor(c("Bosutinib\n", "Galunisertib\n", "Gal. + Bos.\n", "Saracatinib\n"))
    )
}

test <- function(data) {
  data |>
    select(-value) |>
    pivot_wider(names_from = name, values_from = adj_count) |>
    mutate(panel_line = paste0(panel, "_", cell_line)) |>
    tapply(~panel_line, \(x) tidy(t.test(x$`+`, x$`-`, paired = TRUE, data = x))) |>
    array2DF() |>
    separate(panel_line, into = c("panel", "cell_line"), sep = "_") |>
    mutate(
      stars = format_pval(p.value),
      x = 1.5,
      y = 150
    )
}

fig(tw)
