get_expression <- function() {
  download.file(
    "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-22465-w/MediaObjects/41467_2021_22465_MOESM5_ESM.zip", # nolint
    paste0(tempdir(), "/data.zip"),
    method = "curl"
  )
  unzip(paste0(tempdir(), "/data.zip"), exdir = tempdir())
  read_excel(paste0(tempdir(), "/Supplementary Data 2.xlsx"))
}

get_clinical <- function() {
  download.file(
    "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-22465-w/MediaObjects/41467_2021_22465_MOESM9_ESM.zip",
    paste0(tempdir(), "/clin.zip")
  )
  unzip(paste0(tempdir(), "/clin.zip"), exdir = tempdir())
  read_excel(paste0(tempdir(), "/Source Data/Source Data.xlsx"), skip = 1)
}

wrangle <- function(expression, clinical) {
  src_index <- which(expression$hgnc == "SRC")
  src <- t(expression[src_index, -(1:2)])
  colnames(src) <- "SRC"
  src <- as_tibble(src, rownames = "id")
  left_join(clinical, src, by = c(`UROMOL ID` = "id")) |>
    mutate(
      uromol = str_remove(`UROMOL2021 classification`, "Class "),
      LundTax = factor(
        LundTax,
        levels = c("UroA.Prog", "GU", "UroC", "GU.Inf1"),
        labels = c("UroA\nProg", "GU", "UroC", "GU\nInf1")
      )
    )
}
