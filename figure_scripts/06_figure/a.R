library(ggsci)
library(survival)
library(tidyverse)
library(ggsurvfit)
library(broom)

source("R/functions/common.R")
tvi <- read_csv("01_data/01_in-vivo/survival.csv")

fig <- function(data) {
  wrangled <- wrangle(data)
  plotting_data <- fit(wrangled)
  tt <- test(wrangled)

  plot <- ggplot(plotting_data, aes(time, estimate)) +
    facet_grid(~cell_line) +
    geom_step(aes(color = dox)) +
    custom_ggplot +
    theme(legend.position = "top") +
    geom_text(
      data = tt, aes(x = 0, y = 0.5, label = label),
      hjust = 0, size = 3
    ) +
    labs(y = "OS", x = "Time (days)", color = "SRC KD")
  ggsave(
    "02_figures/06-a.png", plot,
    width = 4, height = 2.5, units = "in", dpi = 500
  )
}

wrangle <- function(data) {
  distinct(tvi, id, .keep_all = TRUE) |>
    mutate(
      injection_date = if_else(cell_line == "UC6", as.Date("2023-11-10"), as.Date("2024-02-28")),
      days_to_death = death_date - injection_date
    ) |>
    filter(type == "iKD")
}

test <- function(data) {
  tapply(
    data, ~cell_line,
    \(x) glance(survdiff(Surv(days_to_death, event) ~ dox, data = x))
  ) |>
    array2DF() |>
    as_tibble() |>
    mutate(label = paste0("p = ", signif(p.value, 2)))
}

fit <- function(data) {
  survfit2(Surv(days_to_death, event) ~ cell_line + dox, data = data) |>
    tidy_survfit() |>
    separate(strata, c("cell_line", "dox"), sep = ", ")
}

fig(tvi)
