get_supplemental <- function() {
  download.file(
    "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5687509/bin/NIHMS911030-supplement-8.xlsx", #nolint
    paste0(tempdir(), "/supp.xlsx"),
    method = "curl"
  )
  read_excel(paste0(tempdir(), "/supp.xlsx"), sheet = 2)
}

wrangle <- function(tcga, supplemental) {
  supplemental <- mutate(supplemental, cases.case_id = tolower(`BCR patient uuid`))
  cd <- as_tibble(colData(tcga))
  both <- left_join(cd, supplemental, by = "cases.case_id")
  src_id <- which(rownames(tcga) == "SRC")
  both$src <- assay(tcga, "vst")[src_id, ]

  both |>
    mutate(
      subtype = case_when(
        `mRNA cluster` == "Luminal_papillary" ~ "LP",
        `mRNA cluster` == "Luminal" ~ "L",
        `mRNA cluster` == "Luminal_infiltrated" ~ "LI",
        `mRNA cluster` == "Basal_squamous" ~ "BS",
        `mRNA cluster` == "Neuronal" ~ "N",
        .default = NA
      ),
      subtype = fct_reorder(subtype, src, .desc = TRUE)
    )
}

get_rppa <- function() {
  manifest <- files() |>
    GenomicDataCommons::filter(cases.project.project_id == "TCGA-BLCA") |>
    GenomicDataCommons::filter(type == "protein_expression") |>
    GenomicDataCommons::filter(access == "open") |>
    manifest() |>
    mutate(path = paste(id, file_name, sep = "/"))

  barcodes <- manifest$id |>
    UUIDtoBarcode(from_type = "file_id") |>
    dplyr::rename(submitter_id = associated_entities.entity_submitter_id)

  uuids <- manifest$id |>
    UUIDtoUUID(to_type = "case_id")

  joined_ids <- full_join(barcodes, uuids, by = "file_id")

  manifest <- manifest |>
    full_join(joined_ids, by = c("id" = "file_id")) |>
    rename(submitter_id = submitter_id.y) |>
    mutate(short_id = str_sub(submitter_id, 1, 12)) |>
    filter(str_detect(submitter_id, "^TCGA-[[:alnum:]]{2}-[[:alnum:]]{4}-0")) |>
    arrange(submitter_id) |>
    distinct(short_id, .keep_all = TRUE) |>
    get_data_from_man()


  gdc_set_cache("01_data/00_gdcdata", create_without_asking = TRUE)
  data <- apply(manifest, 1, read_rppa)
  Reduce(\(x, y) left_join(x, y, by = c("AGID", "peptide")), data)
}

read_rppa <- function(man) {
  path <- paste0("01_data/00_gdcdata/", man["path"])
  id <- man["short_id"]
  cat(".\n")
  out <- read_tsv(path, show_col_types = FALSE) |>
    select(AGID, peptide_target, protein_expression)
  colnames(out) <- c("AGID", "peptide", id)
  out
}

get_data_from_man <- function(manifest) {
  manifest <- manifest |>
    select(id, path, submitter_id, short_id, cases.case_id)
  write_tsv(manifest, file = paste0(tempdir(), "/temp.txt"))
  system2(
    "gdc-client",
    c("download",
      "-m", paste0(tempdir(), "/temp.txt"),
      "-d", "01_data/00_gdcdata/")
  )
  manifest
}

wrangle_rppa <- function(plotting_data, rppa) {
  pd <- select(plotting_data, short_id, src, subtype)
  long <- pivot_longer(rppa, -(AGID:peptide))
  left_join(long, pd, by = c(name = "short_id")) |>
    filter(str_detect(peptide, "SRC"), !is.na(subtype))
}
