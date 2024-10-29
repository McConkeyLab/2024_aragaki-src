library(targets)
library(ggsci)
library(tidyverse)
library(broom)
source("R/functions/common.R")
tar_make(script = "R/targets/tw.R", store = "stores/tw/")

tw <- tar_read(tw, store = "stores/tw/")

fig <- function(data) {
  d <- prep_data(data)
  summary <- summarize_data(d)
  tt <- test(summary)

  plot <- ggplot(d, aes(cell_line, adj_count)) +
    geom_pointrange(data = summary, aes(y = Mean, ymin = Lower, ymax = Upper, color = consensus), fatten = 1.5) +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      lineend = "square",
      inherit.aes = FALSE
    ) +
    geom_segment(
      data = filter(tt, !is.na(yend_seg)),
      aes(x = mid, xend = mid, y = y, yend = yend_seg),
      lineend = "square",
      inherit.aes = FALSE
    ) +
    geom_segment(
      data = filter(tt, !is.na(xend_top)),
      aes(x = mid, xend = xend_top, y = yend_seg, yend = yend_seg),
      lineend = "square",
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = label_x, y = label_y, label = stars),
      vjust = -0.2,
      size = 1.7,
      inherit.aes = FALSE
    ) +
    coord_cartesian(ylim = c(0.1, 500), clip = "off") +
    labs(y = "Invaded cells/hr", color = "Consensus", tag = "D") +
    scale_y_log10() +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_text(hjust = 0, vjust = 0.5, angle = -90),
      panel.grid.major.x = element_blank(),
      plot.margin = unit(c(2.2, 0, 0, 0), "lines"),
      plot.tag.position = c(0, 1.25),
      plot.tag = element_text(hjust = 0),
      legend.position = "bottom",
      legend.spacing.x = unit(0, "lines"),
      legend.margin = margin(b = 1),
      legend.key.size = unit(1, "pt")
    ) +
    guides(color = guide_legend(title = NULL))
  ggsave(
    "02_figures/cells-inv.svg", plot,
    width = 47, height = 50, units = "mm"
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
    group_1 = c("lp", "lp", "lp", "bs"),
    group_2 = c("bs", "ne", "ne", "ne"),
    x = c(1, 1, 18, 10),
    xend = c(17, 9, 19, 19),
    y = c(500, 10000, 10000, 2500),
    yend = y,
    mid = (x + xend) / 2
  )
  v_segs <- tibble(
    group_1 = "lp",
    group_2 = "ne",
    yend_seg = 20000
    # x and xend is mid in annot_coords
    # y is y in annot_coords
  )
  top_seg <- tibble(
    group_1 = "lp",
    group_2 = "ne",
    x = 1,
    # x above used for join
    # real x is mid
    xend_top = (18 + 19) / 2,
  )
  label <- tibble(
    group_1 = c("lp", "lp", "bs"),
    group_2 = c("bs", "ne", "ne"),
    label_x = c(9, (5 + 18.5) / 2, 14.5),
    label_y = c(500, 20000, 2500)
  )
  left_join(annot_coords, v_segs) |>
    left_join(top_seg) |>
    left_join(label)
}

t_fun <- function(data) {
  lp_v_e <- t.test(Mean ~ consensus, filter(data, consensus %in% c("LP", "BS"))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "bs")
  m_v_e <- t.test(Mean ~ consensus, filter(data, consensus %in% c("NE", "BS"))) |>
    tidy() |>
    mutate(group_1 = "bs", group_2 = "ne")
  lp_v_m <- t.test(Mean ~ consensus, filter(data, consensus %in% c("LP", "NE"))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "ne")
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
    arrange(consensus, adj_count_mean) |>
    mutate(cell_line = fct_inorder(cell_line))
}

summarize_data <- function(data) {
  data |>
    reframe(
      as_tibble(rownames = "name", Hmisc::smean.cl.normal(adj_count)),
      .by = c(cell_line, consensus)
    ) |>
    mutate(value = ifelse(value <= 0.1, 0.1, value)) |>
    pivot_wider()
}

fig(tw)
