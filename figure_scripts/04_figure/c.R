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

  plot <- ggplot(d, aes(drug, adj_count, group = cell_line)) +
    facet_grid(~clade, scale = "free_x", space = "free_x") +
    geom_line(linewidth = 0.2) +
    geom_text_repel(
      aes(label = label),
      xlim = c(1, 1),
      direction = "y",
      hjust = 1,
      min.segment.length = 0.1,
      size = 2,
      max.time = 10, max.iter = 1e6,
      force = 6,
      seed = 3
    ) +
    geom_point(aes(color = drug)) +
    scale_y_log10() +
    labs(y = "Cells/hr", color = "Condition") +
    custom_ggplot +
    theme(
      axis.text.x = element_blank(),
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank()
    ) +
  coord_cartesian(x = c(1, 2), clip = "off")

  ggsave(
    "02_figures/04-c.png", plot,
    width = 6, height = 2, units = "in", dpi = 500
  )
}


prep_data <- function(data) {
  filtered <- data |>
    filter(
      cell_line_character == "parental",
      transwell == "uncoated",
      drug %in% c("bosutinib", "dmso"),
      all(c("bosutinib", "dmso") %in% drug),
      loading_number == 1e5,
      time_hr == 20,
      .by = c("cell_line", "date")
    )

  filtered |>
    summarize(
      adj_count = mean((count + 1) / time_hr),
      .by = c(cell_line, drug, clade)
    ) |>
    mutate(
      # Only label one side
      cell_line = toupper(cell_line),
      label = ifelse(drug == "dmso", as.character(cell_line), NA),
      drug = case_when(
        drug == "dmso" ~ "DMSO",
        drug == "bosutinib" ~ "Bosutinib"
      ),
      drug = fct_relevel(drug, "DMSO"),
      clade = case_when(
        clade == "Luminal Papillary" ~ "LP",
        clade == "Epithelial Other" ~ "Ep. Other",
        clade == "Mesenchymal" ~ "Mes.",
        .default = NA
      ),
      clade = factor(clade, c("LP", "Ep. Other", "Mes."))
    )
}

test <- function(data) {
  by_exp |>
    select(-label) |>
    pivot_wider(names_from = drug, values_from = adj_count) |>
    filter(clade != "Mes.") |>
    mutate(clade = as.character(clade)) |>
    tapply(
      ~clade, \(x) tidy(t.test(x = x$dmso, y = x$bosutinib, paired = TRUE))
    )
}

fig(tw)
