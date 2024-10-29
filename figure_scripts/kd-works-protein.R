library(tidyverse)
library(bladdr)
library(blotbench)
library(magick)

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
