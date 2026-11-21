# Ecological niche modeling (ENM)

This directory contains the scripts and supporting documentation used to develop ecological niche models for *Chelonoidis chilensis* with MaxEnt and the R package `kuenm`.

## Workflow

### 1. Environmental data preparation and variable screening
Environmental predictors were prepared for the calibration area (M). Pairwise Pearson correlations were examined to identify strongly correlated predictors (|r| ≥ 0.8). Decisions about retaining variables also considered their ecological relevance.

### 2. Candidate model calibration
Candidate models were generated with `kuenm_cal`, exploring combinations of regularization multipliers (RM), feature classes (FC), and sets of environmental predictors.

### 3. Candidate model evaluation and selection
Models were evaluated with `kuenm_ceval` using partial ROC significance, omission rates, and the corrected Akaike information criterion (AICc). Candidate configurations were selected according to the evaluation criteria specified in the modeling scripts.

### 4. Iterative refinement
Selected candidate models were examined using omission and commission diagnostics, ROC/AUC, response curves, percent contribution, permutation importance, and jackknife assessments of variable importance. Environmental predictors with limited apparent contribution were considered for removal in subsequent calibration cycles. Calibration and evaluation were repeated until further refinement did not yield an improvement under the applied criteria.

### 5. Final model generation and projection
Final models were generated with `kuenm_mod` using the selected parameter settings. The final model was projected to ecoregions outside the calibration area by enabling projection in `kuenm_mod`.

### 6. Extrapolation assessment
The mobility-oriented parity (MOP) analysis implemented in `kuenm_mop` was used to assess environmental novelty and potential extrapolation risks when transferring models beyond the calibration conditions.

### 7. Model summaries
`kuenm_modstats` was used to summarize model outputs across replicates, as applicable.

## Reproducibility notes
The scripts are the authoritative source for the exact parameter grids, candidate variable sets, occurrence partitions, evaluation thresholds, number of replicates, and projection settings. These details should be reported explicitly in the manuscript's Methods section.
