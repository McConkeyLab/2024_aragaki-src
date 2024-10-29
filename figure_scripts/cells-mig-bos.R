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
    facet_grid(~consensus, scale = "free_x", space = "free_x") +
    geom_line(linewidth = 0.3) +
    geom_text_repel(
      aes(label = label),
      xlim = c(1, 1),
      direction = "y",
      hjust = 1,
      min.segment.length = 0.1,
      size = 2,
      max.time = 10, max.iter = 1e6,
      force = 15,
      seed = 12
    ) +
    geom_text_repel(
      aes(label = pval_indiv),
      xlim = c(2, 2),
      direction = "y",
      hjust = 0,
      min.segment.length = 0.1,
      size = 2,
      max.time = 10, max.iter = 1e6,
      force = 15,
      seed = 12
    ) +
    geom_text(
      data = all,
      aes(label = pval_all, x = x, y = y, group = NA),
      color = "black"
    ) +
    geom_point(aes(color = drug), shape = 16) +
    scale_y_log10() +
    labs(y = "Cells/hr", color = "Condition") +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "none"
    ) +
    coord_cartesian(x = c(0.5, 2.5), clip = "off")

  ggsave(
    "02_figures/cells-mig-bos.svg", plot,
    width = 77, height = 45, units = "mm"
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

  mutated <- filtered |>
    summarize(
      adj_count = mean((count + 1) / time_hr),
      .by = c(cell_line, drug, consensus, date)
    ) |>
    mutate(
      # Only label one side
      cell_line = toupper(cell_line),
      label = ifelse(drug == "dmso", as.character(cell_line), NA),
      drug = case_when(
        drug == "dmso" ~ "DMSO",
        drug == "bosutinib" ~ "Bosutinib"
      ),
      drug = fct_relevel(drug, "DMSO")
    )
}

test_individual <- function(data) {
  data |>
    select(-label) |>
    filter(n() > 2, .by = cell_line) |>
    pivot_wider(names_from = drug, values_from = adj_count) |>
    tapply(~cell_line, \(x) tidy(t.test(x = x$DMSO, y = x$Bosutinib, paired = TRUE))) |>
    array2DF() |>
    mutate(pval_indiv = format_pval(p.value)) |>
    select(cell_line, pval_indiv)
}

test_all <- function(data) {
  data |>
    summarize(adj_count = mean(adj_count), .by = c(cell_line, drug, consensus)) |>
    pivot_wider(names_from = drug, values_from = adj_count) |>
    mutate(consensus = as.character(consensus)) |>
    tapply(
      ~consensus, \(x) tidy(t.test(x = x$DMSO, y = x$Bosutinib, paired = TRUE))
    ) |>
    array2DF() |>
    mutate(
      x = 1.5,
      y = max(d$adj_count) + 10,
      pval_all = format_pval(p.value),
      consensus = fct_rev(consensus)
    ) |>
    select(consensus, pval_all, x, y)
}

fig(tw)
