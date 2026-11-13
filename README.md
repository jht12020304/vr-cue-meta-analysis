# VR drug-cue craving meta-analysis — analysis code

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24183017.svg)](https://doi.org/10.5281/zenodo.24183017)

Three-level random-effects meta-analysis (REML, `metafor::rma.mv`) of VR drug-cue vs neutral-cue craving
(Hedges' g), 30 cohorts / 55 contrasts, with cluster-robust CR2 inference and Satterthwaite df (`clubSandwich`).

## Layout

| Path | Content |
|---|---|
| `data/analysis_input_55.csv` | 55 contrasts: cohort, cue, substance, design, RoB, g, vi, value origin |
| `R/meta_analysis.R` | All models → `results/results.csv` |
| `figures/make_figS3_S6.py` + `figure_data.json` | Supplementary Figures S3 / S6 → `results/` |
| `results/` | Generated outputs and `sessionInfo.txt` |

## Run

```sh
Rscript R/meta_analysis.R          # R ≥ 4.5, metafor 5.0-1, clubSandwich 0.7.0
python3 figures/make_figS3_S6.py   # matplotlib, Pillow
```

## Models

- `V`: `vcalc(vi, cluster = cohort, obs = es, rho = 0.6)`; random `~ 1 | cohort/es`
- `baseline` — all 55 contrasts
- `exclude_serious` — drop 9 cohorts rated serious RoB
- `serious_vs_other` — RoB moderator (serious vs low/moderate)
- `rob_3level_reference_only` — three-level RoB moderator; Low has only 2 cohorts (df ≈ 1.2), reference only
- `nicotine`, `alcohol` — substance subgroups (Choi 2011 recoded to nicotine)

Prediction intervals are model-based (`predict.rma`), not CR2-calibrated.

## Data provenance — read before reuse

`analysis_input_55.csv` is a **reconstructed** input, not the original 55-row analysis file:
`value_origin` = 25 `recomputed_from_MSD`, 27 `table1_g_override`, 3 `v017_candidate_value`; `vi` as supplied.
The reconstruction gives baseline g = 0.68 [0.49, 0.88], df 28.1 vs the manuscript's 0.68 [0.49, 0.87], df 28.2.
Results here are therefore not a formal reproduction of the manuscript analysis.
In Figures S3/S6, black rows are computed by this code; gray rows are values quoted from the manuscript.

## License

MIT — see `LICENSE`.
