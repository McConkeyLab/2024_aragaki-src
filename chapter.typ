Kai Aragaki #footnote[These authors contributed equally] <equal>, Brady Urological Institute, Johns Hopkins School of Medicine, Baltimore, MD, USA], Bryan Wehrenberg, Yujiro Hayashi, and David J. McConkey

== ABSTRACT
=== Background
Past work in preclinical models of solid tumors have implicated SRC in invasion and metastasis, but also demonstrated it inhibited bladder cancer metastasis.
=== Objective
Determine if the role of SRC in metastasis is dependent on bladder cancer molecular subtype membership.
=== Methods
We analyzed large public datasets, performed _in vitro_ invasion and migration assays using small-molecule and doxycycline inducible SRC knock-down constructs, and _in vivo_ experimental metastasis assays.
=== Results
Looking at large public datasets, we found SRC is upregulated in luminal papillary muscle invasive bladder cancer. Using the consensus classifier on RNA expression from 30 cell lines, we demonstrated that chemical SRC antagonists inhibited migration in luminal papillary cells but had little effect in basal/squamous lines. Conditional SRC knockdown inhibited migration in luminal papillary RT112 cells, whereas it increased migration and reduced proliferation in luminal papillary UM-UC6 cells. Regardless, these effects did not affect levels or sites of experimental metastasis _in vivo_.
=== Conclusions
The results support the conclusion that SRC's biological effects in bladder cancer are not primarily involved in promoting invasion and metastasis. Further work is required to define SRC's roles in luminal papillary bladder cancers.

== INTRODUCTION
The SRC protooncogene was first identified as the causative factor that mediated the transforming effects of an avian leukemia virus @Rous_1911. Its human counterpart encodes a 60kD non-receptor tyrosine kinase@Martin_2004 that has been implicated in cell cycle progression and integrin-mediated adhesion signaling. Early studies in hematopoietic cells and solid tumor cell lines implicated the integrin-dependent effects of SRC in directional motility, invasion, and metastasis @Yeatman_2004. However, studies in preclinical models of bladder cancer concluded that SRC inhibited invasion and metastasis via mechanisms that involved direct phosphorylation of RhoGDI2 and downstream inhibition of caveolin-1 @Thomas_2011 @Wu_2009.

Bladder cancers are highly heterogeneous in their invasive and metastatic potentials. The majority of bladder cancers are superficial low-grade papillary lesions (non-muscle-invasive bladder cancer, NMIBC) that are prone to recurrence but rarely progress to become life-threatening and metastatic. However, approximately 20-25% of bladder cancers are muscle-invasive at diagnosis, and about half of patients with muscle-invasive bladder cancer (MIBC) ultimately die of metastatic disease@Kamat_2016. MIBC can also be grouped into basal and luminal molecular subtypes that are similar to those described in breast cancer@Robertson_2017 @Damrauer_2014 @Choi_2014. Luminal bladder cancers are enriched with activating FGFR3 mutations and fusions@Knowles_2014 @Cappellen_1999, higher expression of differentiation markers, and better survival outcomes@Robertson_2017, whereas basal bladder cancers exhibit features of epithelial-to-mesenchymal transition (EMT) and are associated with invasive and metastatic disease at clinical presentation and shorter disease-specific survival @Kamat_2016 @Robertson_2017. We hypothesized that SRC plays different roles in luminal versus basal bladder cancers. We tested this hypothesis using public human bladder cancer bulk RNA expression datasets, human bladder cancer cell lines, and _in vivo_ metastasis models.

== RESULTS
=== SRC expression across subtypes
#figure(
    grid(
        columns: 2,
        rows: (auto, auto),
        image("02_figures/lund-nmi-vs-mi.svg"),
        image("02_figures/uromol-src-across-class.svg"),
        grid.cell(
            colspan: 2,
            image("02_figures/uromol-prog-vs-src-cor.svg")
        )
    ),
    caption: [*SRC is enriched in less aggressive bladder cancer subtypes.* *A:* SRC expression in the Lund cohort, stratified by muscle invasion. *B:* SRC expression in the UROMOL 2021 cohort, stratified by UROMOL 2021 class. *C:* Pearson correlation between progression score and SRC expression. NMI: Non-muscle invasive, MI: Muscle invasive. CI = 95%.]
) <Figure1>
We first used public bulk mRNA expression datasets to explore if SRC expression correlated with stage and molecular subtype membership. Consistent with previous findings @Fanning_1992, SRC expression was significantly higher in NMIBC relative to MIBC (@Figure1, A). SRC levels were relatively high in the least aggressive UROMOL subtype (Class 1), but also in the subtype associated with the highest rate of progression (Class 2a) (@Figure1, B) @Lindskrog_2021. However, SRC expression strongly correlated with progression score in Class 1 but not Class 2a tumors, (@Figure1, C), implying SRC expression may play an indirect role in muscle invasion by potentiating progression.

#figure(
    grid(
       columns: (1.5fr, 3fr),
        image("02_figures/tcga-src-rna-across-subtype.svg"),
        image("02_figures/tcga-src-prot-across-subtype.svg")
    ),
    caption: [*SRC is enriched in luminal muscle invasive bladder cancer.* *A:* SRC expression in the TCGA cohort, stratified by TCGA subtype. *B:* Src protein and phosphorylated species expression in the TCGA cohort, stratified by subtype. LP: Luminal papillary, L: Luminal, LI: Luminal infiltrated, BS: Basal squamous, N: Neuronal. CI = 95%.]
) <Figure2>

Analyses of MIBCs revealed similar patterns between subtype aggressiveness and SRC expression, with SRC RNA (@Figure2, A) and protein expression (@Figure2, B) enriched in luminal papillary and luminal subtypes versus the others, and total and active site phosphorylated (Y416) SRC protein levels were also selectively enriched in the least aggressive luminal-papillary TCGA subtype.

=== Differential SRC expression in human cell lines
#figure(
    grid(
        columns: 2,
        image("02_figures/cells-src-across-consensus.svg"),
        image("02_figures/cells-emt-across-consensus.svg")
    ),
    caption: [*Bladder cancer cell lines recapitulate tumor subtypes.* *A:* SRC expression in cell lines stratified by consensus classifier. *B:* Hallmark gene-set enrichment scores stratified by consensus subtype. Shown Hallmarks are those with statistically significant ANOVA scores. LP: Luminal papillary; BS: Basal squamous; NE: Neuroendocrine-like. CI = 95%.]
) <Figure3>
We next examined whether SRC expression was also heterogeneous in a panel of 30 human bladder cancer cell lines. To compare to human tumors, we first classified the cells by consensus class@Kamoun_2020. We found that our luminal-papillary (LP) cell lines expressed significantly higher levels of SRC than the basal squamous (BS) lines (@Figure3, A), consistent with our findings in human tumors. On the other hand, using GSVA to calculate gene set enrichment scores across classes, we found that the EMT signature was significantly upregulated in the BS lines when compared to the LP lines (@Figure3, B).

=== Differential cell line motility across consensus class
#figure(
    grid(
        rows: 2,
        columns: 2,
        image("02_figures/cells-mig-emt-cor.svg"),
        image("02_figures/cells-inv-emt-cor.svg"),
        image("02_figures/cells-mig.svg"),
        image("02_figures/cells-inv.svg"),
    ),
    caption: [*Motility across consensus subtypes.* Migration (*A*, *C*) and invasion (*B*, *D*) rates of cell lines in Boyden chamber assays, correlated by EMT hallmark signature (*A*, *B*) or stratified by consensus subtype (*C*, *D*). LP: Luminal papillary; BS: Basal squamous; NE: Neuroendocrine-like. NS not significant. CI = 95%.]
) <Figure4>
To determine if motility differed across consensus classes, we performed two--dimensional migration assays using uncoated transwells, and invasion assays using Matrigel coated transwells using cells from within each class. We noted that LP lines tended to migrate (@Figure4, C) and invade (@Figure4, D) less readily than BS lines, but the differences were not statistically significant. However, we did note a statistically significant correlation between EMT score and both migration (@Figure4, A) and invasion (@Figure4, B).

=== Differential sensitivity to SRC across consensus class
#figure(
    image("02_figures/cells-mig-bos.svg"),
    caption: [*Sensitivity to Src inhibition across consensus subtypes.* Changes in migration rates across consensus subtypes without (DMSO, -) or with (+) 1μM bositinib. LP: Luminal papillary; BS: Basal squamous]
) <Figure5>
We next determined if sensitivity to Src inhibition varied across consensus classes using migration assays. We exposed representative LP and BS lines to the Src inhibitor bosutinib. On average, LP lines migrated at 53% their original rate, while BS lines migrated 72% their average rate, with individually statistically significant reductions in RT112 (p = 0.0028) and SCaBER (p = 0.00106)  (@Figure5). We additionally examined the effects of the chemically-distinct inhibitor, saracatinib (AZD0530). Although bosutinib had no effect on UM-UC6 migration, saracatinib strongly inhibited migration in both RT112 and UM-UC6 (@Figures1). Because saracatinib also inhibits the TGF-β receptor@Klaeger_2017, we tested the effects of galunisertib, a TGF-β receptor I inhibitor. Galunisertib had no effect on migration in RT112 but did appear to reduce rates consistently (but not significantly) in UC6 (@Figures1). The directionality of these effects implies migration may be driven more by TGF-β activity in UM-UC6, while migration may be driven more by Src in RT112.

#figure(
    grid(
        columns: (1fr, 1fr),
        rows: 2,
        grid.cell(
            rowspan: 2,
            image("02_figures/kd-works.svg"),
        ),
        image("02_figures/cells-mig-src-ikd.svg"),
    ),
    caption: [*Src knockdown has differential effects on migration across cell lines.* *A*: Src knockdown efficiency, measured by ΔΔCt qPCR (top), or Western blot (bottom) without (-) and with (+) 1μg/mL doxycycline, 48hr. *B* Migration rates of doxycycline-inducible SRC knockdown cell lines both without (-) and with (+) 48hr 1μg/mL doxycycline pre-incubation.]
) <Figure6>
We generated doxycycline-inducible SRC knockdown (SRC iKD) lines, validated by qPCR and Western blot (@Figure6, A) and performed migration assays with and without 48h 1μg/mL doxycycline pre-incubation. Similar to small molecule inhibitors, RT112 demonstrated an insignificant reduction in migration upon SRC KD, while UM-UC6 showed a modest increase in migration upon SRC KD (@Figure6). Because Src can also be required for proliferation@Thomas_1997, we also measured the effects of SRC KD on proliferation upon in two cell lines. Bosutinib inhibited proliferation in both cell lines, though to a similar extent in all lines, implying that differences in migration seen with bosutinib are likely not driven by differences in proliferation. A more targeted approach with SRC knockdown showed a consistent but insignificant reduction in proliferation only in UM-UC6 (@Figures3).

=== _in vivo_ effects of SRC inhibition

#figure(
    grid(
        columns: (3fr, 1fr),
        image("02_figures/in-vivo-survival.svg"),
        image("02_figures/in-vivo-met-ratio.svg")
    ),
    caption: [*Src knockdown has differential _in vivo_ effects across cell lines.* *A:* Overall survival of NSG mice tail-vein injected with conditional knockdown cell-lines, with or without doxycycline drinking water. *B:* Ratio of UM-UC6 lung metastasis area to lung area, as quantified by ImageJ, in mice exposed to (+) or not exposed to (-) doxycycline. CI = 95%]
) <Figure7>
Finally, to directly examine the effects of SRC inhibition on metastasis, we pre-incubated the RT112 and UM-UC6 iKD cells +/- doxycycline before inoculating them into the tail veins of immunodeficient NSG mice housed with or without doxycycline in their drinking water. RT112 produced metastases in the lungs, liver, and spine, resulting in failure to void and hind leg paralysis, whereas UM-UC6 caused lymph node and lung metastases. SRC knockdown extended survival in mice inoculated with UM-UC6 but had no effect in animals with RT112 metastases (@Figure7) and did not affect the sites of metastasis in either model.

== DISCUSSION
Src was one of the first discovered proto-oncogenes @Martin_2004, and over 100 years of study have revealed it serves a complex and varied role in cancer@Thomas_1997. In this study, we sought to clarify the paradoxical role of Src as a metastasis suppressor in bladder cancer by testing the hypothesis that its effects may be dependent on molecular subtype. Overall, we observed modest and inconsistent effects of chemical SRC inhibitors or conditional SRC knockdown in conventional two-dimensional invasion and migration assays, and SRC knockdown also had modest effects in a model of experimental metastasis. SRC inhibition did appear to moderately inhibit proliferation in UM-UC6 cells, but not RT112, which may explain why knockdown extended survival in the UM-UC6 metastasis model. It is possible that established human cell lines and two-dimensional tissue culture are not adequate models of primary human tumors. On the other hand, our results reinforce the original conclusion, that SRC is enriched in luminal papillary human primary tumors. The luminal papillary subtype is associated with earlier state disease and better prognoses than are tumors belonging to the other molecular subtypes. In particular, luminal papillary tumors are characterized by gene expression signatures associated with terminal differentiation, suggesting that SRC may play an important role in this process. We also plan to directly test this possibility in appropriate preclinical models in future studies.


== SUPPLEMENTARY

#figure(
    image("02_figures/uc6-rt112-mig-b-g-bg-s.svg"),
    caption: [*UM-UC6, not RT112, migration more sensitive to TGFβR I inhibition than Src inhibition.* Migration rates of cells exposed to DMSO (-) or 1μM bosutinib, 1μM galunisertib, 1μM galunisertib + 1μM bosutinib, or 1μM saracatinib (+).]
) <Figures1>

#figure(
    image("02_figures/uc6-rt112-prolif-src-ikd-dox-bos.svg"),
    caption: [*UM-UC6 proliferation may be inhibited by SRC knockdown.* *A:* MTT assay of UM-UC6 and RT112 conditional SRC (iKD) or non-targeting (NT) knockdown cells exposed to 1μg/mL doxycycline. *B:* UC6 and RT112 exposed to increasing concentrations of bosutinib (nM).]
) <Figures3>

== MATERIALS & METHODS
=== Chemicals and reagents
Saracatinib (Selleck, S1006), bosutinib (Selleck, S1014), and galunisertib (MedChemExpress, HY-13226) were dissolved in DMSO at stock concentrations of 10mM and stored at -80\u{00B0}C. Prior to use, each inhibitor was diluted in culture medium yielding a maximum DMSO concentration of 0.1%.

=== Cell culture
All parental cell lines were obtained from the Pathology Core of the Bladder Cancer SPORE at MD Anderson Cancer Center, with the exceptions of T24 and SCaBER where were purchased from the American Type Culture Collections. Cells were cultured as monolayers with Minimum Essential Medium (Gibco, 11095080) containing 10% fetal bovine serum (Corning, 35-011-CV), 1% nonessential amino acids (Gibco, 11140050), 1% vitamin solution (Gibco, 11120052), 1% penicillin-streptomycin solution (Gibco, 15140122), and 1% sodium pyruvate (Gibco, 11360070). Cells were incubated 37\u{00B0}C in a humidified, 5% CO#sub[2] atmosphere. Cell line identity confirmed by DNA fingerprinting through the MD Anderson Characterized Cell Line Core and the Johns Hopkins School of Medicine Genetic Resources Core Facility. These experiments were performed with mycoplasma positive cells.

=== Generation of conditional knockdown cell lines
Conditional knockdown lines were generated using SMARTvector Inducible Lentiviral shRNAs (Horizon Discovery). Lines were transduced either with lentivirus with constructs containing shRNA designed to target SRC (V3IHSPGG_10847004) or a non-targeting control (VSC6580) with a PGK RNA Pol II promoter. UM-UC6 was seeded at 10,000 cells/mL and RT112 at 30,000 cells/mL. Transduction was performed without serum, and transduced cells selected with 2.5μg/mL puromycin (InvivoGen, ant-pr-1).

=== Transwell migration and invasion assays
Subconfluent cells were trypsinized, resuspended in serum containing medium, centrifuged, washed with PBS, centrifuged, and resupsended in serum free medium. 30,000 to 60,000 cells were then seeded into the upper chamber of the transwell in 0.5ml of serum free medium. The lower chamber was loaded with 30% FBS-containing medium to establish a chemo-attractant gradient. Migration or invasion was allowed to proceed for 4 to 20 hours. Membranes were then fixed, uninvaded cells wiped away, and remaining cells stained with gentian violet or DAPI. The entire filter was imaged by light microscopy and invaded cells quantified with CellProfiler@Stirling_2021. 8µm pore Matrigel coated transwells (Corning, 354480) and uncoated transwells (Corning, 354578) were purchased from Corning.

=== Western blotting
Subconfluent cells were harvested in RIPA buffer containing protease (cOmplete, Roche 11836153001) and phosphatase (PhosSTOP, Roche, 4906837001) inhibitors. Following protein quantification by BCA assay (Thermo Scientific, 23235), samples were diluted and boiled in 2x 2-mercaptoethanol containing Laemmli sample buffer (BioRad, 1610737). SDS-PAGE gel electrophoresis was run at 100 volts for 1.5 hours in Tris-Glycine-SDS buffer (BioRad, 1610732), followed by transfer onto nitrocellulose membrane in Tris-Glycine buffer (BioRad, 1610734) with 20% methanol for 2 hours at 100 volts. Membranes were blocked in casein blocking buffer (Sigma-Aldrich, B6429) for 1 hour, then incubated for 2 hours or overnight in primary antibody (1:1000 or 1:5000 dilution, 0.1X casein), washed in TBS-T (1X TBS, BioRad, 1706435; 0.1% Tween 20, Sigma-Aldrich, P7949), and incubated in secondary antibody for 1 hour (1:5000 dilution, 0.1X casein). In instances where multiple proteins of similar molecular weight were probed, identical but separate blot were performed at the same time. Loading control (actin) was examined on previously probed blots. Primary antibody Src was purchased from Cell Signaling (#2123, RRID:AB_2106047, diluted 1:1000). Actin was purchased from Sigma-Aldrich (A2066, RRID:AB_476693, diluted 1:5000). Secondary antibodies were purchased from LI-COR (LI-COR 926-32210, 926-32211, diluted 1:5000).

=== Tail Vein Injection
NSG mice were warmed in a mouse restrainer using a heat lamp to facilitate vasodilation. The tail was sterilized with 70% ethanol. A 100 µL cell suspension in PBS, containing 2×10^6 UM-UC6 cells or 5×10^5 RT112 cells, was slowly injected into the tail vein after confirming blood backflow.

=== Lung Metastasis Quantification
All physical H&E slides were scanned using the CONCENTRIQ platform for metastasis quantification. The tumor fraction in the lungs was quantified by calculating the ratio of the total metastatic area to the total lung area using FIJI@Schindelin_2012.

=== Statement on Animal Care and Welfare
The Johns Hopkins University Institutional Animal Care and Use Committee approved the experimental procedures used in this study (approval no. MO16M463) on December 2021. All animal housing and experiments were conducted in strict accordance with the institutional Guidelines for Care and Use of Laboratory Animals at Johns Hopkins University.

=== Statistical Analyses
All analyses were performed using R@R (v. 4.4.1). P \< 0.05 was used as a cutoff for statistical significance. T-tests are two-tailed. Paired t-tests were used to compare drug/control within biological replicates. Log-rank test was used to test for survival differences (`survival`@survival-package). `GSVA`@GSVA was used to calculate signature enrichment scores.

=== Data Availability
All data and code used in this paper are publicly available. Code used to obtain data and generate figures can be found at https://github.com/McConkeyLab/2024_aragaki-src. The Lund cohort data were obtained from GEO (GSE32894). The UROMOL cohort data were obtained from the supplementary and source data from the original paper @Lindskrog_2021. TCGA BLCA data were obtained from the Genomic Data Commons, using the pipeline provided at https://github.com/McConkeyLab/general_tcga. Cell line RNA expression was obtained from our publically available package, cellebrate: https://github.com/McConkeyLab/cellebrate.
]

=== References
#bibliography("./sources.bib", style: "nature", title: none)
