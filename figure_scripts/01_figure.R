library(readxl)
library(targets)
library(tidyverse)
library(Biobase)
library(ggsci)
library(viridis)
library(survival)
library(GEOquery)

starify <- function(pval) {
  if (pval < 0.001) return("***")
  if (pval < 0.01) return("**")
  if (pval < 0.05) return("*")
  "NS"
}
# A ------------------------------------------
lund <- getGEO("GSE32894")[[1]]

plotting_data <- as_tibble(pData(lund)) |>
  select(
    id = geo_accession,
    stage = `tumor_stage:ch1`,
    grade = `tumor_grade:ch1`,
    subtype = `molecular_subtype:ch1`
  )

src_id <- which(fData(lund)$ILMN_Gene == "SRC")
plotting_data$src <- exprs(lund)[src_id, ]

plotting_data <- plotting_data |>
  mutate(
    stage = str_remove(stage, "(?<=[0-9])[a-z]$"),
    stage = factor(stage, c("Tx", "Ta", "T1", "T2", "T3", "T4")),
    muscle_invasive = ifelse(stage %in% c("T2", "T3", "T4"), "MI", "NMI") |>
      factor(c("NMI", "MI"))
  ) |>
  filter(stage != "Tx", grade != "Gx")

tt <- t.test(formula = src ~ muscle_invasive, data = plotting_data)

tt_data <- data.frame(
  label = starify(tt$p.value),
  x = 1.5,
  y = max(plotting_data$src)
)

a <- ggplot(plotting_data, aes(muscle_invasive, src)) +
  geom_jitter(
    width = 0.2, shape = 1, alpha = 0.5, aes(color = muscle_invasive)
  ) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  theme_minimal() +
  geom_text(data = tt_data, aes(x, y, label = label), size = 5) +
  # View, but not error bar, excludes outlier
  coord_cartesian(ylim = c(-2, NA)) +
  labs(x = NULL, y = "SRC") +
  scale_color_npg() +
  theme(legend.position = "none")

ggsave(
  "figure_scripts/01-a.png", a,
  width = 1, height = 2.5, units = "in", dpi = 500
)
# B ---------------------------------
download.file(
  "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-22465-w/MediaObjects/41467_2021_22465_MOESM5_ESM.zip", #nolint
  paste0(tempdir(), "/data.zip"),
  method = "curl"
)
unzip(paste0(tempdir(), "/data.zip"), exdir = tempdir())

data <- read_excel(paste0(tempdir(), "/Supplementary Data 2.xlsx"))

clin <- get_gbci("Datasets/uromol/uromol-2021_clin-dat.xlsx") |>
  read_excel(skip = 1)

src <- data[which(data$hgnc == "SRC"), -(1:2)] |>
  t()
colnames(src) <- "SRC"

src <- as_tibble(src, rownames = "id")

plotting_data <- left_join(clin, src, by = c(`UROMOL ID` = "id")) |>
  mutate(uromol = str_remove(`UROMOL2021 classification`, "Class "))

b <- ggplot(plotting_data, aes(uromol, SRC)) +
  geom_jitter(width = 0.2, shape = 1, alpha = 0.4, aes(color = uromol)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  theme_minimal() +
  labs(x = "UROMOL2021", y = "SRC") +
  theme(legend.position = "none") +
  scale_color_npg()

ggsave(
  "figure_scripts/01-b.png", b,
  width = 1.5, height = 2.5, units = "in", dpi = 500
)


for_cor <- plotting_data |>
  select(SRC, contains("signature"))

long_pd <- plotting_data |>
  select(SRC, contains("signature")) |>
  pivot_longer(cols = -SRC)

ggplot(long_pd, aes(SRC, value)) +
  facet_wrap(~name) +
  geom_point(alpha = 0.1, shape = 1)

# C -------------------------------------------
tt <- plotting_data |>
  filter(LundTax %in% c("UroC", "UroA.Prog"))

c <- ggplot(plotting_data, aes(LundTax, SRC)) +
  geom_jitter(width = 0.2, shape = 1, alpha = 0.5, aes(color = LundTax)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  theme_minimal() +
  labs(x = "LundTax", y = "SRC") +
  theme(legend.position = "none") +
  scale_color_npg()

ggsave(
  "figure_scripts/01-c.png", c,
  width = 2.8, height = 2.5, units = "in", dpi = 500
)
# D --------------

surv <- plotting_data |>
  mutate(rfs = as.numeric(`RFS months (60 months FU)`),
         recur_event = as.numeric(`Recurrence (60 months FU)`),
         pfs = as.numeric(`PFS months (60 months FU)`),
         progress_event = as.numeric(`Progression (60 months FU)`))



coxph(
  Surv(rfs, recur_event) ~ SRC,
  data = surv
)

tapply(surv, ~uromol, \(x) coxph(Surv(rfs, recur_event) ~ SRC, data = x))

tapply(surv, ~uromol, \(x) coxph(Surv(pfs, progress_event) ~ SRC, data = x))
