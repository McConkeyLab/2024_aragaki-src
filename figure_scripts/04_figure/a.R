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
    geom_pointrange(data = summary, aes(y = Mean, ymin = Lower, ymax = Upper, color = consensus)) +
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
      vjust = -0.3,
      size = 3,
      inherit.aes = FALSE
    ) +
    coord_cartesian(ylim = c(NA, 1000), clip = "off") +
    labs(y = "Cells/hr", color = "Consensus", tag = "A") +
    scale_y_log10() +
    custom_ggplot +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_text(hjust = 0, vjust = 0.5, angle = -90),
      panel.grid.major.x = element_blank(),
      plot.margin = unit(c(2.5, 0, 0, 0), "lines"),
      plot.tag.position = c(0, 1.25),
      plot.tag = element_text(hjust = 0)
    )
  ggsave(
    "02_figures/04-a.png", plot,
    width = 3.25, height = 2, units = "in", dpi = 500
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
    x =       c(1,    1,     13,     8),
    xend =    c(12,   7,     14,    14),
    y =       c(1000, 10000, 10000, 3000),
    yend = y,
    mid = (x + xend) / 2
  )
  v_segs <- tibble(
    group_1 = "lp",
    group_2 = "mes",
    yend_seg = 20000
    # x and xend is mid in annot_coords
    # y is y in annot_coords
  )
  top_seg <- tibble(
    group_1 = "lp",
    group_2 = "mes",
    x = 1,
    # x above used for join
    # real x is mid
    xend_top = (13 + 14) / 2,
  )
  label <- tibble(
    group_1 = c("lp", "lp", "eo"),
    group_2 = c("eo", "mes", "mes"),
    label_x = c(6.5, 8.5, 11),
    label_y = c(1000, 20000, 3000)
  )
  left_join(annot_coords, v_segs) |>
    left_join(top_seg) |>
    left_join(label)
}

t_fun <- function(data) {
  lp_v_e <- t.test(Mean ~ consensus, filter(data, consensus %in% c("LP", "BS"))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "eo")
  m_v_e <- t.test(Mean ~ consensus, filter(data, consensus %in% c("NE", "BS"))) |>
    tidy() |>
    mutate(group_1 = "eo", group_2 = "mes")
  lp_v_m <- t.test(Mean ~ consensus, filter(data, consensus %in% c("LP", "NE"))) |>
    tidy() |>
    mutate(group_1 = "lp", group_2 = "mes")
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
    arrange(consensus, adj_count_mean) |>
    mutate(cell_line = fct_inorder(cell_line))
}

summarize_data <- function(data) {
  data |>
    reframe(
      as_tibble(rownames = "name", Hmisc::smean.cl.normal(adj_count)),
      .by = c(cell_line, consensus)
    ) |>
    mutate(value = ifelse(value <= 0, 1, value)) |>
    pivot_wider()
}

fig(tw)
