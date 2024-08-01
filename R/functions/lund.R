wrangle <- function(lund) {
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

