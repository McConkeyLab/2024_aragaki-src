wrangle_tw <- function() {
  get_tw() |>
    tidy_tw()
}

get_tw <- function() {
  get_gbci(
    "Projects and Manuscripts/aragaki-kai/01_masterlists/aragaki_transwell_master.xlsx" #nolint
  ) |>
    read_excel()
}

tidy_tw <- function(tw) {

  src_exp <- cell_rna[rownames(cell_rna) == "SRC", ] |> assay(2)

  clade_data <- cell_rna |>
    colData() |>
    as_tibble() |>
    select(cell, clade) |>
    mutate(
      cell = tolower(cell),
      src = src_exp
    )

  tw |>
    filter(is.na(omit_reason)) |>
    left_join(clade_data, by = c(cell_line = "cell")) |>
    group_by(
      date, cell_line, cell_line_character, loading_number, transwell,
      transwell_character, drug, concentration_uM, time_hr
    ) |>
    mutate(exp_mean = mean(count, na.rm = TRUE)) |>
    ungroup() |>
    mutate(drug = fct_relevel(drug, "dmso"))
}
