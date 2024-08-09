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

  plot <- ggplot(d, aes(x = name, y = adj_count, group = date)) +
    geom_line(linewidth = 0.2) +
    geom_point(aes(color = name), shape = 16, alpha = 0.75) +
    facet_grid(~panel) +
    scale_y_log10() +
    custom_ggplot +
    labs(y = "Cells/hr", tag = "A") +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank()
    )
  ggsave(
    "02_figures/s01-a.png", plot,
    width = 3.7, height = 2, units = "in", dpi = 500
  )
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character == "parental",
      cell_line == "uc6",
      transwell == "uncoated",
      drug %in% c("dmso", "bosutinib", "saracatinib", "galunisertib", "galunisertib; bosutinib"),
      concentration_uM %in% c(0, 1),
      time_hr == 20,
      loading_number == 100000
    ) |>
    select(date, loading_number, drug, count, operator) |>
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
      panel = str_to_title(panel) |>
        factor(c("Bosutinib", "Galunisertib", "Gal. + Bos.", "Saracatinib"))
    )
}

fig(tw)


tt <- fil |>
  select(-value) |>
  pivot_wider(names_from = name, values_from = adj_count) |>
  tapply(~panel, \(x) tidy(t.test(x$`+`, x$`-`, paired = TRUE, data = x))) |>
  array2DF()

