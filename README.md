# Reproducible MixSIAR analysis of aquatic food webs

Nine stable-isotope mixing models for fish and bird trophic guilds, using the supplied final master table. Code, file names and documentation are in English. Original observation labels are preserved.

## Requirements and execution

Use R 4.5.3 and JAGS 4.3.2 for the validated environment. Install JAGS separately before installing the R dependencies. Open the RStudio project or a terminal in this repository.

```sh
Rscript scripts/install_dependencies.R
Rscript --vanilla run_analysis.R prepare results/my_preparation
Rscript --vanilla run_analysis.R test results/my_test_run
Rscript --vanilla run_analysis.R normal results/my_normal_run
Rscript scripts/validate_results.R results/my_normal_run
```

The included `results/` folders already contain completed runs. To reproduce them without overwriting evidence, provide a new output directory:

```sh
Rscript --vanilla run_analysis.R normal results/my_normal_run
Rscript scripts/validate_results.R results/my_normal_run
```

For the recorded package versions, install `renv` and run `renv::restore(project=".", lockfile="renv.lock", prompt=FALSE)` in R. For command-line runs with the restored library, use this wrapper:

```sh
Rscript scripts/run_locked.R normal results/my_locked_run
```

`scripts/install_dependencies.R` installs available packages and is a convenience route, not an exact version restoration. The lockfile records the validation environment, including transitive dependencies; JAGS is an external dependency and is not installed by renv.

## Contents

- `data/raw/master_data.csv`: 384 input records, comma-delimited UTF-8.
- `R/`: cleaning, consumer/source definitions, utilities and model fitting.
- `results/prepare/`: processed data, descriptive tables, model input CSVs and checks.
- `results/test/`: short execution checks; not suitable for scientific inference.
- `results/normal/`: fresh normal-length fits, posterior summaries, diagnostics and trace plots.
- `reference/original_master_data.csv`: unmodified original file, semicolon-delimited.
- `docs/`: data dictionary, provenance and validation report.
- `renv.lock`: recorded R package versions.

Fitted objects are saved locally before summaries and excluded from Git through `.gitignore`. They can be regenerated. All model inputs and numeric summary tables are CSV. Model definitions and diagnostic plots are text/PDF, respectively.

After two runs in the same environment, compare their tables with `Rscript scripts/compare_runs.R results/run_1 results/run_2`.

## Analysis specification

Each consumer guild is fitted separately, pooling municipalities and species. There are no covariates or random effects. Sources use their isotope means, sample SDs and sample sizes; concentration dependence is disabled. The prior is Dirichlet(1,...,1). Residual and process error are both enabled.

The trophic enrichment factors are d13C = 0.4, SD = 0.2 and d15N = 2.8, SD = 0.5 for every source. These settings reproduce the supplied script; a literature justification was not supplied. Consumer minimum sample size is three, except aquatic predatory birds, where it is two. The inherited SD floor of 0.0001 is used for zero source SDs; source sample sizes below two are rejected. The validation report states whether the floor was needed.

| Mode | Iterations per chain | Burn-in | Thinning | Chains |
|---|---:|---:|---:|---:|
| test | 1,000 | 500 | 1 | 3 |
| normal | 100,000 | 50,000 | 50 | 3 |
| long | 300,000 | 200,000 | 100 | 3 |

These are the installed MixSIAR presets. DIC is enabled. Each model resets R's RNG to seed 20260911 plus its index in `R/model_specs.R`; R2jags derives its chain initializations and RNG seeds from that R state. Model order and source labels are recorded. Source labels in posterior tables follow MixSIAR's loaded order, rather than assuming the input order. Exact floating-point identity across platforms or software versions is not guaranteed.

An optional third argument selects model indices, for example `Rscript --vanilla run_analysis.R normal results/selected_models 2,4`. Use separate output folders for independent processes. The nine-model validator is intended for complete runs.

## Data handling and interpretation

Isotope-incomplete records are excluded and exported with their input row numbers. Nonmissing invalid isotope values stop execution. Three ambiguous THg strings are retained in the raw data and become missing in summaries, matching the supplied script; they are explicitly listed in `numeric_conversion_issues.csv`. NT and CT are preserved as text and are not used by these models. Mercury summaries use only isotope-complete observations; `n_THg` is the number of interpretable mercury values.

Numeric posterior tables contain means, SDs, 95% credible interval endpoints, medians and available BUGS diagnostics. Separate CSV files report classical Gelman-Rubin Rhat and coda effective sample size for all monitored parameters. The screening rule is Rhat < 1.01 and ESS >= 400; this is a screening aid, not proof of convergence. Inspect trace plots, priors, source overlap, TEF sensitivity and biological suitability before inference. A successful run only means that computation and export succeeded. Longer runs use a new output directory.

## Research release

Upload the contents of this folder to a new GitHub repository. Large draws and local R environments are excluded by `.gitignore`. No publishing or account access is needed to run the analysis. Before the research release, add the authors, citation, study methods, isotope standards, THg units and measurement basis, TEF references and the appropriate code/data license. These were not supplied and are not fabricated here. See `docs/provenance.md` and `docs/validation_report.md` for the precise scope of reproducibility.
