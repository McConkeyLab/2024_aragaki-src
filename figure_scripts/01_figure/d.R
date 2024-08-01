library(targets)
library(tidyverse)
library(survival)
library(broom)

source("R/functions/common.R")
tar_make(script = "R/targets/uromol.R", store = "stores/uromol/")

uromol <- tar_read(uromol_plotting_data, store = "stores/uromol/")

surv <- uromol |>
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
