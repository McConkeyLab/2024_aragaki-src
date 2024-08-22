library(mop)
library(bladdr)
library(amplify)

source("R/functions/common.R")

fig <- function() {
  d <- wrangle()
  summary <- d |>
    reframe(
      as_tibble(rownames = "name", Hmisc::smean.cl.normal(rq)),
      .by = c(line, type, dox)
    ) |>
    pivot_wider()
  plot <- ggplot(o, aes(dox, rq, color = type)) +
    facet_grid(~line) +
    geom_point(shape = 16, position = position_dodge(width = 0.5), alpha = 0.5) +
    geom_pointrange(
      data = o_summary,
      aes(y = Mean, ymin = Lower, ymax = Upper),
      position = position_dodge2(width = 0.5)
    ) +
    scale_y_log10() +
    labs(
      y = "Relative Quantitity",
      color = ""
    ) +
    custom_ggplot +
    theme(
      legend.position = "bottom",
      axis.title.x = element_blank()
    )

  ggsave(
    "02_figures/kd-works-pcr.png", plot, width = 2, height = 2.5, dpi = 500
  )
}

wrangle <- function() {
  get_pcr("2024-04-29_uc6-rt112-nt-004-nodox-dox.xls", user = "aragaki-kai") |>
    read_pcr() |>
    scrub() |>
    filter(
      !is.na(sample_name), target_name %in% c("SRC", "GAPDH")
    ) |>
    separate(sample_name, c("line", "type", "dox", "rep")) |>
    select(.row, .col, ct, target_name, line, type, dox, rep) |>
    unite(sample_name, type, dox, rep, remove = FALSE) |>
    tapply(~line, \(x) pcr_rq(x, "nt_nodox_1", "GAPDH")) |>
    array2DF() |>
    select(-1) |>
    as_tibble() |>
    filter(target_name == "SRC") |>
    mutate(
      type = factor(type, c("nt", "004"), c("NT", "SRC iKD")),
      dox = factor(dox, c("nodox", "dox"), c("-", "+")),
      line = factor(line, c("rt112", "uc6"), c("RT112", "UM-UC6"))
    ) |>
    select(type, rq, dox, line) |>
    distinct()
}

fig()
