# Compare two seeded runs made in the same software environment.
args <- commandArgs(trailingOnly=TRUE)
if(length(args)!=2L) stop("Usage: Rscript scripts/compare_runs.R output_1 output_2")
files <- list.files(file.path(args[1],"summary_tables"),pattern="[.]csv$",full.names=FALSE)
other <- list.files(file.path(args[2],"summary_tables"),pattern="[.]csv$",full.names=FALSE)
stopifnot(length(files)>0,setequal(files,other))
identical_tables <- vapply(files,function(f) {
  a <- read.csv(file.path(args[1],"summary_tables",f),check.names=FALSE)
  b <- read.csv(file.path(args[2],"summary_tables",f),check.names=FALSE)
  identical(a,b)
},logical(1))
print(data.frame(file=files,identical=identical_tables),row.names=FALSE)
if(!all(identical_tables)) stop("Runs differ. Check inputs, versions, seeds and settings.")
cat("PASS: all summary and diagnostic tables are identical.\n")
