library(ggsci)
library(tidyverse)
library(bladdr)
library(readxl)
library(broom)

source("R/functions/common.R")

wrangle <- function() {
  read_excel("local-data/in-vivo/tail-vein.xlsx") |>
    filter(str_detect(line, "NT")) |>
    mutate(
      cell_line = "UC6",
      type = "NT",
      dox = ifelse(str_detect(line, "_D$"), "+", "-")
    )
}

test <- function(data) {
  tidy(t.test(mets_to_lung_ratio ~ dox, data = data)) |>
    mutate(
      label = format_pval(p.value),
      y = max(data$mets_to_lung_ratio, na.rm = TRUE),
      x = 1.5
    )
}

fig <- function() {
  d <- wrangle()
  tt <- test(d)
  mets_summary <- d |>
    reframe(
      as_tibble(rownames = "name", Hmisc::smean.cl.normal(mets_to_lung_ratio)),
      .by = c(line, dox, type, cell_line)
    ) |>
    mutate(value = ifelse(value < 0.0001, 0.0001, value)) |>
    pivot_wider()

  plot <- ggplot(d, aes(dox, mets_to_lung_ratio + 0.0001, color = dox)) +
    scale_y_log10() +
    geom_jitter(width = 0.1, height = 0, shape = 16, size = 0.5) +
    geom_pointrange(data = mets_summary, aes(y = Mean, ymin = Lower, ymax = Upper)) +
    geom_text(data = tt, aes(x = x, y = y, label = label),
              color = "black", size = 2.5, vjust = 0) +
    labs(y = "Met./Lung Area", tag = "B") +
    coord_cartesian(clip = "off") +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      panel.grid.major.x = element_blank(),
      plot.tag.location = "plot",
      legend.position = "none"
    )
  ggsave(
    "02_figures/in-vivo-met-ratio.svg", plot,
    width = 17, height = 100, units = "mm"
  )
}

fig()
