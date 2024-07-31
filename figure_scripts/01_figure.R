library(broom)
library(readxl)
library(targets)
library(tidyverse)
library(Biobase)
library(ggsci)
library(viridis)
library(survival)
library(GEOquery)
library(bladdr)

starify <- function(pval) {
  case_when(pval < 0.001 ~ "***",
            pval < 0.01  ~ "**",
            pval < 0.05  ~ "*",
            .default = "NS")
}

custom_ggplot <- list(
  theme_minimal(),
  scale_color_npg(),
  theme(
    panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
    panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
  )
)
# A ------------------------------------------
# Takes a bit longer, uses network -
# good to cache the results
get_lund <- function() {
  getGEO("GSE32894")[[1]]
}

lund <- get_lund()

# Converts to plotting data - whatever that may be
# Abstract wrangling from plotting
wrangle_lund <- function(lund) {
  pheno <- lund |>
    pData() |>
    as_tibble() |>
    select(
      id = geo_accession,
      stage = `tumor_stage:ch1`,
      grade = `tumor_grade:ch1`,
      subtype = `molecular_subtype:ch1`
    )

  src_index <- which(fData(lund)$ILMN_Gene == "SRC")

  plotting_data <- cbind(pheno, src = exprs(lund)[src_index, ])

  plotting_data |>
    mutate(
      # Reduce stage granularity (T2a -> T2)
      stage = str_remove(stage, "(?<=[0-9])[a-z]$"),
      stage = factor(stage, c("Tx", "Ta", "T1", "T2", "T3", "T4")),
      muscle_invasive = ifelse(stage %in% c("T2", "T3", "T4"), "MI", "NMI"),
      muscle_invasive = factor(muscle_invasive, c("NMI", "MI"))
    ) |>
    filter(stage != "Tx", grade != "Gx")
}

# Takes wrangled data, performs tests, and presents them in a plot-ready form
test_fig_1a <- function(data) {
  tt <- t.test(formula = src ~ muscle_invasive, data = data)
  data.frame(label = starify(tt$p.value), x = 1.5, y = max(data$src))
}

fig_1a <- function(lund) {
  plotting_data <- wrangle_lund(lund)
  tt <- test_fig_1a(plotting_data)
  a <- ggplot(plotting_data, aes(muscle_invasive, src)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.5, size = 0.5,
      aes(color = muscle_invasive)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    geom_text(data = tt, aes(x, y, label = label), size = 5) +
    # View, but not error bar, excludes outlier
    coord_cartesian(ylim = c(-2, NA)) +
    labs(x = NULL, y = "SRC", tag = "A") +
    custom_ggplot +
    theme(legend.position = "none")

  ggsave(
    "figure_scripts/01-a.png", a,
    width = 1.2, height = 2.5, units = "in", dpi = 500
  )
  "figure_scripts/01-a.png"
}
fig_1a(lund)
# B ---------------------------------

# Downloads UROMOL RNA expression data and clinical data,
# extracts only SRC expression and joins it to clinical data
prep_uromol_src_data <- function() {
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

  left_join(clin, src, by = c(`UROMOL ID` = "id")) |>
    mutate(
      uromol = str_remove(`UROMOL2021 classification`, "Class "),
      LundTax = factor(
        LundTax,
        levels = c("UroA.Prog", "GU", "UroC", "GU.Inf1"),
        labels = c("UroA\nProg", "GU", "UroC", "GU\nInf1")
      )
    )
}

uromol_src <- prep_uromol_src_data()

# Compare class 1 expression to all others
test_fig_1b <- function(data) {
  cl1 <- filter(data, uromol == "1")
  not_cl1 <- filter(data, uromol != "1")

  tapply(not_cl1, ~uromol, \(x) tidy(t.test(x$SRC, cl1$SRC))) |>
    array2DF() |>
    mutate(stars = starify(p.value)) |>
    select(uromol, p.value, stars) |>
    arrange(uromol) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend) / 2
    )
}

fig_1b <- function(uromol_src) {
  tt <- test_fig_1b(uromol_src)
  plot <- ggplot(uromol_src, aes(uromol, SRC)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.4, size = 0.5,
      aes(color = uromol)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    labs(x = "UROMOL2021", y = "SRC", tag = "B") +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 2.5
    ) +
    custom_ggplot() +
    theme(legend.position = "none")

  ggsave(
    "figure_scripts/01-b.png", plot,
    width = 1.7, height = 2.7, units = "in", dpi = 500
  )
  "figure_scripts/01-b.png"
}

fig_1b(uromol_src)

fig_1b_extra_wrangle <- function(data) {
  data |>
    select(uromol, SRC, contains("signature")) |>
    pivot_longer(cols = -(uromol:SRC)) |>
    mutate(name = str_remove(name, "[:space:]signature")) |>
    arrange(name)
}

# Calculate correlation between SRC expression and signature values, stratified
# by uromol class
fig_1b_extra_test <- function(data) {
  data$name_uromol <- paste0(data$name, "_", data$uromol)
  tapply(
    data, ~name_uromol, \(x) tidy(cor.test(x$SRC, x$value))
  ) |>
    array2DF() |>
    select(name_uromol, estimate, p.value) |>
    separate(name_uromol, c("name", "uromol"), sep = "_") |>
    mutate(
      star = starify(p.value),
      label = paste0("r: ", round(estimate, 2), " p: ", star)
    ) |>
    mutate(mean_cor = mean(estimate), .by = "name") |>
    arrange(mean_cor) |>
    mutate(name = fct_inorder(name)) |>
    mutate(y = c(-3, -3, -4, -4), x = c(3.5, 7, 3.5, 7), .by = "name")
}

fig_1b_extra_data <- fig_1b_extra_wrangle(uromol_src)

fig_1b_extra <- function(uromol_src) {
  cors <- fig_1b_extra_test(uromol_src)

  # To harmonize ordering
  uromol_src$name <- factor(uromol_src$name, levels = levels(cors$name))

  plot <- ggplot(uromol_src, aes(SRC, value, color = uromol)) +
    facet_wrap(~name) +
    geom_text(data = arrange(cors, name),
              aes(x = x, y = y, label = label, color = uromol),
              hjust = 0, size = 3) +
    geom_point(alpha = 0.5, shape = 1, size = 0.2) +
    geom_smooth(method = "lm", se = FALSE, linewidth = 0.5) +
    labs(y = "Signature Score") +
    scale_x_continuous(breaks = c(0, 2.5, 5, 7.5, 10),
                       labels = c("0", "2.5", "5", "7.5", "10")) +
    custom_ggplot

  ggsave(
    "figure_scripts/01-b_extra.png",
    plot,
    width = 10, height = 8, units = "in", dpi = 500
  )
  "figure_scripts/01-b_extra.png"
}

fig_1b_extra(uromol_src)

# C -------------------------------------------
fig_1c_test <- function(data) {
  ua <- filter(data, LundTax == "UroA\nProg")
  not_ua <- filter(data, LundTax != "UroA\nProg")

  tapply(not_ua, ~LundTax, \(x) tidy(t.test(x$SRC, ua$SRC))) |>
    array2DF() |>
    mutate(stars = starify(p.value)) |>
    select(LundTax, p.value, stars) |>
    mutate(
      LundTax = factor(
        LundTax,
        levels = c("UroA\nProg", "GU", "UroC", "GU\nInf1")
      )
    ) |>
    arrange(LundTax) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend) / 2
    )
}

fig_1c <- function(uromol_src) {
  tt <- fig_1c_test(uromol_src)
  plot <- ggplot(uromol_src, aes(LundTax, SRC)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.5, size = 0.5,
      aes(color = LundTax)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    geom_segment(
      data = tt,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 2.5
    ) +
    labs(x = "LundTax", y = "SRC", tag = "C") +
    custom_ggplot +
    theme(legend.position = "none")

  ggsave(
    "figure_scripts/01-c.png", plot,
    width = 2.2, height = 2.7, units = "in", dpi = 500
  )
  "figure_scripts/01-c.png"
}
fig_1c(uromol_src)
# D --------------

surv <- uromol_src |>
  mutate(rfs = as.numeric(`RFS months (60 months FU)`),
         recur_event = as.numeric(`Recurrence (60 months FU)`),
         pfs = as.numeric(`PFS months (60 months FU)`),
         progress_event = as.numeric(`Progression (60 months FU)`))



coxph(
  Surv(rfs, recur_event) ~ SRC,
  data = surv
)

tapply(surv, ~uromol, \(x) tidy(coxph(Surv(rfs, recur_event) ~ SRC, data = x), exponentiate = TRUE))

tapply(surv, ~uromol, \(x) tidy(coxph(Surv(pfs, progress_event) ~ SRC, data = x), exponentiate = TRUE))
