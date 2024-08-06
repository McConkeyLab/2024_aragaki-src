library(targets)
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
    geom_segment(
      data = filter(tt, !is.na(yend_seg)),
      aes(x = mid, xend = mid, y = y, yend = yend_seg),
      inherit.aes = FALSE
    ) +
    geom_segment(
      data = filter(tt, !is.na(xend_top)),
      aes(x = mid, xend = xend_top, y = yend_seg, yend = yend_seg),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = label_x, y = label_y, label = stars),
      vjust = 0.3,
      size = 5,
      inherit.aes = FALSE
    ) +
    coord_cartesian(ylim = c(NA, 3500)) +
    labs(y = "Cells/hr", color = "Clade", tag = "B") +
    scale_y_log10() +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_text(hjust = 0, vjust = 0.5, angle = -90)
    )
  ggsave(
    "02_figures/04-b.png", plot,
    width = 3.5, height = 2, units = "in", dpi = 500
  )
}

test <- function(data) {
  t_fun(data) |>
    mutate(stars = starify(p.value)) |>
    select(group_1, group_2, stars) |>
    right_join(make_test_annotation())
}

make_test_annotation <- function() {
  # LP vs Mes needs two horizontal segments
  #    ___________
  #   |           |
  # ------     ------
  #   LP         Mes
  annot_coords <- tibble(
    group_1 = c("lp", "lp", "lp",   "eo"),
    group_2 = c("eo", "mes", "mes", "mes"),
    x =       c(1,    1,     10,     6),
    xend =    c(9,    5,     15,    15),
    y =       c(50,  1000,  1000,  300),
    yend = y,
    mid = (x + xend) / 2
  )
  v_segs <- tibble(
    group_1 = "lp",
    group_2 = "mes",
    yend_seg = 1500
    # x and xend is mid in annot_coords
    # y is y in annot_coords
  )
  top_seg <- tibble(
    group_1 = "lp",
    group_2 = "mes",
    x = 1,
    # x above used for join
    # real x is mid
    xend_top = (10 + 15) / 2,
  )
  label <- tibble(
    group_1 = c("lp", "lp", "eo"),
    group_2 = c("eo", "mes", "mes"),
    label_x = c(5, 8, 10.5),
    label_y = c(50, 1500, 300)
  )
  left_join(annot_coords, v_segs) |>
    left_join(top_seg) |>
    left_join(label)
}

t_fun <- function(data) {
  lp_v_e <- t.test(adj_count ~ clade, filter(data, clade %in% c("LP", "Ep. Other"))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "eo")
  m_v_e <- t.test(adj_count ~ clade, filter(data, clade %in% c("Mes.", "Ep. Other"))) |>
    tidy() |>
    mutate(group_1 = "eo", group_2 = "mes")
  lp_v_m <- t.test(adj_count ~ clade, filter(data, clade %in% c("LP", "Mes."))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "mes")
  bind_rows(lp_v_e, m_v_e, lp_v_m)
}

prep_data <- function(data) {
  data |>
    filter(
      cell_line_character %in% c("parental", "new pack", "bryan", "tryple", "trypsin"),
      transwell == "matrigel",
      !is.na(count)
    ) |>
    mutate(
      ## Since we're going to take the log, eliminate 0 by adding a pseudocount
      adj_count = (count + 1) * (30000 / loading_number) / time_hr,
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
