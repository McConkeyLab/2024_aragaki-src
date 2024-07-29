# This script requires running the general_tcga submodule
library(ggsurvfit)
library(DESeq2)
library(tidyverse)
library(survival)
library(readxl)

tcga <- readRDS("general_tcga/01_data/blca/dds.rds")

download.file(
  "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5687509/bin/NIHMS911030-supplement-8.xlsx", #nolint
  paste0(tempdir(), "/supp.xlsx"),
  method = "curl"
)

supp <- read_excel(paste0(tempdir(), "/supp.xlsx"), sheet = 2) |>
  mutate(cases.case_id = tolower(`BCR patient uuid`))
cd <- colData(tcga) |>
  as_tibble()

both <- left_join(cd, supp, by = "cases.case_id")

src_id <- which(rownames(tcga) == "SRC")
both$src <- assay(tcga, "vst")[src_id, ]

both <- both |>
  mutate(exceeds_group_mean = src > mean(src), .by = "mRNA cluster") |>
  mutate(cluster = `mRNA cluster`)

fit <- survfit2(Surv(follow_up_time, death) ~ exceeds_group_mean + cluster, data = both) |>
  tidy_survfit() |>
  mutate(above_mean = str_detect(strata, "TRUE"),
         subtype = str_extract(strata, "(?<=, ).*"))

ggplot(fit, aes(time, estimate, color = subtype, linetype = above_mean)) +
  geom_step() +
  facet_wrap(~subtype, ncol = 1) +
  coord_cartesian(xlim = c(0, 5 * 365)) +
  theme_minimal() +
  scale_color_npg() +
  guides(linetype = guide_legend(nrow = 2), color = "none") +
  theme(legend.position = "top") +
  labs(linetype = "SRC > group mean", x = "Days", y = "OS")

ggplot(both, aes(`mRNA cluster`, src)) +
  geom_jitter(width = 0.2, shape = 1, alpha = 0.5)

tapply(both, ~ `mRNA cluster`, \(x) coxph(Surv(follow_up_time, death) ~ src, data = x)) |>
  lapply(tidy, exponentiate = TRUE) |>
  bind_rows(.id = "subtype")

lp <- filter(both, `mRNA cluster` == "Luminal_papillary")
not_lp <- filter(both, `mRNA cluster` != "Luminal_papillary")

tapply(not_lp, ~ `mRNA cluster`, \(x) t.test(lp$src, x$src))
