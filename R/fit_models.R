# Save draws before summaries; model execution and convergence are separate outcomes.
fit_model <- function(id,mix_file,source_file,discr_file,source_df,mode,seed) {
  out_dir <- file.path(dir_mod,id)
  dir.create(out_dir,showWarnings=FALSE)
  previous <- getwd()
  on.exit(setwd(previous),add=TRUE)
  setwd(out_dir)
  mix <- load_mix_data(mix_file,iso_names=c("d13C","d15N"),factors=NULL,
                       fac_random=NULL,fac_nested=NULL,cont_effects=NULL)
  source <- load_source_data(source_file,source_factors=NULL,conc_dep=FALSE,data_type="means",mix=mix)
  discr <- load_discr_data(discr_file,mix=mix)
  model_file <- paste0("MixSIAR_model_",id,".txt")
  write_JAGS_model(model_file,resid_err=TRUE,process_err=TRUE,mix=mix,source=source)
  set.seed(seed)
  fit <- run_model(run=mode,mix=mix,source=source,discr=discr,model_filename=model_file,alpha.prior=1)
  saveRDS(fit,paste0("jags_out_",id,".rds"))
  saveRDS(list(seed=seed,mode=mode,source_names=source$source_names,
               jags_version=as.character(rjags::jags.version())),"run_metadata.rds")
  extract_summary_table(fit,source_df,file.path(dir_sum,paste0("summary_proportions_",id,".csv")),source$source_names)
  sm <- as.data.frame(fit$BUGSoutput$summary)
  sm$parameter <- rownames(sm)
  write_csv(sm,file.path(dir_sum,paste0("all_parameters_",id,".csv")))
  arr <- fit$BUGSoutput$sims.array
  chains <- coda::mcmc.list(lapply(seq_len(dim(arr)[2]),function(k) coda::mcmc(arr[,k,])))
  rhat <- coda::gelman.diag(chains,autoburnin=FALSE,multivariate=FALSE)$psrf[,1]
  ess <- coda::effectiveSize(chains)
  diag <- tibble(parameter=names(rhat),Rhat=unname(rhat),ESS=unname(ess[names(rhat)])) %>%
    mutate(screen_pass=is.finite(Rhat) & Rhat<1.01 & is.finite(ESS) & ESS>=400)
  write_csv(diag,file.path(dir_sum,paste0("diagnostics_",id,".csv")))
  if(any(!diag$screen_pass)) warning("Convergence screening flagged parameters for ",id)
  # Basic plots avoid version-sensitive output_JAGS options.
  pidx <- grep("^p[.]global[[]",dimnames(arr)[[3]])
  pdf(paste0("posterior_trace_",id,".pdf"),width=9,height=7)
  tryCatch({
    par(mfrow=c(length(pidx),2),mar=c(3,3,2,1))
    for(j in seq_along(pidx)) {
      matplot(arr[,,pidx[j]],type="l",lty=1,xlab="Retained draw",ylab="Proportion",main=source$source_names[j])
      hist(as.vector(arr[,,pidx[j]]),breaks=30,xlim=c(0,1),xlab="Proportion",main=source$source_names[j])
    }
  },finally=dev.off())
}
