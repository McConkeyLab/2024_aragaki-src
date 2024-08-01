library(targets)
library(survival)
tar_make(script = "R/targets/tcga.R", store = "stores/tcga/")

tcga <- tar_read(tcga_plotting_data, store = "stores/tcga/")

tapply(
  tcga, ~ `mRNA cluster`,
  \(x) tidy(coxph(Surv(follow_up_time, death) ~ src, data = x), exponentiate = TRUE)
) |>
  array2DF()
