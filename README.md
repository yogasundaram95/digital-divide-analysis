# Digital Divide Project: Broadband Access & Social Vulnerability

A comprehensive analysis of the digital divide in the United States, examining the relationship between broadband connectivity, social vulnerability, and rural-urban classification at the county level.

## Quick Start

1. Open `digital_divide_project.Rmd` in RStudio
2. Set your preferences in the setup chunk:
   ```r
   USE_FCC_2025 <- TRUE  # Set to FALSE for 2020 FCC data
   ```
3. Click **Knit** to generate the full report

## Project Structure

```
digital_divide_project/
├── digital_divide_project.Rmd    # Main analysis document
├── README.md                      # This file
├── scripts/                       # Data processing scripts
│   ├── aggregate_ookla_to_county.R
│   ├── process_fcc_2025_may.R
│   └── process_usda_rucc.R
├── raw_data/                      # Source data files
│   ├── fcc_bdc_may_2025_county.csv
│   ├── usda_rucc_2023.csv
│   ├── ookla_csv/                 # Ookla quarterly speedtest data
│   │   ├── fixed_q1_2020.csv
│   │   ├── fixed_q2_2020.csv
│   │   ├── fixed_q3_2020.csv
│   │   └── fixed_q4_2020.csv
│   └── geographic/                # TIGER/Line shapefiles
└── processed_data/                # Cleaned datasets (generated)
    ├── fcc_2020_dec_clean.rds
    ├── fcc_2025_may_clean.rds
    ├── svi_2020_county_clean.rds
    ├── airband_2020_county_clean.rds
    ├── ookla_2020_county_clean.rds
    ├── usda_rucc_2023_clean.rds
    ├── counties_sf.rds
    └── merged_master_2020.rds
```

## Data Sources

| Dataset | Source | Year | Description |
|---------|--------|------|-------------|
| **FCC Broadband** | [FCC BDC](https://broadbandmap.fcc.gov/data-download) | 2020/2025 | County-level broadband coverage |
| **CDC SVI** | [CDC/ATSDR](https://www.atsdr.cdc.gov/placeandhealth/svi/) | 2020 | Social Vulnerability Index |
| **Microsoft Airband** | Microsoft | 2020 | Broadband usage estimates |
| **Ookla Speedtest** | [Ookla Open Data](https://github.com/teamookla/ookla-open-data) | 2020 | Actual measured internet speeds |
| **USDA RUCC** | [USDA ERS](https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/) | 2023 | Rural-Urban Continuum Codes |
| **Census TIGER** | [Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) | 2020 | County boundary shapefiles |

## Key Variables

### Broadband Metrics
- `tier1`, `tier2`, `tier3` - FCC availability tiers (1-4 scale)
- `coverage_25_3`, `coverage_100_20`, `coverage_250_25` - FCC coverage fractions (2025 data)
- `avg_download_mbps`, `avg_upload_mbps` - Actual speeds (Ookla)
- `avg_latency_ms` - Network latency (Ookla)
- `airband_usage` - Microsoft broadband usage estimate

### Social Vulnerability
- `svi_overall` - Overall SVI percentile (0-1)
- `svi_soc` - Socioeconomic theme
- `svi_hh` - Household composition & disability
- `svi_min` - Minority status & language
- `svi_hous` - Housing type & transportation

### Rural-Urban Classification
- `rucc_2023` - USDA Rural-Urban Continuum Code (1-9)
- `is_metro` - TRUE if metro county (RUCC 1-3)
- `is_rural` - TRUE if nonmetro county (RUCC 4-9)
- `rural_urban_cat` - Category: Metro, Nonmetro-Adjacent, Nonmetro-Nonadjacent

## Analysis Sections

1. **Data Loading & Cleaning** - FCC, SVI, Airband processing
2. **Ookla Speedtest Integration** - Actual speed measurements
3. **USDA Rural-Urban Codes** - Geographic classification
4. **Data Merging** - Combined master dataset (3,141 counties)
5. **Visualizations** - 8 key plots showing digital divide patterns
6. **Spatial Analysis** - Choropleth maps
7. **Statistical Modeling** - Regression analysis

## Key Findings

| Area Type | Counties | Avg Download | % Below 25 Mbps |
|-----------|----------|--------------|-----------------|
| Metro | 1,179 | 110 Mbps | 3.9% |
| Nonmetro-Adjacent | 654 | 82 Mbps | 2.8% |
| Nonmetro-Remote | 1,300 | 52 Mbps | 25.1% |

**Remote rural counties are 6x more likely to lack basic broadband.**

## Requirements

### R Packages
```r
install.packages(c(
  "tidyverse", "sf", "readr", "dplyr", "ggplot2",
  "corrplot", "gridExtra", "scales", "viridis",
  "MatchIt", "cobalt", "spdep", "spatialreg",
  "randomForest", "xgboost", "caret", "pROC",
  "data.table", "knitr", "rmarkdown"
))
```

### System Requirements
- R >= 4.0
- RStudio (recommended for knitting)
- ~2GB RAM for processing

## Running the Processing Scripts

If you need to regenerate processed data:

```bash
# From project directory
Rscript scripts/aggregate_ookla_to_county.R
Rscript scripts/process_fcc_2025_may.R
Rscript scripts/process_usda_rucc.R
```

## Configuration Options

In the Rmd setup chunk:

```r
# Use May 2025 FCC data (newer) or Dec 2020 (original)
USE_FCC_2025 <- TRUE

# Enable/disable map generation (slower)
# Set eval=TRUE in viz-rucc-map chunk for maps
```

## Output Files

After knitting:
- `digital_divide_project.html` - Full report with visualizations
- `processed_data/merged_master_2020.rds` - Final merged dataset

## Authors

- Group 3

## License

For academic use only. Data sources retain their original licenses.

## Acknowledgments

- FCC for broadband deployment data
- CDC/ATSDR for Social Vulnerability Index
- Ookla for open speedtest data
- USDA ERS for rural-urban classifications
- Microsoft for Airband usage data
