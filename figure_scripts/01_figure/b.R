library(targets)
library(tidyverse)
library(ggsci)
library(broom)

source("R/functions/common.R")
tar_make(script = "R/targets/uromol.R", store = "stores/uromol/")

uromol <- tar_read(uromol_plotting_data, store = "stores/uromol/")

fig <- function(data) {
  tt <- test(data)
  plot <- ggplot(data, aes(uromol, SRC)) +
    geom_jitter(
      width = 0.2, shape = 16, alpha = 0.4, size = 0.5,
      aes(color = uromol)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1) +
    labs(x = "UROMOL", y = "SRC", tag = "B") +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      size = 2.5,
      inherit.aes = FALSE
    ) +
    custom_ggplot +
    theme(
      legend.position = "none",
      panel.grid.major.x = element_blank()
    )

  ggsave(
    "02_figures/01-b.png", plot,
    width = 1.5, height = 2.7, units = "in", dpi = 500
  )
}


test <- function(data) {
  cl1 <- filter(data, uromol == "1")
  not_cl1 <- filter(data, uromol != "1")

  tapply(not_cl1, ~uromol, \(x) tidy(t.test(x$SRC, cl1$SRC))) |>
    array2DF() |>
    mutate(stars = starify(p.value)) |>
    select(uromol, p.value, stars) |>
    arrange(uromol) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend) / 2
    )
}

fig(uromol)
