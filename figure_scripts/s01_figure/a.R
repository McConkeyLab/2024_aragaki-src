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

  plot <- ggplot(d, aes(drug, adj_count)) +
    geom_point(aes(color = drug)) +
    scale_y_log10() +
    labs(y = "Cells/hr", color = "Condition", tag = "A") +
    custom_ggplot +
    theme(
      axis.text.x = element_blank(),
      axis.title.x = element_blank()
    ) +
    coord_cartesian(xlim = c(1, NA))

  ggsave(
    "02_figures/s01-a.png", plot,
    width = 3, height = 2, units = "in", dpi = 500
  )
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character == "parental",
      cell_line == "uc6",
      transwell == "uncoated",
      drug %in% c("dmso", "bosutinib", "saracatinib", "galunisertib"),
      all(c("dmso", "bosutinib", "saracatinib", "galunisertib") %in% drug),
      .by = c(date, cell_line)
    ) |>
    summarize(
      adj_count = mean((count + 1) / time_hr),
      .by = c(cell_line, drug)
    ) |>
    mutate(
      drug = case_when(
        drug == "dmso" ~ "DMSO",
        .default = str_to_title(drug)
      ),
      drug = fct_relevel(drug, "DMSO")
    )
}

fig(tw)
