# Validation report

Validation date: 2026-09-11. Environment: Windows, R 4.5.3, MixSIAR 3.1.12, R2jags 0.8-9 and JAGS 4.3.2. The lockfile records 89 non-base packages.

## Completed checks

- All 384 input records and all 10 original columns preserved in the standardized input CSV; cell-by-cell comparison against the archived original passed.
- All 384 observations have complete isotope values; zero records excluded for missing isotopes.
- Three ambiguous THg values are explicitly logged and treated as missing: data rows 221, 222 and 316. No corrected numeric values were supplied. No units were inferred.
- All nine consumer/source input sets generated. Independently recomputed source means and sample sizes agree with the exported files. No source SD required the inherited 0.0001 floor.
- All nine models completed in test mode and in the original normal preset (100,000 iterations, 50,000 burn-in, thinning 50, three chains).
- Two independent seeded test runs produced identical full posterior arrays for all nine models and byte-identical values in all 29 summary/diagnostic CSV files. See the repeated-run comparison tables.
- A separate project library was populated from the same locally downloaded package binaries and synchronized with `renv::restore`. The locked runner completed all nine test models, producing the same 29 summary/diagnostic tables. This checks isolated library execution; it is not a test of downloading every historical package on another operating system.
- Posterior tables contain every source, finite means in [0,1], means summing to one and ordered credible-interval endpoints. The nine-model validation script passed.
- A representative five-source diagnostic PDF was rendered and inspected for legible source names and plotted chains.

## Normal-run convergence screening

Models with at least one flagged monitored parameter: Birds_Invertivore, Birds_Omnivore, Birds_Nectarivore.

Models with flagged dietary-proportion parameters: none.

The exact parameters, maximum classical Rhat and minimum effective sample sizes are reported in `normal_convergence_overview.csv`; detailed values are in the model diagnostic CSV files. A flag means Rhat >= 1.01, ESS < 400 or a nonfinite diagnostic. Review flagged fits and consider longer chains and model adequacy checks before scientific interpretation. Passing this screen does not establish identifiability, model validity or experimental reproducibility.

## Scope and limitations

The nine normal fits were computed in separate R processes and assembled by model identifier. Each uses the same seed and configuration as the sequential entry point. Final stored fits, source order and generated JAGS model text are preserved locally; large RDS draws are excluded from the GitHub ZIP and ignored by Git. They are recreated when the pipeline runs.

The original source script did not fix seeds, and its historical proportion CSVs had no data rows. The new normal estimates are fresh fits, not claimed bitwise reconstructions of historical estimates. The output_JAGS reporting dependency was replaced with direct posterior extraction, diagnostics and basic trace/histogram plots. Model likelihood, source definitions, prior, TEFs and MCMC preset were retained. NT and CT remain unused text fields.

THg units and wet/dry basis, isotope standards, study/laboratory methods, TEF references, author/citation metadata and reuse licenses remain to be supplied by the study authors. The package supports computational reproducibility; these missing details prevent a complete claim of experimental reproducibility.
