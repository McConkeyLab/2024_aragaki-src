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
  plotting_data <- as_tibble(pData(lund)) |>
    select(
      id = geo_accession,
      stage = `tumor_stage:ch1`,
      grade = `tumor_grade:ch1`,
      subtype = `molecular_subtype:ch1`
    )

  src_id <- which(fData(lund)$ILMN_Gene == "SRC")
  plotting_data$src <- exprs(lund)[src_id, ]

  plotting_data |>
    mutate(
      stage = str_remove(stage, "(?<=[0-9])[a-z]$"),
      stage = factor(stage, c("Tx", "Ta", "T1", "T2", "T3", "T4")),
      muscle_invasive = ifelse(stage %in% c("T2", "T3", "T4"), "MI", "NMI") |>
        factor(c("NMI", "MI"))
    ) |>
    filter(stage != "Tx", grade != "Gx")
}

fig_1a <- function(lund) {
  plotting_data <- wrangle_lund(lund)
  tt <- t.test(formula = src ~ muscle_invasive, data = plotting_data)

  tt_data <- data.frame(
    label = starify(tt$p.value),
    x = 1.5,
    y = max(plotting_data$src)
  )

  a <- ggplot(plotting_data, aes(muscle_invasive, src)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.5, size = 0.5,
      aes(color = muscle_invasive)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    theme_minimal() +
    geom_text(data = tt_data, aes(x, y, label = label), size = 5) +
    # View, but not error bar, excludes outlier
    coord_cartesian(ylim = c(-2, NA)) +
    labs(x = NULL, y = "SRC", tag = "A") +
    scale_color_npg() +
    theme(
      legend.position = "none",
      panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
      panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
    )

  ggsave(
    "figure_scripts/01-a.png", a,
    width = 1.2, height = 2.5, units = "in", dpi = 500
  )
  "figure_scripts/01-a.png"
}
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
    mutate(uromol = str_remove(`UROMOL2021 classification`, "Class "))
}

uromol_src <- prep_uromol_src_data()

fig_1b <- function(uromol_src) {
  cl1 <- filter(uromol_src, uromol == "1")
  not_cl1 <- filter(uromol_src, uromol != "1")

  tt <- tapply(not_cl1, ~uromol, \(x) tidy(t.test(x$SRC, cl1$SRC)))

  tt_plotting <- tt |>
    bind_rows() |>
    mutate(uromol = names(tt),
           stars = starify(p.value)) |>
    select(uromol, p.value, stars) |>
    arrange(uromol) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend)/2
    )

  b <- ggplot(uromol_src, aes(uromol, SRC)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.4, size = 0.5,
      aes(color = uromol)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    theme_minimal() +
    labs(x = "UROMOL2021", y = "SRC", tag = "B") +
    geom_segment(
      data = tt_plotting,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt_plotting,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 2.5
    ) +
    theme(
      legend.position = "none",
      panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
      panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
    ) +
    scale_color_npg()

  ggsave(
    "figure_scripts/01-b.png", b,
    width = 1.7, height = 2.7, units = "in", dpi = 500
  )
  "figure_scripts/01-b.png"
}

fig_1b(uromol_src)

fig_1b_extra <- function(uromol_src) {
  long_pd <- uromol_src |>
    select(uromol, SRC, contains("signature")) |>
    pivot_longer(cols = -(uromol:SRC)) |>
    mutate(name = str_remove(name, "[:space:]signature")) |>
    arrange(name)

  prelim_cors <- tapply(long_pd, ~name, \(x) cor.test(x$SRC, x$value)) |>
    lapply(tidy)

  cors <- prelim_cors |>
    bind_rows() |>
    mutate(name = names(prelim_cors)) |>
    arrange(estimate)

  cors_class <- long_pd
  cors_class$subclass <- paste0(cors_class$name, "_", cors_class$uromol)
  prelim_cors_class <- tapply(
    cors_class, ~subclass, \(x) tidy(cor.test(x$SRC, x$value))
  )
  cors_class <- prelim_cors_class |>
    bind_rows() |>
    mutate(name = names(prelim_cors_class)) |>
    select(name, estimate, p.value) |>
    separate(name, c("name", "class"), sep = "_") |>
    mutate(
      star = starify(p.value),
      label = paste0("r: ", round(estimate, 2), " p: ", star)
    ) |>
    arrange(name, class) |>
    mutate(n = seq_len(n()), .by = "name") |>
    mutate(y = -2 * n / 4,
           x = 3.5)

  long_pd$name <- factor(long_pd$name, levels = cors$name)
  cors_class$name <- factor(cors_class$name, levels = levels(long_pd$name))

  pd <- left_join(long_pd, cors_class, by = c("name", uromol = "class"))

  plot <- ggplot(long_pd, aes(SRC, value, color = uromol)) +
    facet_wrap(~name, scales = "free") +
    geom_text(data = arrange(cors_class, name),
              aes(x = x, y = y, label = label, color = class),
              hjust = "inward", size = 3) +
    geom_point(alpha = 0.5, shape = 1, size = 0.2) +
    geom_smooth(method = "lm", se = FALSE) +
    theme_minimal() +
    labs(y = "Signature Score") +
    scale_x_continuous(breaks = c(0, 2.5, 5, 7.5, 10),
                       labels = c("0", "2.5", "5", "7.5", "10")) +
    theme(
      panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
      panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
    ) +
    scale_color_npg()

  ggsave(
    "figure_scripts/01-b_extra.png",
    plot,
    width = 10, height = 8, units = "in", dpi = 500
  )
  "figure_scripts/01-b_extra.png"
}


# C -------------------------------------------
fig_1c <- function(uromol_src) {
  ua <- filter(uromol_src, LundTax == "UroA.Prog")
  not_ua <- filter(uromol_src, LundTax != "UroA.Prog")

  tt <- tapply(not_ua, ~LundTax, \(x) tidy(t.test(x$SRC, ua$SRC)))

  tt_plotting <- tt |>
    bind_rows() |>
    mutate(lund = names(tt),
           stars = starify(p.value)) |>
    select(lund, p.value, stars) |>
    mutate(
      lund = factor(
        lund,
        levels = c("UroA.Prog", "GU", "UroC", "GU.Inf1")
      )
    ) |>
    arrange(lund) |>
    mutate(
      x = 1,
      xend = seq_len(n()) + 1,
      y = c(8.5, 9, 9.5),
      mid = (x + xend) / 2
    )

  uromol_src$LundTax <- factor(
    uromol_src$LundTax,
    levels = c("UroA.Prog", "GU", "UroC", "GU.Inf1"),
    labels = c("UroA\nProg", "GU", "UroC", "GU\nInf1")
  )
  c <- ggplot(uromol_src, aes(LundTax, SRC)) +
    geom_jitter(
      width = 0.2, shape = 1, alpha = 0.5, size = 0.5,
      aes(color = LundTax)
    ) +
    stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
    geom_segment(
      data = tt_plotting,
      aes(x = x, xend = xend, y = y, yend = y),
      inherit.aes = FALSE
    ) +
    geom_text(
      data = tt_plotting,
      aes(x = mid, y = y, label = stars),
      vjust = -0.3,
      inherit.aes = FALSE,
      size = 2.5
    ) +
    theme_minimal() +
    labs(x = "LundTax", y = "SRC", tag = "C") +
    theme(
      legend.position = "none",
      panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
      panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
    ) +
    scale_color_npg()

  ggsave(
    "figure_scripts/01-c.png", c,
    width = 2.2, height = 2.7, units = "in", dpi = 500
  )

}
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
