#set page(margin: 0.5in)
#set footnote(numbering: "*")
#set par(justify: true)
#show figure.caption: it => [
    #set text(8pt)
    #set align(left)
    #it
]

#show heading.where(
  level:1
): it => text(
    14pt,
    it
)

#show heading.where(
  level: 2
): it => text(
    10pt,
    weight: "bold",
    it.body + [.],
)

#text(17pt)[*Heterogeneous Effects of Src Inhibition on Determinants of Metastasis in Preclinical Models of Human Bladder Cancer.*]

Kai Aragaki #footnote[Department of Pharmacology, Johns Hopkins School of Medicine, Baltimore, MD, USA] #footnote[Johns Hopkins Greenberg Bladder Cancer Institute, Brady Urological Institute, Johns Hopkins School of Medicine, Baltimore, MD, USA] <brady>, Bryan Wehrenberg  @brady, Yujiro Hayashi @brady, and David J. McConkey @brady #footnote[To whom correspondence should be addressed: dmcconk1\@jh.edu]



#align(center)[= ABSTRACT]
#[
    #show par: set block(spacing: 2em)
    #set par(leading: 0.4em)
    Past work in preclinical models of solid tumors implicated SRC in invasion and metastasis, whereas it functioned as an inhibitor of metastasis in bladder cancer. Here we tested the hypothesis that the role of SRC in metastasis is dependent on molecular subtype membership. Analyses of large public datasets demonstrated that SRC mRNA and protein expression is enriched in tumors assigned to the luminal papillary molecular subtype. Using the consensus classifier on RNA expression from 30 cell lines, we noted that chemical SRC antagonists tended to inhibit migration in luminal papillary cells but had little effect in basal/squamous lines. Conditional SRC knockdown inhibited migration in luminal papillary RT112 cells, whereas it increased migration and reduced proliferation in luminal papillary UM-UC6 cells. Regardless, these effects did not affect levels or sites of experimental metastasis _in vivo_. Overall, the results confirm that the effects of SRC inhibition on invasion and migration are heterogeneous and linked to molecular subtype membership. The results have implications for the potential use of SRC pathway inhibitors to block bladder cancer progression in patients.
]

#show: rest => columns(2, rest)

= INTRODUCTION
The SRC protooncogene was first identified as the causative factor that mediated the transforming effects of an avian leukemia virus @Rous_1911. Its human counterpart encodes a 60kD non-receptor tyrosine kinase that has been implicated in cell cycle progression and integrin-mediated adhesion signaling. Early studies in hematopoietic cells and solid tumor cell lines implicated the integrin-dependent effects of SRC in directional motility, invasion, and metastasis @Yeatman_2004. However, studies in preclinical models of bladder cancer concluded that SRC inhibited invasion and metastasis via mechanisms that involved direct phosphorylation of RhoGDI2 and downstream inhibition of caveolin-1 @Thomas_2011 @Wu_2009.

Bladder cancers are highly heterogeneous in their invasive and metastatic potentials. Most bladder cancers are superficial low-grade papillary lesions (non-muscle-invasive bladder cancer, NMIBC) that are prone to recurrence but rarely progress to become life-threatening and metastatic. However, approximately 20-25% of bladder cancers are muscle-invasive at diagnosis, and about half of patients with muscle-invasive bladder cancer (MIBC) ultimately die of metastatic disease. Bladder cancers can also be grouped into basal and luminal molecular subtypes that are similar to those described in breast cancer. Luminal papillary bladder cancers are associated with activating FGFR3 mutations and fusions are associated with better survival outcomes, whereas basal bladder cancers exhibit features of epithelial-to-mesenchymal transition (EMT) and are associated with invasive and metastatic disease at clinical presentation and shorter disease-specific survival @Kamat_2016. We wondered whether SRC might play different roles in luminal versus basal bladder cancers. We tested this hypothesis using public human bladder cancer bulk RNA expression datasets and a large panel of human bladder cancer cell lines.

= RESULTS

#figure(
    grid(
        columns: 2,
        rows: (auto, auto),
        image("02_figures/01-a.png"),
        image("02_figures/01-b.png"),
        grid.cell(
            colspan: 2,
            image("02_figures/01-c.png")
        )
    ),
    caption: [*SRC is enriched in less aggressive bladder cancer subtypes.* *A:* SRC expression in the Lund cohort, stratified by muscle invasion. *B:* SRC expression in the UROMOL 2021 cohort, stratified by UROMOL 2021 class. *C:* Pearson correlation between progression score and SRC expression. NMI: Non-muscle invasive, MI: Muscle invasive. CI = 95%.]
) <fig1>

== SRC expression across subtypes
We first used public bulk mRNA expression datasets to explore if SRC expression correlated with stage and molecular subtype membership. Consistent with previous findings @Fanning_1992, SRC expression was significantly higher in NMIBC relative to MIBC (@fig1, A). SRC levels were additionally elevated in the least aggressive UROMOL subtype (Class 1), but also in the subtype associated with the highest rate of progression (Class 2a) (@fig1, B) @Lindskrog_2021. SRC expression strongly correlated with progression score in Class 1 tumors, (@fig1, C), implying SRC expression may be an avenue for progression.

MIBC showed a similar pattern between subtype aggressiveness and SRC expression, with SRC RNA (@fig2, A) and protein expression (@fig2, B) enriched in the less-aggressive luminal-papillary TCGA subtype.

#figure(
    grid(
        columns: (1.5fr, 3fr),
        image("02_figures/02-b.png"),
        image("02_figures/02-c.png")
    ),
    caption: [*SRC is enriched in luminal muscle invasive bladder cancer.* *A:* SRC expression in the TCGA cohort, stratified by TCGA subtype. *B:* Src protein and phosphorylated species expression in the TCGA cohort, stratified by subtype. LP: Luminal papillary, L: Luminal, LI: Luminal infiltrated, BS: Basal squamous, N: Neuronal. CI = 95%.]
) <fig2>

== Differential SRC expression in human cell lines
We next examined whether SRC expression was also heterogeneous in a panel of 30 human bladder cancer cell lines. To compare to human tumors, we first classified the cells by consensus class@Kamoun_2020. We found that our luminal-papillary (LP) models expressed significantly higher levels of SRC than the basal squamous (BS) models (@fig3, A), consistent with our findings in human tumors. Using GSVA to calculate Hallmark gene set enrichment scores across classes, we found seven signatures significant by ANOVA (@fig3, B). Of note, EMT was significantly upregulated in the BS lines when compared to the LP lines.

#figure(
    grid(
        columns: 2,
        image("02_figures/03-b.png"),
        image("02_figures/03-d.png")
    ),
    caption: [*Bladder cancer cell lines recapitulate tumor subtypes.* *B:* SRC expression in cell lines stratified by consensus classifier. *D:* Hallmark gene-set enrichment scores stratified by consensus subtype. Shown Hallmarks are those with statistically significant ANOVA scores. LP: Luminal papillary; BS: Basal squamous; NE: Neuroendocrine-like. CI = 95%.]
) <fig3>

== Differential cell line motility across consensus class

To if enrichment of EMT score translated to functional cell line motility per cell line, we performed migration assays using uncoated transwells, and invasion assays using Matrigel coated transwells, from cells within each class. We noted that LP lines tended to migrate (@fig4, A) and invade (@fig4, B) less readily than BS lines. However, this difference was not statistically significant, likely due to the variability of the assay.

#figure(
    grid(
        rows: 2,
        image("02_figures/04-a.png"),
        image("02_figures/04-b.png"),
    ),
    caption: [*Motility across consensus subtypes.* *A, B:* Migration (*A*) and invasion (*B*) rates of cell lines in Boyden chamber assays, stratified by consensus subtype. LP: Luminal papillary; BS: Basal squamous; NE: Neuroendocrine-like. NS not significant. CI = 95%.]
) <fig4>

== Differential sensitivity to SRC across consensus class
We next determined if sensitivity to Src inhibition varied across consensus classes. We exposed a panel of both LP and BS lines to Src inhibitor bosutinib. On average, LP lines migrated at 53% their original rate, while BS lines migrated 72% their average rate; However, neither of these changes were statistically significant (@fig5).

#figure(
    grid(
        image("02_figures/04-c.png")
    ),
    caption: [*Sensitivity to Src inhibition across consensus subtypes.* Changes in migration rates across consensus subtypes upon exposure 1μM bositinib. LP: Luminal papillary; BS: Basal squamous]
) <fig5>


== UM-UC6 migration is mediated by the TGF-β receptor, not Src
UM-UC6 showed no change in migration upon Src inhibition with bosutinib, but showed significant decrease in migration when inhibited by another Src inhibitor, saracatinib. As saracatinib also inhibits the TGF-β receptor@Klaeger_2017, we wanted to determine if migration in UM-UC6 was mediated by an alternate mechanism. Galunisertib, a TGF-β receptor I inhibitor, either alone or in combination with bosutinib, yielded a decrease in migration rates in UC6 (albeit not statistically significant). RT112's migration was inhibited both by bosutinib as well as saracatinib, but not galunisertib (@figs1).

#figure(
    image("02_figures/s01-a.png"),
    caption: [*UC6 migration may be mediated by TGFb rather than Src.* Migration rates of cells exposed to DMSO (-) or 1μM bosutinib, 1μM galunisertib, 1μM galunisertib + 1μM bosutinib, or 1μM saracatinib (+).]
) <figs1>

We generated doxycycline-inducible SRC knockdown (SRC iKD) lines and performed migration assays with and without 48h 1μg/mL doxycycline pre-incubation. Similar to small molecule inhibitors, RT112 demonstrated an insignificant reduction in migration upon SRC KD, while UC6 showed a modest increase in migration upon SRC KD (@fig6).

#figure(
    grid(
        columns: (0.6fr, 1fr),
        image("02_figures/kd-works-pcr.png"),
        image("02_figures/05-a.png"),
    ),
    caption: [*Src knockdown has differential effects on migration across cell lines.* Migration rates of doxycycline-inducible SRC knockdown cell lines both without (-) and with (+) 48hr 1μg/mL doxycycline pre-incubation.]
) <fig6>

As Src is associated with a variety of oncogenic processes including proliferation@Thomas_1997, we measured proliferation upon SRC KD. Despite bosutinib inhibiting proliferation in both UC6 and RT112, induction of SRC knockdown only inhibited proliferation in UC6 lines (@figs3).

#figure(
    image("02_figures/s03-a.png"),
    caption: [*UC6 proliferation is uniquely inhibited by SRC knockdown.* *A:* MTT assay of UC6 and RT112 conditional SRC (iKD) or non-targeting (NT) knockdown cells exposed to increasing concentrations of doxycycline (ng/mL) or bosutinib (nM). CI = 95%]
) <figs3>

== _in vivo_ effects of SRC inhibition
To examine the effects of SRC inhibition _in vivo_, we pre-treated the RT112 and UM-UC6 iKD cells +/- doxycycline before inoculating them into the tail veins of immunodeficient NSG mice housed with or without doxycycline in their drinking water. RT112 produced metastases in the lungs, liver, and spine, resulting in failure to void and hind leg paralysis, whereas UM-UC6 caused lymph node and lung metastases. Consistent with our findings of SRC KD's effect on proliferation, SRC knockdown extended survival in mice inoculated with UM-UC6 but had no effect in animals with RT112 metastases, and did not affect the sites of metastasis in either model (@fig7).

#figure(
    grid(
        rows: 2,
        image("02_figures/06-a.png"),
        image("02_figures/06-b.png")
    ),
    caption: [*Src knockdown has differential _in vivo_ effects across cell lines.* *A:* Overall survival of NSG mice tail-vein injected with conditional knockdown cell-lines, with or without doxycycline drinking water. *B:* Ratio of lung metastasis area to lung area, as quantified by ImageJ, in mice exposed to (+) or not exposed to (-) doxycycline. CI = 95%]
) <fig7>

= DISCUSSION
Src was one of the first discovered proto-oncogenes, and over 100 years of study have revealed it serves a complex and varied role in cancer@Thomas_1997. Here we have attempted to demonstrate this complexity by describing the interaction between molecular subtypes of bladder cancer and Src. This was made challenging for several reasons. Transwell assays continue to be a challenging, noisy, and low-throughput assay, plagued with confounding variables such as cell passage number, splitting time, and confluence at split. Further, since Src has been shown (by us and many others) to be involved in both proliferation and motility, it is impossible to disentangle the results of transwells assays as that of pure motility or motility combined with changes to proliferation. This would additionally explain the discrepancies between our _in vitro_ migration assays and our _in vivo_ tail vein injection results. Proliferation, rather than motility, may be the key factor in determining survival. As our proliferation assays have shown, RT112 fails to have inhibition proliferated by SRC KD, while UM-UC6's proliferation is inhibited. This is reflected in the differences in survival. Conversely, Src may be important for migration in only RT112, as implied by our transwell assays.

In this study we have demonstrated that Src acts heterogeneously across different molecular subtypes. Molecular subtypes are clinically important and have been shown to be not only prognostic, but also predictive to certain treatments. By treating these subtypes individually, we have shown that we can resolve the apparent paradox of Src acting as a tumor suppressor in some instances while acting as an oncogene in others. Src's preferential role for acting as a promoter of migration and invasion in luminal papillary lines may imply that we should give Src inhibitors to patients only of a given subtype.


= MATERIALS & METHODS
#text(8pt)[
    #show heading.where(
        level: 2
    ): it => text(
    8pt,
        weight: "bold",
        it.body + [.],
    )
    == Chemicals and reagents
Saracatinib (Selleck, S1006), bosutinib (Selleck, S1014), and galunisertib (MedChemExpress, HY-13226) were dissolved in DMSO at stock concentrations of 10mM and stored at -80\u{00B0}C. Prior to use, each inhibitor was diluted in culture medium yielding a maximum DMSO concentration of 1%.

    == Cell culture
All parental cell lines were obtained from the Pathology Core of the Bladder Cancer SPORE at MD Anderson Cancer Center, with the exceptions of T24 and SCaBER where were purchased from the American Type Culture Collections. Cells were cultured as monolayers with Minimum Essential Medium (Gibco, 11095080) containing 10% fetal bovine serum (Corning, 35-011-CV), 1% nonessential amino acids (Gibco, 11140050), 1% vitamin solution (Gibco, 11120052), 1% penicillin-streptomycin solution (Gibco, 15140122), and 1% sodium pyruvate (Gibco, 11360070). Cells were incubated 37\u{00B0}C in a humidified, 5% CO#sub[2] atmosphere. Cell line identity confirmed by DNA fingerprinting through the MD Anderson Characterized Cell Line Core and the Johns Hopkins School of Medicine Genetic Resources Core Facility.

    == Generation of conditional knockdown cell lines
    Conditional knockdown lines were generated using SMARTvector Inducible Lentiviral shRNAs (Horizon Discovery). Lines were transduced either with lentivirus with constructs containing shRNA designed to target SRC (V3IHSPGG_10847004) or a non-targeting control (VSC6580) with a PGK RNA Pol II promoter. UM-UC6 was seeded at 10,000 cells/mL and RT112 at 30,000 cells/mL. Transduction was performed without serum, and transduced cells selected with 2.5μg/mL puromycin (InvivoGen, ant-pr-1).


    == Transwell migration and invasion assays
Subconfluent cells were trypsinized, resuspended in serum containing medium, centrifuged, washed with PBS, centrifuged, and resupsended in serum free medium. 30,000 to 60,000 cells were then seeded into the upper chamber of the transwell in 0.5ml of serum free medium. The lower chamber was loaded with 30% FBS-containing medium to establish a chemo-attractant gradient. Migration or invasion was allowed to proceed for 4 to 20 hours. Membranes were then fixed, uninvaded cells wiped away, and remaining cells stained with gentian violet or DAPI. The entire filter was imaged by light microscopy and invaded cells quantified with CellProfiler@Stirling_2021. 8µm pore Matrigel coated transwells (Corning, 354480) and uncoated transwells (Corning, 354578) were purchased from Corning. Collagen-1 coated transwells were generated by applying 0.2mg/ml collagen-1 (Corning 354236) in PBS to uncoated transwell filters overnight. Collagen-1 filters were rinsed with PBS and used immediately or stored at 4\u{00B0}C for up to one week.

    == Western blotting
    Subconfluent cells were harvested in RIPA buffer containing protease (cOmplete, Roche 11836153001) and phosphatase (PhosSTOP, Roche, 4906837001) inhibitors. Following protein quantification by BCA assay (Thermo Scientific, 23235), samples were diluted and boiled in 2x 2-mercaptoethanol containing Laemmli sample buffer (BioRad, 1610737). SDS-PAGE gel electrophoresis was run at 100 volts for 1.5 hours in Tris-Glycine-SDS buffer (BioRad, 1610732), followed by transfer onto nitrocellulose membrane in Tris-Glycine buffer (BioRad, 1610734) with 20% methanol for 2 hours at 100 volts. Membranes were blocked in casein blocking buffer (Sigma-Aldrich, B6429) for 1 hour, then incubated for 2 hours or overnight in primary antibody (1:1000 or 1:5000 dilution, 0.1X casein), washed in TBS-T (1X TBS, BioRad, 1706435; 0.1% Tween 20, Sigma-Aldrich, P7949), and incubated in secondary antibody for 1 hour (1:5000 dilution, 0.1X casein). In instances where multiple proteins of similar molecular weight were probed, identical but separate blot were performed at the same time. Loading control (actin) was examined on previously probed blots. Primary antibodies were purchased from Cell Signaling including Src, (#2123, RRID:AB_2106047, diluted 1:1000), Smad2 (#3122, RRID:AB_823638, diluted 1:1000), and pS465/468 Smad2 (#3108 RRID:AB_490941, diluted 1:1000). Additional primary antibodies were purchased from ThermoFisher including FAK (AHO0502, RRID:AB_2536313, diluted 1:1000) and pY861 FAK (#44-626G, RRID:AB_2533703, diluted 1:1000) or Sigma-Aldrich including actin (A2066, RRID:AB_476693, diluted 1:5000). Secondary antibodies were purchased from LI-COR (LI-COR 926-32210, 926-32211, diluted 1:5000).

    == Tail Vein Injection
    NSG mice were warmed in a mouse restrainer using a heat lamp to facilitate vasodilation. The tail was sterilized with 70% ethanol. A 100 µL cell suspension in PBS, containing 2×10^6 UM-UC6 cells or 5×10^5 RT112 cells, was slowly injected into the tail vein after confirming blood backflow.

    == Lung Metastasis Quantification:
    All physical H&E slides were scanned using the CONCENTRIQ platform for metastasis quantification. The tumor fraction in the lungs was quantified by calculating the ratio of the total metastatic area to the total lung area using FIJI@Schindelin_2012.

    == Statistical Analyses
    All analyses were performed using R@R (v. 4.4.1). P \< 0.05 was used as a cutoff for statistical significance. T-tests are two-tailed. Paired t-tests were used to compare drug/control within biological replicates. Log-rank test was used to test for survival differences (`survival`@survival-package). `GSVA`@GSVA was used to calculate signature enrichment scores.

    == Data Availability
    All code to generate the manuscript and all its figures is available at https://github.com/McConkeyLab/2024_aragaki-src.

]

= TODO
- Results
    - Survival: Add tags
    - Western blots
    - _in vivo_: Figures from Yujiro
    - Bosutinib sensitivity across clades: rm legend, use x axis text (DMSO, Bos.)
    - rm confusing coloring
- Discussion

#text(8pt)[
    #set par(leading: 0.4em)
    #bibliography("./sources.bib", style: "nature")
]
