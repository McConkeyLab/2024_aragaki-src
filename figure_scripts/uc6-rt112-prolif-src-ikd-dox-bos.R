library(bladdr)
library(ggsci)
library(gplate)
library(tidyverse)
library(mop)
library(broom)
library(drc)
library(ezmtt)
library(patchwork)
library(targets)
tar_make(script = "R/targets/mtt.R", store = "stores/mtt/")

source("R/functions/common.R")

mtt <- tar_read(mtt_data_tidy, store = "stores/mtt/")

panel_a <- function(data) {
  data <- prep_data_a(data)
  stats <- stats_a(data)
  ggplot(data, aes(type, div)) +
    geom_point(aes(color = cell_line)) +
    geom_line(aes(group = rep, color = cell_line)) +
    facet_grid(~cell_line) +
    geom_text(data = stats, aes(label = p.value), size = 2) +
    custom_ggplot +
    labs(y = "Relative OD", tag = "A") +
    theme(
      axis.title.x = element_blank(),
      legend.position = "none"
    ) +
    coord_cartesian(clip = "off", ylim = c(0, NA))
}

prep_data_a <- function(data) {
  data$type <- factor(data$type, c("NT", "004"), c("NT", "iKD"))
  filter(data, drug == "Doxycycline", conc == 1000)
}

stats_a <- function(x) {
  pivot_wider(x, names_from = type, values_from = div) |>
    tapply(~cell_line, \(x) t.test(x$NT, x$iKD, paired = TRUE) |> tidy()) |>
    array2DF() |>
    dplyr::select(cell_line, p.value) |>
    mutate(
      p.value = format_pval(p.value),
      type = 1.5,
      div = max(x$div + 0.1),
      cell_line = factor(cell_line, levels = c("UC6", "RT112"))
    )
}

fig2 <- function(x) {
  ggplot(x, aes(type, div)) +
    geom_line(aes(group = rep)) +
    geom_point(aes(color = type)) +
    facet_grid(~cell_line)
}

panel_b <- function(data) {
  data <- prep_data_b(data)
  fits <- fit_data(data)
  pd <- fit_data_plotting(fits)
  ggplot(pd, aes(x = dose, y = resp)) +
    scale_x_log10(breaks = c(0.1, 1, 100, 10000), labels = c("0", "1", "100", "10000")) +
    lapply(fits, \(x) {
      geom_function(
        aes(linetype = strsplit(x$condition, "_")[[1]][1], color = strsplit(x$condition, "_")[[1]][2]),
        fun = ezmtt:::get_curve_eqn(x)
      )
    }
    ) +
    custom_ggplot +
    labs(color = "Line", linetype = "Type", x = "[Drug]", y = "Relative OD", tag = "B") +
    theme(
      legend.position = "bottom",
      legend.box = "vertical",
      legend.spacing = unit(0, "pt"),
      legend.box.spacing = unit(0, "pt"),
      legend.margin = margin()
    )
}

prep_data_b <- function(data) {
  data$type <- factor(data$type, c("NT", "004"), c("NT", "iKD"))
  filter(data, drug == "Bosutinib")
}

fit_data <- function(data) {
  data$group <- paste(data$type, data$cell_line, sep = "_")
  fits <- tapply(
    data, ~group, \(x) drm(
      div~conc, data = x, fct = LL.4(),
      lowerl = c(-Inf, 0, 0.999, -Inf),
      upperl = c(Inf, 0.001, 1, Inf)
    )
  )
  names <- names(fits)
  mapply(function(x, y) {
    x$condition <- y
    x
  }, fits, names, SIMPLIFY = FALSE)
}


fit_data_plotting <- function(fits) {
  lapply(fits, \(x) ezmtt:::get_fit_data(x)) |>
    bind_rows(.id = "condition")
}

fig <- function(data) {
  a <- panel_a(data)
  b <- panel_b(data)
  plot <- a + b + plot_layout(widths = c(1, 2))
  ggsave(
    "02_figures/uc6-rt112-prolif-src-ikd-dox-bos.svg", plot,
    width = 77, height = 50, units = "mm"
  )
}

fig(mtt)
