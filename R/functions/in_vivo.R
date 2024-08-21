library(bladdr)
library(ggsci)
library(survival)
library(tidyverse)
library(ggsurvfit)
library(broom)

source("R/functions/common.R")
tvi <- read_csv("01_data/01_in-vivo/survival.csv")

md <- distinct(tvi, id, .keep_all = TRUE) |>
  mutate(
    injection_date = if_else(cell_line == "UC6", as.Date("2023-11-10"), as.Date("2024-02-28")),
    days_to_death = death_date - injection_date
  ) |>
  filter(type == "iKD")

uc6 <- filter(md, cell_line == "UC6")
rt112 <- filter(md, cell_line == "RT112")

fit <- survfit2(Surv(days_to_death, event) ~ cell_line + dox, data = md) |>
  tidy_survfit() |>
  separate(strata, c("cell_line", "dox"), sep = ", ")

tt <- tapply(
  md,
  ~ cell_line,
  \(x) glance(survdiff(Surv(days_to_death, event) ~ dox, data = x))
) |>
  array2DF() |>
  as_tibble() |>
  mutate(
    label = paste0("p = ", signif(p.value, 2))
  )

ggplot(fit, aes(time, estimate, color = dox)) +
  facet_grid(~cell_line) +
  geom_step() +
  custom_ggplot +
  theme(legend.position = "top") +
  geom_text(data = tt, aes(x = 0, y = 0, label = label), color = "black", hjust = 0, vjust = 0) +
  labs(y = "OS", x = "Time (days)", color = "SRC KD")
