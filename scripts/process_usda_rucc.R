# ============================================================
# PROCESS USDA RURAL-URBAN CONTINUUM CODES (2023)
# Converts long format to wide format for merging
# ============================================================

library(dplyr)
library(tidyr)
library(readr)

cat("=== USDA RURAL-URBAN CONTINUUM CODES PROCESSING ===\n\n")

# Set working directory
setwd("/Users/yogasundaramramaswamy/Downloads/digital_divide_project")

# -----------------------------
# 1. LOAD RAW USDA DATA
# -----------------------------
cat("1. Loading USDA RUCC 2023 data...\n")

rucc_raw <- read_csv("raw_data/usda_rucc_2023.csv", show_col_types = FALSE)

cat("   Raw rows:", nrow(rucc_raw), "\n")
cat("   Columns:", paste(names(rucc_raw), collapse = ", "), "\n")
cat("   Attributes:", paste(unique(rucc_raw$Attribute), collapse = ", "), "\n\n")

# -----------------------------
# 2. PIVOT TO WIDE FORMAT
# -----------------------------
cat("2. Pivoting to wide format...\n")

rucc_wide <- rucc_raw %>%
  pivot_wider(
    id_cols = c(FIPS, State, County_Name),
    names_from = Attribute,
    values_from = Value
  ) %>%
  rename(
    county_fips = FIPS,
    state_abbr = State,
    county_name = County_Name,
    population_2020 = Population_2020,
    rucc_2023 = RUCC_2023,
    rucc_description = Description
  ) %>%
  mutate(
    county_fips = sprintf("%05d", as.integer(county_fips)),
    population_2020 = as.numeric(population_2020),
    rucc_2023 = as.integer(rucc_2023)
  )

cat("   Counties processed:", nrow(rucc_wide), "\n\n")

# -----------------------------
# 3. CREATE RURAL/URBAN BINARY
# -----------------------------
cat("3. Creating rural/urban classification...\n")

# RUCC codes 1-3 are Metro, 4-9 are Nonmetro
rucc_clean <- rucc_wide %>%
  mutate(
    is_metro = rucc_2023 <= 3,
    is_rural = rucc_2023 >= 4,
    rural_urban_cat = case_when(
      rucc_2023 <= 3 ~ "Metro",
      rucc_2023 <= 6 ~ "Nonmetro-Adjacent",
      TRUE ~ "Nonmetro-Nonadjacent"
    )
  )

cat("   Metro counties:", sum(rucc_clean$is_metro), "\n")
cat("   Nonmetro counties:", sum(rucc_clean$is_rural), "\n\n")

# -----------------------------
# 4. VALIDATION
# -----------------------------
cat("4. Validation checks...\n")

# Check RUCC codes are in valid range (1-9)
invalid_rucc <- rucc_clean %>% filter(rucc_2023 < 1 | rucc_2023 > 9)
cat("   Invalid RUCC codes:", nrow(invalid_rucc), "\n")

# Check for missing FIPS
na_fips <- sum(is.na(rucc_clean$county_fips) | rucc_clean$county_fips == "")
cat("   Missing FIPS codes:", na_fips, "\n\n")

# -----------------------------
# 5. SUMMARY STATISTICS
# -----------------------------
cat("5. RUCC Distribution:\n")
print(table(rucc_clean$rucc_2023))

cat("\nRural-Urban Category Distribution:\n")
print(table(rucc_clean$rural_urban_cat))

# -----------------------------
# 6. SAVE RESULTS
# -----------------------------
cat("\n6. Saving results...\n")

write_csv(rucc_clean, "processed_data/usda_rucc_2023_clean.csv")
saveRDS(rucc_clean, "processed_data/usda_rucc_2023_clean.rds")

cat("\nSaved to:\n")
cat("  - processed_data/usda_rucc_2023_clean.csv\n")
cat("  - processed_data/usda_rucc_2023_clean.rds\n")

# Preview
cat("\n=== PREVIEW ===\n")
print(head(rucc_clean %>% select(county_fips, state_abbr, rucc_2023, rural_urban_cat, is_metro), 10))

cat("\n=== USDA RUCC PROCESSING COMPLETE ===\n")
