# ============================================================
# AGGREGATE OOKLA SPEEDTEST DATA TO COUNTY LEVEL
# Converts tile-level speed data to county-level averages
# ============================================================

library(data.table)
library(sf)
library(dplyr)

cat("=== OOKLA DATA AGGREGATION TO COUNTY LEVEL ===\n\n")

# Set working directory
setwd("/Users/yogasundaramramaswamy/Downloads/digital_divide_project")

# -----------------------------
# 1. LOAD COUNTY SHAPEFILE
# -----------------------------
cat("Loading county shapefile...\n")
counties_sf <- readRDS("processed_data/counties_sf.rds")

# Filter to continental US + Alaska + Hawaii (exclude territories)
counties_sf <- counties_sf %>%
  filter(!STATEFP %in% c("60", "66", "69", "72", "78"))  # Remove AS, GU, MP, PR, VI

cat("Counties loaded:", nrow(counties_sf), "\n\n")

# -----------------------------
# 2. LOAD AND COMBINE OOKLA QUARTERS
# -----------------------------
cat("Loading Ookla quarterly data (this may take a few minutes)...\n")

ookla_files <- list.files("raw_data/ookla_csv", pattern = "*.csv", full.names = TRUE)

# Use data.table for speed
ookla_list <- lapply(ookla_files, function(f) {
  cat("  Loading:", basename(f), "\n")
  fread(f, select = c("tile_x", "tile_y", "avg_d_kbps", "avg_u_kbps", "avg_lat_ms", "tests", "devices"))
})

ookla_all <- rbindlist(ookla_list)
cat("\nTotal tiles loaded:", format(nrow(ookla_all), big.mark = ","), "\n")

# Clean: remove NA coordinates
ookla_all <- ookla_all[!is.na(tile_x) & !is.na(tile_y)]

# -----------------------------
# 3. CONVERT TO SPATIAL POINTS
# -----------------------------
cat("\nConverting to spatial points...\n")

# Sample if too large (for faster processing)
if (nrow(ookla_all) > 5000000) {
  cat("  Sampling 5M points for efficiency...\n")
  set.seed(42)
  ookla_sample <- ookla_all[sample(.N, 5000000)]
} else {
  ookla_sample <- ookla_all
}

ookla_sf <- st_as_sf(ookla_sample, coords = c("tile_x", "tile_y"), crs = 4326)
cat("Points created:", format(nrow(ookla_sf), big.mark = ","), "\n")

# -----------------------------
# 4. SPATIAL JOIN TO COUNTIES
# -----------------------------
cat("\nPerforming spatial join (this may take several minutes)...\n")

# Ensure same CRS
counties_sf <- st_transform(counties_sf, 4326)

# Spatial join
ookla_joined <- st_join(ookla_sf, counties_sf[, c("GEOID", "NAME")], join = st_within)

cat("Points matched to counties:", sum(!is.na(ookla_joined$GEOID)), "\n")

# -----------------------------
# 5. AGGREGATE BY COUNTY
# -----------------------------
cat("\nAggregating to county level...\n")

# Drop geometry for faster aggregation
ookla_df <- st_drop_geometry(ookla_joined)

# Weighted average by number of tests
ookla_county <- ookla_df %>%
  filter(!is.na(GEOID)) %>%
  group_by(GEOID) %>%
  summarise(
    # Weighted averages
    avg_download_mbps = weighted.mean(avg_d_kbps / 1000, tests, na.rm = TRUE),
    avg_upload_mbps = weighted.mean(avg_u_kbps / 1000, tests, na.rm = TRUE),
    avg_latency_ms = weighted.mean(avg_lat_ms, tests, na.rm = TRUE),

    # Unweighted medians (more robust)
    median_download_mbps = median(avg_d_kbps / 1000, na.rm = TRUE),
    median_upload_mbps = median(avg_u_kbps / 1000, na.rm = TRUE),

    # Sample size
    total_tests = sum(tests, na.rm = TRUE),
    total_devices = sum(devices, na.rm = TRUE),
    n_tiles = n(),

    .groups = "drop"
  ) %>%
  rename(county_fips = GEOID)

cat("\nCounties with Ookla data:", nrow(ookla_county), "\n")

# -----------------------------
# 6. SUMMARY STATISTICS
# -----------------------------
cat("\n=== SUMMARY STATISTICS ===\n")
cat("\nDownload Speed (Mbps):\n")
print(summary(ookla_county$avg_download_mbps))

cat("\nUpload Speed (Mbps):\n")
print(summary(ookla_county$avg_upload_mbps))

cat("\nLatency (ms):\n")
print(summary(ookla_county$avg_latency_ms))

# -----------------------------
# 7. SAVE RESULTS
# -----------------------------
cat("\nSaving results...\n")

write.csv(ookla_county, "processed_data/ookla_2020_county_clean.csv", row.names = FALSE)
saveRDS(ookla_county, "processed_data/ookla_2020_county_clean.rds")

cat("\nSaved to:\n")
cat("  - processed_data/ookla_2020_county_clean.csv\n")
cat("  - processed_data/ookla_2020_county_clean.rds\n")

# Preview
cat("\n=== PREVIEW ===\n")
print(head(ookla_county, 10))

cat("\n=== OOKLA AGGREGATION COMPLETE ===\n")
