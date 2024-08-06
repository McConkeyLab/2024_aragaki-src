wrangle_tw_ka <- function() {
  get_tw_ka() |>
    tidy_tw_ka()
}

get_tw_ka <- function() {
  get_gbci(
    "Projects and Manuscripts/aragaki-kai/01_masterlists/aragaki_transwell_master.xlsx" #nolint
  ) |>
    read_excel()
}

tidy_tw_ka <- function(tw) {

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

wrangle_tw_bw <- function() {
  get_tw_bw() |>
    tidy_tw_bw()
}

get_tw_bw <- function() {
  get_gbci(
    "Projects and Manuscripts/wehrenberg-bryan/Masterlists/wehrenberg_transwell_master.xlsx"
  ) |>
    read_excel(na = "NA")
}

tidy_tw_bw <- function(tw) {
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
