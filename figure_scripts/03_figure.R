library(cellebrate)
library(ggsci)
library(classifyBLCA)

consensus <- classify_blca(assay(cell_rna, 2), gene_id = "hgnc", classifier = "consensus")

cd <- as_tibble(colData(cell_rna))

both <- left_join(consensus, cd, by = c(sample = "cell")) |>
  filter(nearest == class) |>
  mutate(class = factor(class, levels = c("lum_p", "ba_sq", "ne_like"))) |>
  arrange(clade, nearest) |>
  mutate(sample = fct_inorder(sample))


table(both$class, both$clade)

ggplot(both, aes(x = sample, y = estimate, color = class)) +
  geom_point() +
  facet_grid(~clade, scales = "free_x", space = "free_x")
