wrangle_tw_ka <- function(cell_rna) {
  get_tw_ka() |>
    tidy_tw_ka(cell_rna)
}

get_tw_ka <- function() {
  get_gbci(
    "Projects and Manuscripts/aragaki-kai/01_masterlists/aragaki_transwell_master.xlsx" #nolint
  ) |>
    read_excel()
}

tidy_tw_ka <- function(tw, cell_rna) {

  clade_data <- cell_rna |>
    colData() |>
    as_tibble() |>
    select(cell, consensus, clade) |>
    mutate(cell = tolower(cell))

  tw |>
    filter(is.na(omit_reason), !is.na(count)) |>
    left_join(clade_data, by = c(cell_line = "cell")) |>
    group_by(
      date, cell_line, cell_line_character, loading_number, transwell,
      drug, concentration_uM, time_hr, clade, consensus
    ) |>
    summarize(count = mean(count, na.rm = TRUE)) |>
    ungroup() |>
    mutate(
      drug = fct_relevel(drug, "dmso"),
      operator = "ka"
    )
}

wrangle_tw_bw <- function(cell_rna) {
  get_tw_bw() |>
    tidy_tw_bw(cell_rna)
}

get_tw_bw <- function() {
  get_gbci(
    "Projects and Manuscripts/wehrenberg-bryan/Masterlists/wehrenberg_transwell_master.xlsx"
  ) |>
    read_excel(na = "NA")
}

tidy_tw_bw <- function(tw, cell_rna) {

  clade_data <- cell_rna |>
    colData() |>
    as_tibble() |>
    select(cell, consensus, clade) |>
    mutate(cell = tolower(cell))

  tw |>
    filter(is.na(omit_reason), !is.na(count)) |>
    filter(cell_line != "uc9") |> # These UC9s might be UC6s
    left_join(clade_data, by = c(cell_line = "cell")) |>
    group_by(
      date, cell_line, cell_line_character, loading_number, transwell,
      drug, concentration_uM, time_hr, clade, consensus
    ) |>
    summarize(count = mean(count, na.rm = TRUE)) |>
    ungroup() |>
    mutate(
      loading_number = ifelse(loading_number == "unknown", 1e5, loading_number) |>
        as.numeric(),
      drug = ifelse(drug == "azd0530", "saracatinib", drug),
      drug = fct_relevel(drug, "dmso"),
      operator = "bw"
    )
}
