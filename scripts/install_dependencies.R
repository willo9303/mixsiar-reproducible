options(repos=c(CRAN="https://cloud.r-project.org"))
packages <- c("dplyr","stringr","readr","purrr","tidyr","MixSIAR","tibble","renv")
missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
if(length(missing)) install.packages(missing)
missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
if(length(missing)) stop("Dependency installation incomplete: ",paste(missing,collapse=", "))
if(!requireNamespace("rjags",quietly=TRUE)) stop("Install JAGS before installing rjags")
message("JAGS: ",rjags::jags.version())
