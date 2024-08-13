#set page(margin: 0.5in)
#set par(justify: true)

= Figures

== Figure 1
#grid(
    columns: 4,
    image("02_figures/01-a.png"),
    image("02_figures/01-b.png"),
    image("02_figures/01-c.png"),
    image("02_figures/01-b_extra.png")
)

*Figure 1: SRC is enriched in less aggressive bladder cancer subtypes.* *A:* SRC expression in the Lund cohort, stratified by muscle invasion. *B, C:* SRC expression in the UROMOL 2021 cohort, stratified by UROMOL 2021 class (*B*) or LundTax (*C*). *D:* Pearson correlation of signatures used in UROMOL and SRC expression, stratified by class. NMI: Non-muscle invasive, MI: Muscle invasive. \*\*\* p < 0.001, \*\* p < 0.01, \* p < 0.05, NS not significant. CI = 95%.

== Figure 2
#grid(
    columns: 2,
    image("02_figures/02-b.png"),
    image("02_figures/02-c.png")
)
*Figure 2: SRC is enriched in luminal muscle invasive bladder cancer.* *B:* SRC expression in the TCGA cohort, stratified by TCGA subtype. *C:* Src protein and phosphorylated species expression in the TCGA cohort, stratified by subtype. LP: Luminal papillary, L: Luminal, LI: Luminal infiltrated, BS: Basal squamous, N: Neuronal. \*\*\* p < 0.001, \*\* p < 0.01, \* p < 0.05, NS not significant. CI = 95%.

#pagebreak()

== Figure 3
#grid(
    columns: (90pt, auto, auto, auto),
    rows: (120pt, 120pt),
    grid.cell(
      rowspan: 2,
      image("02_figures/03-a.png")
    ),
    image("02_figures/03-b.png"),
    image("02_figures/03-c.png"),
    image("02_figures/03-e.png"),
    grid.cell(
        colspan: 3,
        image("02_figures/03-d.png")
    )
)
*Figure 3: Bladder cancer cell lines recapitulate tumor subtypes.* *A:* Hierarchical clustering of RNA expression from 30 bladder cancer cell lines. By branch color: orange - luminal papillary; light blue - epithelial other; green - mesenchymal; purple - unknown. Text indicates presence of an FGFR3 alteration. *B:* SRC expression in cell lines stratified by consensus classifier. *C:* Consensus subtype enrichment within each clade. *D:* Hallmark gene-set enrichment scores stratified by consensus subtype. Shown Hallmarks are those with statistically significant ANOVA scores. *E:* Heatmap of known EMT marker expression stratified by consensus subtype. LP: Luminal papillary; Ep.: Epithelial other; Mes.: Mesenchymal; Unk.: Unknown; BS: Basal squamous; NE: Neuroendocrine-like.  \*\*\* p < 0.001, \*\* p < 0.01, \* p < 0.05, NS not significant. CI = 95%.

== Figure 4
#grid(
    columns: 3,
    image("02_figures/04-a.png"),
    image("02_figures/04-b.png"),
    image("02_figures/04-c.png"),
)
*Figure 4: Motility and Src inhibition sensitivity across consensus subtypes.* *A, B:* Migration (*A*) and invasion (*B*) rates of cell lines in Boyden chamber assays, stratified by consensus subtype. *C:* Changes in migration rates across consensus subtypes upon exposure 1μM bositinib. LP: Luminal papillary; BS: Basal squamous; NE: Neuroendocrine-like. NS not significant. CI = 95%.

#pagebreak()

== Figure 5
#image("02_figures/05-a.png")
*Figure 5: Src knockdown has differential effects on migration across cell lines.* *A:* Migration rates of doxycycline inducible SRC knockdown cell lines both without (-) and with (+) 48hr 1μg/mL doxycycline pre-incubation. \* p < 0.05, NS not significant.

== Figure 6
#image("02_figures/06-a.png")
*Figure 6: Src knockdown has differential _in vivo_ effects across cell lines.* *A:* Overall survival of NSG mice tail-vein injected with conditional knockdown cell-lines, with or without doxycycline drinking water.

== Figure S1
#image("02_figures/s01-a.png")
*Figure S1: UC6 migration may be mediated by TGFb rather than Src.* *A:* Migration rates of cells exposed to DMSO (-) or 1μM bosutinib, 1μM galunisertib, 1μM galunisertib + 1μM bosutinib, or 1μM saracatinib (+). \*\*\* p < 0.001, \*\* p < 0.01, \* p < 0.05, NS not significant.

#pagebreak()

== Figure S3
#image("02_figures/s03-a.png")
*Figure S3: UC6 proliferation is uniquely inhibited by SRC knockdown.* *A:* MTT assay of UC6 and RT112 conditional SRC (004) or non-targeting (NT) knockdown cells (004, blue) exposed to varying concentrations of doxycycline (ng/mL) or bosutinib (nM).
