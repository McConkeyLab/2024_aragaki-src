library(bladdr)
library(gplate)
library(tidyverse)
library(mop)

get_all_data <- function() {
  c("2024-03-27_uc6-nt-004-no-dox-dr-dox.txt",
    "2024-03-31_uc6-nt-004-dr-dox.txt",
    "2024-04-01_uc6-nt-004-dr-bos-dox.txt",
    "2024-04-02_uc6-nt-004-dr-bos.txt",
    "2024-04-02_rt112-nt-004-dr-bos-dox.txt",
    "2024-04-01_rt112-nt-004-dr-bos-dox.txt",
    "2024-04-03_rt112-nt-004-bos-dox-dr.txt",
    "2024-04-04_uc6-nt-004-bos-dr.txt") |>
    lapply(get_data)
}

get_data <- function(path) {
  path <- paste0("MTT/", path)
  get_spectramax(path, user_name = "aragaki-kai") |>
    read_spectramax() |>
    plate_data() |>
    gp_serve()
}

tidy <- function(data_list) {
  # Plate layout specification
  spec_1 <- make_base_plate("UC6", "dox") |>
    gp_sec(
      "conc", ncol = 1, nrow = 4, wrap = TRUE,
      labels = c(rep(0, 12), rep(c(0, 10^(0:4)), 2)),
      advance = FALSE
    )

  spec_2 <- make_base_plate("UC6", "dox") |>
    gp_sec("conc", ncol = 1, labels = c(0, 10^(0:4)), advance = FALSE)

  spec_3 <- make_base_plate("UC6", c("bos", "dox")) |>
    gp_sec("conc", ncol = 1, labels = c(0, 10^(0:4)), advance = FALSE)

  spec_4 <- make_base_plate("UC6", "bos") |>
    gp_sec("conc", ncol = 1, labels = c(0, 10^(0:4)), advance = FALSE)

  spec_5 <- make_base_plate("RT112", c("bos", "dox")) |>
    gp_sec("conc", ncol = 1, labels = c(0, 10^(0:4)), advance = FALSE)

  spec_6 <- spec_5
  spec_7 <- spec_5

  spec_8 <- make_base_plate("UC6", "bos") |>
    gp_sec("conc", ncol = 1, labels = c(0, 10^(0:4)), advance = FALSE)

  specs <- list(
    spec_1, spec_2, spec_3, spec_4, spec_5, spec_6, spec_7, spec_8
  ) |>
    lapply(gp_serve)

  add_rep_and_data <- function(spec, rep, data) {
    spec$rep <- rep
    spec
    left_join(spec, data, by = c(".row", ".col"))
  }

  specs_with_rep <- mapply(
    add_rep_and_data, spec = specs, data = data_list, rep = c(1:8), SIMPLIFY = FALSE
  )

  bind_rows(specs_with_rep) |>
    mutate(
      diff = nm562 - nm660,
      conc = as.numeric(as.character(conc))
    ) |>
    mutate(
      diff_mean = mean(diff),
      .by = c(conc, type, rep, cell_line, drug)
    ) |>
    mutate(
      div = diff / diff_mean[which(conc == min(conc))[1]],
      .by = c(type, rep, cell_line, drug)
    ) |>
    mutate(conc = ifelse(conc == 0, 0.1, conc)) |>
    summarize(div = mean(div), .by = c(type, rep, cell_line, drug, conc)) |>
    mutate(drug = factor(drug, c("dox", "bos"), c("Doxycycline", "Bosutinib")))
}

make_base_plate <- function(cell_line, drugs) {
  drug_nrow <- ifelse(length(drugs) > 1, 4, 8)
  drug_advance <- !length(drugs) > 1
  gp(wells = 96) |>
    gp_sec("cell_line", labels = cell_line) |>
    gp_sec("type", ncol = 6, labels = c("NT", "004")) |>
    gp_sec("drug", nrow = drug_nrow, labels = drugs, advance = drug_advance)
}
