library(ggsci)
library(tidyverse)
library(broom)
source("R/functions/common.R")
tar_make(script = "R/targets/tw.R", store = "stores/tw/")

tw <- tar_read(tw, store = "stores/tw/")

fig <- function(data) {
  d <- prep_data(data)
  tt <- test(d)

  plot <- ggplot(d, aes(cell_line, adj_count))+
    stat_summary(
      fun.data = mean_cl_normal, geom = "errorbar", width = 0.1, linewidth = 0.2
    ) +
    geom_point(stat = "summary", fun = "mean", aes(color = clade)) +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = y, label = stars),
      vjust = 0.3,
      size = 5,
      inherit.aes = FALSE
    ) +
    coord_cartesian(ylim = c(NA, 2000)) +
    labs(y = "Cells/hr", color = "Clade") +
    scale_y_log10() +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_text(hjust = 0, vjust = 0.5, angle = -90)
    )
  ggsave(
    "02_figures/04-a.png", plot,
    width = 3.25, height = 2, units = "in", dpi = 500
  )
}

test <- function(data) {
  t_fun(data) |>
    mutate(stars = starify(p.value)) |>
    select(x, xend, stars) |>
    mutate(
      y = case_when(
        x == 1 & xend == 11 ~ 1500,
        x == 1 & xend == 8 ~ 300,
        x == 5 ~ 700
      ),
      yend = y,
      label_y = if_else(stars == "NS", y, y - 10),
      mid = (x + xend) / 2
    )
}

t_fun <- function(data) {
  lp_v_e <- t.test(adj_count ~ clade, filter(data, clade %in% c("LP", "Ep. Other"))) |>
    tidy() |>
    mutate(x = 1, xend = 11)
  m_v_e <- t.test(adj_count ~ clade, filter(data, clade %in% c("Mes.", "Ep. Other"))) |>
    tidy() |>
    mutate(x = 5, xend = 11)
  lp_v_m <- t.test(adj_count ~ clade, filter(data, clade %in% c("LP", "Mes."))) |>
    tidy() |>
    mutate(x = 1, xend = 8)
  bind_rows(lp_v_e, m_v_e, lp_v_m)
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character %in% c("parental", "new pack", "bryan", "tryple", "trypsin"),
      transwell == "uncoated",
      drug == "dmso",
      loading_number == 100000
    ) |>
    mutate(
      ## Since we're going to take the log, eliminate 0 by adding a pseudocount
      adj_count = (count + 1) / time_hr,
      cell_line = toupper(cell_line)
    ) |>
    mutate(adj_count_mean = mean(adj_count), .by = cell_line) |>
    arrange(clade, adj_count_mean) |>
    mutate(
      cell_line = fct_inorder(cell_line),
      clade = case_when(
        clade == "Luminal Papillary" ~ "LP",
        clade == "Epithelial Other" ~ "Ep. Other",
        clade == "Mesenchymal" ~ "Mes.",
        .default = NA
      )
    )
}

fig(tw)
