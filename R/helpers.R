safe_name <- function(x){
  x %>%
    iconv(from = "", to = "ASCII//TRANSLIT") %>%
    str_replace_all("[ /|()-]+", "_") %>%
    str_replace_all("[^A-Za-z0-9_]", "") %>%
    str_replace_all("_+", "_") %>%
    str_replace_all("^_|_$", "")
}

summarize_sources <- function(df){
  df %>%
    group_by(Source) %>%
    summarise(
      Meand13C = mean(d13C, na.rm = TRUE),
      SDd13C   = sd(d13C, na.rm = TRUE),
      Meand15N = mean(d15N, na.rm = TRUE),
      SDd15N   = sd(d15N, na.rm = TRUE),
      n        = sum(!is.na(d13C) & !is.na(d15N)),
      .groups  = "drop"
    ) %>%
    mutate(
      SDd13C = ifelse(is.na(SDd13C) | SDd13C == 0, 0.0001, SDd13C),
      SDd15N = ifelse(is.na(SDd15N) | SDd15N == 0, 0.0001, SDd15N)
    )
}

create_mix_file <- function(df_all, consumer_key){
  mix_df <- df_all %>%
    filter(Entity_key == consumer_key) %>%
    mutate(
      ID = ifelse(
        is.na(Code) | Code == "" | Code == "NA",
        paste0(safe_name(consumer_key), "_", row_number()),
        Code
      )
    ) %>%
    select(
      ID,
      Municipality,
      Species,
      Group,
      Trophic_guild,
      Entity_key,
      d13C,
      d15N,
      THg
    )
  
  min_n <- ifelse(grepl("Aquatic predator", consumer_key), 2, 3)
  
  if(nrow(mix_df) < min_n){
    stop("Not enough consumer samples for model: ", consumer_key,
         ". n = ", nrow(mix_df))
  }
  
  mix_df
}

create_fixed_sources <- function(df_all, source_keys){
  source_df <- df_all %>%
    filter(Entity_key %in% source_keys) %>%
    mutate(Source = Entity_key) %>%
    summarize_sources() %>%
    mutate(Source = factor(Source, levels = source_keys)) %>%
    arrange(Source) %>%
    mutate(Source = as.character(Source))
  
  missing_sources <- setdiff(source_keys, source_df$Source)
  
  if(length(missing_sources) > 0){
    stop("Missing sources in data: ", paste(missing_sources, collapse = ", "))
  }
  
  source_df
}

create_discrimination_file <- function(source_df,
                                       tef_d13C_mean = 0.4,
                                       tef_d13C_sd   = 0.2,
                                       tef_d15N_mean = 2.8,
                                       tef_d15N_sd   = 0.5){
  data.frame(
    Source   = source_df$Source,
    Meand13C = rep(tef_d13C_mean, nrow(source_df)),
    SDd13C   = rep(tef_d13C_sd,   nrow(source_df)),
    Meand15N = rep(tef_d15N_mean, nrow(source_df)),
    SDd15N   = rep(tef_d15N_sd,   nrow(source_df))
  )
}

extract_summary_table <- function(jags_out, source_df, out_file, source_names = NULL){
  if(is.null(jags_out) || is.null(jags_out$BUGSoutput$summary)) {
    stop("The fitted object does not contain a posterior summary")
  }
  
  sm <- as.data.frame(jags_out$BUGSoutput$summary)
  sm$parameter <- rownames(sm)
  rownames(sm) <- NULL
  
  if(is.null(source_names)){
    source_names <- source_df$Source
  }
  
  p_tab <- sm %>%
    filter(grepl("^p\\.global\\[", parameter)) %>%
    mutate(
      source_index = as.integer(gsub("p\\.global\\[|\\]", "", parameter)),
      Source = source_names[source_index]
    ) %>%
    select(Source, mean, sd, `2.5%`, `50%`, `97.5%`, any_of(c("Rhat", "n.eff")))
  
  if(nrow(p_tab) != length(source_names) || anyNA(p_tab$Source)){
    stop("No p.global parameters found in jags_out summary.")
  }
  
  stopifnot(all(is.finite(p_tab$mean)), all(p_tab$mean >= 0 & p_tab$mean <= 1),
            abs(sum(p_tab$mean) - 1) < 1e-6)
  write_csv(p_tab, out_file)
  
  p_tab
}

