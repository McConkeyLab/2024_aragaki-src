library(targets)
library(tidyverse)
library(ggsci)
library(broom)

source("R/functions/common.R")
tar_make(script = "R/targets/uromol.R", store = "stores/uromol/")

uromol <- tar_read(uromol_plotting_data, store = "stores/uromol/")


fig <- function(data) {
  tt <- test(data)
  plot <- ggplot(data, aes(LundTax, SRC)) +
    geom_jitter(
      width = 0.2, shape = 16, alpha = 0.5, size = 0.5,
      aes(color = LundTax)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 2.5
    ) +
    labs(x = "LundTax", y = "SRC", tag = "C") +
    custom_ggplot +
    theme(legend.position = "none")

  ggsave(
    "02_figures/01-c.png", plot,
    width = 2.2, height = 2.7, units = "in", dpi = 500
  )
}

test <- function(data) {
  data$LundTax <- as.character(data$LundTax)
  ua <- filter(data, LundTax == "UroA\nProg")
  not_ua <- filter(data, LundTax != "UroA\nProg")

  tapply(not_ua, ~LundTax, \(x) tidy(t.test(x$SRC, ua$SRC))) |>
    array2DF() |>
    mutate(stars = starify(p.value)) |>
    select(LundTax, p.value, stars) |>
    mutate(
      LundTax = factor(
        LundTax,
        levels = c("UroA\nProg", "GU", "UroC", "GU\nInf1")
      )
    ) |>
    arrange(LundTax) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend) / 2
    )
}

fig(uromol)
