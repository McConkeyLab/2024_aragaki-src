starify <- function(pval) {
  case_when(pval < 0.001 ~ "***",
            pval < 0.01  ~ "**",
            pval < 0.05  ~ "*",
            .default = "NS")
}

format_pval <- function(pval) {
  ifelse(
    pval > 0.05,
    "NS",
    paste("P =", signif(pval, 1) |> format())
  )
}

custom_ggplot <- list(
  theme_minimal(),
  scale_color_npg(),
  theme(
    panel.grid.major = element_line(linewidth = 0.1, color = "#AAAAAA"),
    panel.grid.minor = element_line(linewidth = 0.1, color = "#AAAAAA")
  )
)
