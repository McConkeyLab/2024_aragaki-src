library(targets)
library(ggsci)
library(tidyverse)
library(broom)
library(DESeq2)
source("R/functions/common.R")
tar_make(script = "R/targets/tw.R", store = "stores/tw/")
tar_make(script = "R/targets/cell_rna.R", store = "stores/cell_rna/")

tw <- tar_read(tw, store = "stores/tw/")
emt <- tar_read(w_emt, store = "stores/cell_rna")

join <- function(tw, emt) {
  cd <- as_tibble(colData(emt))
  cd$cell_line <- tolower(cd$cell)
  left_join(tw, cd, by = c("cell_line", "consensus", "clade"))
}

fig <- function(tw, emt) {
  data <- join(tw, emt)
  d <- prep_data(data)
  r <- test(d)

  plot <- ggplot(d, aes(emt, count, color = consensus)) +
    geom_point() +
    geom_smooth(method = lm, se = FALSE, aes(group = 1), color = "black", linewidth = 0.3) +
    annotate("text", x = min(d$emt), y = max(d$count), label = r, size = 1.7, hjust = 0, vjust = 1) +
    labs(y = "Migrated cells/hr", x = "EMT score", color = "Consensus", tag = "A") +
    scale_y_log10() +
    custom_ggplot +
    theme(
      panel.grid.major.x = element_blank(),
      plot.tag.location = "plot",
      legend.position = "none"
    )
  ggsave(
    "02_figures/cells-mig-emt-cor.svg", plot,
    width = 38, height = 40, units = "mm"
  )
}

test <- function(data) {
  data <- cor.test(data$emt, data$count, method = "spearman") |>
    tidy()
  paste0("Rho = ", round(data$estimate, 2), "\n", format_pval(data$p.value))
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
    mutate(cell_line = fct_inorder(cell_line)) |>
    select(cell_line, adj_count_mean, clade, consensus, emt = Epithelial.Mesenchymal.Transition) |>
    summarize(
      count = mean(adj_count_mean), .by = c(cell_line, clade, consensus, emt)
    )
}
fig(tw, emt)
