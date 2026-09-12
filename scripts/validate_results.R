# Validate a completed output directory without refitting the models.
args <- commandArgs(trailingOnly=TRUE)
output <- if(length(args)) args[1] else "results/normal"
read <- function(path) read.csv(path,check.names=FALSE,stringsAsFactors=FALSE)
log <- read(file.path(output,"logs/run_log.csv"))
stopifnot(nrow(log)==9L, !anyDuplicated(log$Model), all(log$Status %in% c("Prepared","Ran")))
master <- read(file.path(output,"processed_data/master_table_clean.csv"))
stopifnot(all(is.finite(master$d13C)),all(is.finite(master$d15N)))
counts <- read(file.path(output,"processed_data/counts_entities.csv"))
stopifnot(sum(counts$n)==nrow(master))
for(id in log$Model) {
  mix <- read(file.path(output,"mix_files",paste0("mix_",id,".csv")))
  src <- read(file.path(output,"source_files",paste0("source_",id,".csv")))
  tef <- read(file.path(output,"discrimination_files",paste0("discr_",id,".csv")))
  stopifnot(identical(src$Source,tef$Source), all(src$n>=2),
    all(tef$Meand13C==0.4),all(tef$Meand15N==2.8),
    all(tef$SDd13C==0.2),all(tef$SDd15N==0.5))
  # Independently recompute source means and sample sizes from the master table.
  for(i in seq_len(nrow(src))) {
    rows <- master[master$Entity_key==src$Source[i],]
    stopifnot(nrow(rows)==src$n[i],
      abs(mean(rows$d13C)-src$Meand13C[i])<1e-10,
      abs(mean(rows$d15N)-src$Meand15N[i])<1e-10)
  }
  if(all(log$Status=="Ran")) {
    p <- read(file.path(output,"summary_tables",paste0("summary_proportions_",id,".csv")))
    stopifnot(nrow(p)==nrow(src),setequal(p$Source,src$Source),
      all(is.finite(p$mean)),all(p$mean>=0 & p$mean<=1),
      abs(sum(p$mean)-1)<1e-6,all(p$`2.5%`<=p$`50%`),all(p$`50%`<=p$`97.5%`))
    diag <- read(file.path(output,"summary_tables",paste0("diagnostics_",id,".csv")))
    stopifnot(nrow(diag)>0,all(c("Rhat","ESS","screen_pass") %in% names(diag)))
  }
}
cat("PASS: nine model outputs, source summaries, TEFs, counts and posterior structure.\n")
cat("Numerical validity does not imply convergence; inspect diagnostics CSV and trace plots.\n")
