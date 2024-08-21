library(ggsci)
library(tidyverse)
library(bladdr)
library(readxl)

source("R/functions/common.R")

mets <- get_gbci("Raw Data/mouse-measurements/hayashi-yujiro/tail-vein.xlsx") |>
  read_excel()

mets <- mets |>
  mutate(
    cell_line = "UC6",
    type = ifelse(str_detect(line, "NT"), "NT", "KD"),
    dox = str_detect(line, "_D$")
  )

mets_summary <- mets |>
  reframe(
    as_tibble(rownames = "name", Hmisc::smean.cl.normal(mets_to_lung_ratio)),
    .by = c(line, dox, type, cell_line)
  ) |>
  mutate(value = ifelse(value < 0.0001, 0.0001, value)) |>
  pivot_wider()

ggplot(mets, aes(dox, mets_to_lung_ratio + 0.0001, color = dox)) +
  facet_grid(~type) +
  scale_y_log10() +
  geom_jitter(width = 0.1, height = 0, alpha = 0.5, shape = 16) +
  geom_pointrange(data = mets_summary, aes(y = Mean, ymin = Lower, ymax = Upper)) +
  custom_ggplot
