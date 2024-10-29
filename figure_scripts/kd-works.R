library(mop)
library(bladdr)
library(amplify)
library(tidyverse)
library(ggsci)
library(blotbench)
library(magick)

source("R/functions/common.R")

wrangle <- function() {
  read_pcr("local-data/pcr/2024-04-29_uc6-rt112-nt-004-nodox-dox.xls") |>
    scrub() |>
    filter(
      !is.na(sample_name), target_name %in% c("SRC", "GAPDH")
    ) |>
    separate(sample_name, c("line", "type", "dox", "rep"))
}

min <- d |>
  select(.row, .col, ct, target_name, line, type, dox, rep) |>
  unite(sample_name, type, dox, rep, remove = FALSE)


o <- tapply(min, ~line, \(x) pcr_rq(x, "nt_nodox_1", "GAPDH")) |>
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

o_summary <- o |>
  reframe(
    as_tibble(rownames = "name", Hmisc::smean.cl.normal(rq)),
    .by = c(line, type, dox)
  ) |>
  pivot_wider()


plot <- ggplot(o, aes(dox, rq, color = type)) +
  facet_grid(~line) +
  geom_pointrange(
    data = o_summary,
    aes(y = Mean, ymin = Lower, ymax = Upper),
    position = position_dodge2(width = 0.5),
    fatten = 1.5
  ) +
  scale_y_log10() +
  labs(
    y = "Relative Quantitity",
    color = "",
    tag = "A"
  ) +
  custom_ggplot +
  theme(
    legend.position = "bottom",
    axis.title.x = element_blank(),
    plot.tag.location = "plot",
    legend.spacing.x = unit(0, "lines"),
    legend.margin = margin(b = 1),
    legend.key.size = unit(1, "pt")
  )

ggsave(
  "02_figures/kd-works-pcr.svg", plot,
  width = 38, height = 38, units = "mm"
)

get_convert_read <- function(path) {
  get_gbci(path) |>
    wb_convert_scn(overwrite = TRUE) |>
    image_read()
}

base <- "Raw Data/ChemiDoc/aragaki-kai/2023-08-08_rt112-uc6-nt-004-no-dox-dox/"
files <- c("src-mab.scn", "src-mab-actin.scn")

images <- sapply(paste0(base, files), get_convert_read)

ca <- expand_grid(
  "Cell Line" = c("RT112", "UM-UC6"),
  "Type" = c("NT", "iKD"),
  "Doxycycline" = c("-", "+")
)

ca <- bind_rows(ca[1:4, ], tibble("Cell Line" = "", "Type" = "", "Doxycycline" = ""), ca[5:8, ])

wb <- wb(image_join(images), ca, c("SRC", "Actin"))

transforms(wb) <- tibble::tribble(
  ~width, ~height, ~xpos, ~ypos, ~rotate, ~flip,
  430L, 57L, 182, 194, 1, TRUE,
  423L, 39L, 170, 250, 1, TRUE
)

wb <- apply_transforms(wb)

wb$imgs <- wb$imgs |>
  image_negate() |>
  image_normalize()

png("./02_figures/kd-works-protein.png", width = 3, height = 1, res = 1200, units = "in", pointsize = 8)
wb_present(wb)
dev.off()

wb <- image_read("./02_figures/kd-works-protein.png")
pcr <- image_read("./02_figures/kd-works-pcr.svg", density = 1200) |>
  image_scale(image_info(wb)$width)

image_append(c(pcr, wb), stack = TRUE) |>
  image_write("02_figures/kd-works.svg")
