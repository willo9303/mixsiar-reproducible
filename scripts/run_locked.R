# Run the entry point using the restored project library.
if(!requireNamespace("renv",quietly=TRUE)) stop("Install renv first")
renv::load(".")
source("run_analysis.R",encoding="UTF-8")
