# Data provenance

`reference/original_master_data.csv` is a byte-for-byte copy of the supplied final master table (semicolon-delimited; detected encoding: Windows-1252). `data/raw/master_data.csv` contains the same 384 records and 10 columns, serialized as comma-delimited UTF-8. Cell strings are preserved, including NT/CT values with multiple decimal points. No Excel dependency is required.

Only the supplied nine-model MixSIAR pipeline is in scope. Separate SEM, pathway simulations, and mercury biomagnification scripts are not inputs to this pipeline and are not included.

Legacy posterior CSV files contained headers only. They were not copied as valid results. New outputs are generated from the supplied master table. Original seeds and full historical software versions are unavailable, so the historical stochastic results cannot be recreated exactly.

The source script does not document THg units, wet/dry basis, isotope reference standards, laboratory methods, sampling dates, TEF literature justification, authorship or a reuse license. These details must be supplied by the study authors for experimental reproducibility and a complete research release. No license or bibliographic metadata has been invented.
