# This script requires running the general_tcga submodule
library(ggsurvfit)
library(DESeq2)
library(tidyverse)
library(survival)
library(readxl)
library(ggsci)
library(broom)

tcga <- readRDS("general_tcga/01_data/blca/dds.rds")

download.file(
  "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5687509/bin/NIHMS911030-supplement-8.xlsx", #nolint
  paste0(tempdir(), "/supp.xlsx"),
  method = "curl"
)

supp <- read_excel(paste0(tempdir(), "/supp.xlsx"), sheet = 2) |>
  mutate(cases.case_id = tolower(`BCR patient uuid`))
cd <- colData(tcga) |>
  as_tibble()

both <- left_join(cd, supp, by = "cases.case_id")

src_id <- which(rownames(tcga) == "SRC")
both$src <- assay(tcga, "vst")[src_id, ]

both <- both |>
  mutate(exceeds_group_mean = src > mean(src), .by = "mRNA cluster") |>
  mutate(cluster = `mRNA cluster`)

fit <- survfit2(Surv(follow_up_time, death) ~ exceeds_group_mean + cluster, data = both) |>
  tidy_survfit() |>
  mutate(above_mean = str_detect(strata, "TRUE"),
         subtype = str_extract(strata, "(?<=, ).*"))

ggplot(fit, aes(time, estimate, color = subtype, linetype = above_mean)) +
  geom_step() +
  facet_wrap(~subtype, ncol = 1) +
  coord_cartesian(xlim = c(0, 5 * 365)) +
  theme_minimal() +
  scale_color_npg() +
  guides(linetype = guide_legend(nrow = 2), color = "none") +
  theme(legend.position = "top") +
  labs(linetype = "SRC > group mean", x = "Days", y = "OS")

ggplot(both, aes(`mRNA cluster`, src)) +
  geom_jitter(width = 0.2, shape = 1, alpha = 0.5)

tapply(both, ~ `mRNA cluster`, \(x) coxph(Surv(follow_up_time, death) ~ src, data = x)) |>
  lapply(tidy, exponentiate = TRUE) |>
  bind_rows(.id = "subtype")

lp <- filter(both, `mRNA cluster` == "Luminal_papillary")
not_lp <- filter(both, `mRNA cluster` != "Luminal_papillary")

tapply(not_lp, ~ `mRNA cluster`, \(x) t.test(lp$src, x$src))

get_rppa <- function() {
  manifest <- files() |>
    GenomicDataCommons::filter(cases.project.project_id == "TCGA-BLCA") |>
    GenomicDataCommons::filter(type == "protein_expression") |>
    GenomicDataCommons::filter(access == "open") |>
    manifest() |>
    # Creates a 'path' feature that DESeq uses for its sampleTable argument
    mutate(path = paste(id, file_name, sep = "/"))

  barcodes <- manifest$id |>
    UUIDtoBarcode(from_type = "file_id") |>
    dplyr::rename(submitter_id = associated_entities.entity_submitter_id)

  uuids <- manifest$id |>
    UUIDtoUUID(to_type = "case_id")

  joined_ids <- full_join(barcodes, uuids, by = "file_id")

  manifest <- manifest |>
    full_join(joined_ids, by = c("id" = "file_id")) |>
    dplyr::rename(submitter_id = submitter_id.y) |>
    mutate(short_id = str_sub(submitter_id, 1, 12)) |>
    dplyr::filter(str_detect(submitter_id, "^TCGA-[[:alnum:]]{2}-[[:alnum:]]{4}-0")) |>
    arrange(submitter_id) |>
    distinct(short_id, .keep_all = TRUE)

  get_data <- function(manifest) {
    manifest <- manifest |>
      dplyr::select(id, path, submitter_id, short_id, cases.case_id)
    write_tsv(manifest, file = paste0(tempdir(), "/temp.txt"))
    system2(
      "gdc-client",
      c("download",
        "-m", paste0(tempdir(), "/temp.txt"),
        "-d", "./01_data/00_gdcdata/")
    )
    manifest
  }

  manifest <- get_data(manifest)


  read_data <- function(man) {
    path <- paste0("./01_data/00_gdcdata/", man["path"])
    id <- man["short_id"]
    cat(".\n")
    out <- read_tsv(path, show_col_types = FALSE) |>
      select(AGID, peptide_target, protein_expression)
    colnames(out) <- c("AGID", "peptide", id)
    out
  }

  gdc_set_cache("./01_data/00_gdcdata", create_without_asking = T)
  data <- apply(man, 1, read_data)
  Reduce(\(x, y) left_join(x, y, by = c("AGID", "peptide")), data)
}

joined <- get_rppa()

both_sel <- select(both, short_id, src, subtype = `mRNA cluster`)

long <- pivot_longer(joined, -(AGID:peptide))

all <- left_join(long, both_sel, by = c(name = "short_id")) |>
  filter(str_detect(peptide, "SRC"),
         !is.na(subtype))

ggplot(all, aes(subtype, value)) +
  geom_jitter(width = 0.2, alpha = 0.5, aes(color = subtype)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  facet_wrap(~peptide, scales = "free")

tt_data <- all |>
  select(peptide, name, value, subtype) |>
  pivot_wider(values_from = value, names_from = peptide)

lp <- filter(tt_data, subtype == "Luminal_papillary")
not_lp <- filter(tt_data, subtype != "Luminal_papillary")

tapply(not_lp, ~ subtype, \(x) t.test(lp$SRC, x$SRC))
tapply(not_lp, ~ subtype, \(x) t.test(lp$SRC, x$SRC_pY416))
tapply(not_lp, ~ subtype, \(x) t.test(lp$SRC, x$SRC_pY527))
