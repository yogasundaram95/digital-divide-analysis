# ============================================================
# PROCESS FCC BROADBAND DATA - MAY 2025
# Converts BDC county-level data to format compatible with 2020 analysis
# ============================================================

library(dplyr)
library(readr)

cat("=== FCC MAY 2025 DATA PROCESSING ===\n\n")

# Set working directory
setwd("/Users/yogasundaramramaswamy/Downloads/digital_divide_project")

# -----------------------------
# 1. LOAD RAW FCC MAY 2025 DATA
# -----------------------------
cat("1. Loading FCC May 2025 data...\n")

fcc_raw <- read_csv(
  "/Users/yogasundaramramaswamy/Downloads/filtered_broadband_data_county_may.csv",
  show_col_types = FALSE
)

cat("   Raw rows:", format(nrow(fcc_raw), big.mark = ","), "\n")
cat("   Columns:", paste(names(fcc_raw), collapse = ", "), "\n\n")

# -----------------------------
# 2. FILTER FOR RESIDENTIAL + ANY TECHNOLOGY
# -----------------------------
cat("2. Filtering for Residential + Any Technology...\n")

fcc_county <- fcc_raw %>%
  filter(
    geography_type == "County",
    area_data_type == "Total",  # Total (not Rural/Urban/Tribal subsets)
    biz_res == "R",  # Residential only
    technology == "Any Technology"  # Any technology type
  )

cat("   Filtered rows:", format(nrow(fcc_county), big.mark = ","), "\n\n")

# -----------------------------
# 3. CREATE TIER VARIABLES
# -----------------------------
# Tiers are categorical (1-4) based on coverage quartiles
# Following the pattern of the 2020 FCC data

cat("3. Creating tier variables from coverage fractions...\n")

# Convert coverage fractions to tier categories (1-4)
# Tier 1: 25/3 Mbps coverage (FCC definition of broadband)
# Tier 2: 100/20 Mbps coverage
# Tier 3: 250/25 Mbps coverage

coverage_to_tier <- function(coverage) {
  case_when(
    is.na(coverage) ~ NA_integer_,
    coverage >= 0.90 ~ 4L,  # 90%+ coverage = Tier 4 (excellent)
    coverage >= 0.75 ~ 3L,  # 75-89% = Tier 3 (good)
    coverage >= 0.50 ~ 2L,  # 50-74% = Tier 2 (moderate)
    TRUE ~ 1L               # <50% = Tier 1 (limited)
  )
}

fcc_clean <- fcc_county %>%
  mutate(
    county_fips = geography_id,
    county_name = geography_desc,
    housing_units = total_units,

    # Coverage fractions (continuous)
    coverage_25_3 = speed_25_3,
    coverage_100_20 = speed_100_20,
    coverage_250_25 = speed_250_25,
    coverage_1000_100 = speed_1000_100,

    # Tier variables (categorical 1-4)
    tier1 = coverage_to_tier(speed_25_3),
    tier2 = coverage_to_tier(speed_100_20),
    tier3 = coverage_to_tier(speed_250_25)
  ) %>%
  # Extract state from full description
  mutate(
    state_name = sub("^.*, ", "", geography_desc_full)
  ) %>%
  select(
    county_fips,
    state_name,
    county_name,
    housing_units,
    tier1, tier2, tier3,
    # Also keep continuous coverage for enhanced analysis
    coverage_25_3, coverage_100_20, coverage_250_25, coverage_1000_100
  )

cat("   Counties processed:", nrow(fcc_clean), "\n\n")

# -----------------------------
# 4. VALIDATION
# -----------------------------
cat("4. Validation checks...\n")

# Check tiers are in valid range
invalid_tiers <- fcc_clean %>%
  filter(
    (!is.na(tier1) & (tier1 < 1 | tier1 > 4)) |
    (!is.na(tier2) & (tier2 < 1 | tier2 > 4)) |
    (!is.na(tier3) & (tier3 < 1 | tier3 > 4))
  )
cat("   Invalid tier values:", nrow(invalid_tiers), "\n")

# Check for NA FIPS
na_fips <- sum(is.na(fcc_clean$county_fips) | fcc_clean$county_fips == "")
cat("   Missing FIPS codes:", na_fips, "\n")

# Check housing units
invalid_hu <- sum(fcc_clean$housing_units <= 0, na.rm = TRUE)
cat("   Invalid housing units:", invalid_hu, "\n\n")

# -----------------------------
# 5. SUMMARY STATISTICS
# -----------------------------
cat("5. Summary Statistics:\n\n")

cat("Tier 1 (25/3 Mbps) distribution:\n")
print(table(fcc_clean$tier1))

cat("\nTier 2 (100/20 Mbps) distribution:\n")
print(table(fcc_clean$tier2))

cat("\nTier 3 (250/25 Mbps) distribution:\n")
print(table(fcc_clean$tier3))

cat("\nCoverage summary (25/3 Mbps):\n")
print(summary(fcc_clean$coverage_25_3))

# -----------------------------
# 6. COMPARE WITH 2020 DATA
# -----------------------------
cat("\n6. Comparison with 2020 FCC data...\n")

fcc_2020 <- readRDS("processed_data/fcc_2020_dec_clean.rds")

cat("\n   2020 counties:", nrow(fcc_2020), "\n")
cat("   2025 counties:", nrow(fcc_clean), "\n")

# Check overlap
common_fips <- intersect(fcc_2020$county_fips, fcc_clean$county_fips)
cat("   Common FIPS:", length(common_fips), "\n")

# Compare tier distributions
cat("\n   2020 Tier 3 distribution:\n")
print(table(fcc_2020$tier3))

cat("\n   2025 Tier 3 distribution:\n")
print(table(fcc_clean$tier3))

# -----------------------------
# 7. SAVE RESULTS
# -----------------------------
cat("\n7. Saving results...\n")

# Copy raw data to project
file.copy(
  "/Users/yogasundaramramaswamy/Downloads/filtered_broadband_data_county_may.csv",
  "raw_data/fcc_bdc_may_2025_county.csv",
  overwrite = TRUE
)

# Save processed data
write_csv(fcc_clean, "processed_data/fcc_2025_may_clean.csv")
saveRDS(fcc_clean, "processed_data/fcc_2025_may_clean.rds")

cat("\nSaved to:\n")
cat("  - raw_data/fcc_bdc_may_2025_county.csv\n")
cat("  - processed_data/fcc_2025_may_clean.csv\n")
cat("  - processed_data/fcc_2025_may_clean.rds\n")

# Preview
cat("\n=== PREVIEW ===\n")
print(head(fcc_clean, 5))

cat("\n=== FCC 2025 PROCESSING COMPLETE ===\n")
