# All fields are initially text: NT and CT contain ambiguous multi-dot values.
data_raw <- read_csv(input_file, col_types = cols(.default = col_character()),
                     na = c("", "NA"), show_col_types = FALSE)
required <- c("Code", "Municipality", "Species", "Trophic guild", "Group", "THg", "d13C", "d15N")
if(length(setdiff(required, names(data_raw)))) stop("Missing required input columns")
numeric_issues <- list()
for(field in c("THg", "d13C", "d15N")) {
  value <- suppressWarnings(as.numeric(data_raw[[field]]))
  invalid <- !is.na(data_raw[[field]]) & !is.finite(value)
  if(any(invalid)) {
    numeric_issues[[field]] <- tibble(input_row=which(invalid),column=field,
      original_value=data_raw[[field]][invalid],action="Set to NA; ambiguous numeric format")
    if(field!="THg") stop("Invalid isotope value in ",field)
    data_raw[[field]][invalid] <- NA_character_
  }
}
write_csv(bind_rows(numeric_issues),file.path(dir_data,"numeric_conversion_issues.csv"))
excluded <- data_raw %>% mutate(input_row = row_number()) %>% filter(is.na(d13C) | is.na(d15N))
write_csv(excluded, file.path(dir_data, "excluded_missing_isotopes.csv"))
data_clean <- data_raw %>%
  rename(
    Trophic_guild = `Trophic guild`
  ) %>%
  mutate(
    Code = str_squish(as.character(Code)),
    Municipality = str_squish(as.character(Municipality)),
    Municipality = iconv(Municipality, from = "UTF-8", to = "ASCII//TRANSLIT"),
    Species = str_squish(as.character(Species)),
    Trophic_guild = str_squish(as.character(Trophic_guild)),
    Group = str_squish(as.character(Group))
  ) %>%
  mutate(
    THg  = suppressWarnings(as.numeric(THg)),
    d15N = suppressWarnings(as.numeric(d15N)),
    d13C = suppressWarnings(as.numeric(d13C))
  ) %>%
  filter(is.finite(d13C), is.finite(d15N)) %>%
  mutate(
    Group = case_when(
      str_to_lower(Group) == "detritus" ~ "Detritus",
      str_to_lower(Group) == "phytoplankton" ~ "Phytoplankton",
      str_to_lower(Group) == "macrophytes" ~ "Macrophytes",
      str_to_lower(Group) == "periphyton" ~ "Periphyton",
      str_to_lower(Group) == "allochthonous insects" ~ "Allochthonous insects",
      str_to_lower(Group) == "aquatic macroinvertebrates" ~ "Aquatic macroinvertebrates",
      str_to_lower(Group) == "allochthonous plants" ~ "Allochthonous plants",
      str_to_lower(Group) %in% c("fish", "fishes") ~ "Fish",
      str_to_lower(Group) %in% c("bird", "birds") ~ "Birds",
      TRUE ~ Group
    ),
    Trophic_guild = case_when(
      str_to_lower(Trophic_guild) == "primary consumer" ~ "Primary Consumer",
      str_to_lower(Trophic_guild) == "invertivore" ~ "Invertivore",
      str_to_lower(Trophic_guild) == "omnivore" ~ "Omnivore",
      str_to_lower(Trophic_guild) == "carnivore-piscivore" ~ "Carnivore-piscivore",
      str_to_lower(Trophic_guild) %in% c(
        "frugi-granivore",
        "frugigranivore",
        "frugivore",
        "granivore"
      ) ~ "FrugiGranivore",
      str_to_lower(Trophic_guild) == "nectarivore" ~ "Nectarivore",
      str_to_lower(Trophic_guild) == "aquatic predator" ~ "Aquatic predator",
      TRUE ~ Trophic_guild
    ),
    Entity_key = case_when(
      Group %in% c("Fish", "Birds") &
        !is.na(Trophic_guild) &
        Trophic_guild != "" &
        Trophic_guild != "NA" ~
        paste(Group, Trophic_guild, sep = " | "),
      TRUE ~ Group
    )
  )

write_csv(data_clean, file.path(dir_data, "master_table_clean.csv"))

# -----------------------------
# SPECIES SUMMARY (ISOTOPE-COMPLETE ROWS)
# -----------------------------

species_summary <- data_clean %>%
  filter(!is.na(Species), Species != "", Species != "NA") %>%
  group_by(Group, Trophic_guild, Species) %>%
  summarise(
    n = n(),
    
    mean_d13C = mean(d13C, na.rm = TRUE),
    sd_d13C = ifelse(n() > 1, sd(d13C, na.rm = TRUE), NA_real_),
    
    mean_d15N = mean(d15N, na.rm = TRUE),
    sd_d15N = ifelse(n() > 1, sd(d15N, na.rm = TRUE), NA_real_),
    
    mean_THg = ifelse(
      all(is.na(THg)),
      NA_real_,
      mean(THg, na.rm = TRUE)
    ),
    
    sd_THg = ifelse(
      sum(!is.na(THg)) > 1,
      sd(THg, na.rm = TRUE),
      NA_real_
    ),
    
    n_THg = sum(!is.na(THg)),
    
    .groups = "drop"
  ) %>%
  arrange(Group, Trophic_guild, Species)

# Export the numeric table
write_csv(
  species_summary,
  file.path(dir_sum, "species_isotopes_mercury.csv")
)

print(species_summary)


# -----------------------------
# FORMATTED SPECIES SUMMARY
# -----------------------------

format_mean_sd <- function(mean_value, sd_value, n_value, digits = 2){
  case_when(
    is.na(mean_value) ~ "",
    n_value <= 1 | is.na(sd_value) ~ as.character(round(mean_value, digits)),
    TRUE ~ paste0(round(mean_value, digits), " +/- ", round(sd_value, digits))
  )
}

species_summary_formatted <- species_summary %>%
  mutate(
    `d13C mean +/- SD` = format_mean_sd(mean_d13C, sd_d13C, n, 2),
    `d15N mean +/- SD` = format_mean_sd(mean_d15N, sd_d15N, n, 2),
    `THg mean +/- SD` = format_mean_sd(mean_THg, sd_THg, n_THg, 3)
  ) %>%
  select(
    Group,
    `Trophic guild` = Trophic_guild,
    Species,
    n,
    n_THg,
    `d13C mean +/- SD`,
    `d15N mean +/- SD`,
    `THg mean +/- SD`
  )

write_csv(
  species_summary_formatted,
  file.path(dir_sum, "species_summary_formatted.csv")
)

print(species_summary_formatted)

# -----------------------------
# 3. CHECKS
# -----------------------------
counts_sources <- data_clean %>%
  count(Group, sort = TRUE)

counts_consumers <- data_clean %>%
  filter(Group %in% c("Fish", "Birds")) %>%
  count(Group, Trophic_guild, Entity_key, sort = TRUE)

counts_entities <- data_clean %>%
  count(Entity_key, sort = TRUE)

write_csv(counts_sources, file.path(dir_data, "counts_sources_global.csv"))
write_csv(counts_consumers, file.path(dir_data, "counts_consumers_group_guild.csv"))
write_csv(counts_entities, file.path(dir_data, "counts_entities.csv"))

print(counts_entities)

