# Digital Divide Project: Pre vs Post Condition Report

**Date:** January 5, 2026
**Project:** Digital Divide Analysis - Broadband Access & Social Vulnerability

---

## Executive Summary

This document describes the transformation of the Digital Divide Project from its initial state to the enhanced final version. The project evolved from a basic FCC + SVI analysis to a comprehensive multi-source study incorporating real-world speed measurements, rural-urban classifications, and advanced visualizations.

---

## PRE-PROJECT CONDITION (Initial State)

### Data Sources Available
| Dataset | Status | Counties |
|---------|--------|----------|
| FCC Form 477 (Dec 2020) | Integrated | 3,234 |
| CDC SVI (2020) | Integrated | 3,143 |
| Microsoft Airband | Integrated | 3,142 |
| Ookla Speedtest | **NOT INTEGRATED** | - |
| USDA Rural-Urban Codes | **NOT INTEGRATED** | - |
| FCC 2025 Data | **NOT AVAILABLE** | - |

### Initial Data Structure
```
processed_data/
├── fcc_2020_dec_clean.rds        (3,234 counties)
├── svi_2020_county_clean.rds     (3,143 counties)
├── airband_2020_county_clean.rds (3,142 counties)
└── merged_fcc_svi_airband_2020.rds
```

### Initial Variables (Merged Dataset)
- **FCC Variables:** county_fips, tier1, tier2, tier3, housing_units
- **SVI Variables:** svi_overall, svi_soc, svi_hh, svi_min, svi_hous
- **Airband Variables:** airband_fcc_availability, airband_usage
- **Total Columns:** ~20

### Limitations of Initial State
1. **No actual speed measurements** - Only FCC "availability" data (where broadband COULD be offered)
2. **No rural-urban classification** - Couldn't analyze urban vs rural digital divide
3. **Outdated FCC data** - Only December 2020 data available
4. **Limited visualizations** - Basic plots without rural-urban comparisons
5. **Missing key analysis** - Couldn't compare "advertised" vs "actual" speeds

### Initial Analysis Capabilities
- Basic correlation between SVI and broadband tiers
- County-level mapping
- Regression models using tier variables
- No rural/urban stratification possible

---

## POST-PROJECT CONDITION (Final State)

### Data Sources Now Available
| Dataset | Status | Counties | New Variables |
|---------|--------|----------|---------------|
| FCC Form 477 (Dec 2020) | Integrated | 3,234 | Original tiers |
| FCC BDC (May 2025) | **NEW** | 3,232 | Continuous coverage fractions |
| CDC SVI (2020) | Integrated | 3,143 | Same |
| Microsoft Airband | Integrated | 3,142 | Same |
| Ookla Speedtest (2020) | **NEW** | 3,124 | Actual speeds, latency |
| USDA RUCC (2023) | **NEW** | 3,235 | Rural-urban codes |

### Final Data Structure
```
digital_divide_project/
├── digital_divide_project.Rmd    (Enhanced - 2000+ lines)
├── README.md                      (NEW - Complete documentation)
├── PROJECT_CHANGES.md             (NEW - This document)
│
├── scripts/                       (NEW FOLDER)
│   ├── aggregate_ookla_to_county.R   (NEW)
│   ├── process_fcc_2025_may.R        (NEW)
│   └── process_usda_rucc.R           (NEW)
│
├── raw_data/
│   ├── ookla_csv/                    (NEW - 4 quarterly files, 1GB+)
│   │   ├── fixed_q1_2020.csv
│   │   ├── fixed_q2_2020.csv
│   │   ├── fixed_q3_2020.csv
│   │   └── fixed_q4_2020.csv
│   ├── fcc_bdc_may_2025_county.csv   (NEW)
│   └── usda_rucc_2023.csv            (NEW)
│
└── processed_data/
    ├── fcc_2020_dec_clean.rds        (Original)
    ├── fcc_2025_may_clean.rds        (NEW)
    ├── svi_2020_county_clean.rds     (Original)
    ├── airband_2020_county_clean.rds (Original)
    ├── ookla_2020_county_clean.rds   (NEW)
    ├── usda_rucc_2023_clean.rds      (NEW)
    └── merged_master_2020.rds        (NEW - Enhanced)
```

### Final Variables (Merged Dataset)
**Total Columns: 34** (was ~20)

#### Original Variables (Retained)
- county_fips, state_name, county_name, housing_units
- tier1, tier2, tier3 (FCC availability tiers)
- svi_overall, svi_soc, svi_hh, svi_min, svi_hous
- airband_fcc_availability, airband_usage

#### NEW: Ookla Speedtest Variables
| Variable | Description |
|----------|-------------|
| `avg_download_mbps` | Weighted average download speed |
| `avg_upload_mbps` | Weighted average upload speed |
| `avg_latency_ms` | Weighted average network latency |
| `median_download_mbps` | Median download speed (robust) |
| `median_upload_mbps` | Median upload speed |
| `total_tests` | Number of speed tests in county |
| `total_devices` | Number of unique devices |
| `n_tiles` | Number of Ookla geographic tiles |

#### NEW: FCC 2025 Variables (when USE_FCC_2025=TRUE)
| Variable | Description |
|----------|-------------|
| `coverage_25_3` | % with 25/3 Mbps coverage |
| `coverage_100_20` | % with 100/20 Mbps coverage |
| `coverage_250_25` | % with 250/25 Mbps coverage |
| `coverage_1000_100` | % with 1000/100 Mbps coverage |

#### NEW: USDA Rural-Urban Variables
| Variable | Description |
|----------|-------------|
| `rucc_2023` | Rural-Urban Continuum Code (1-9) |
| `is_metro` | TRUE if metro county (RUCC 1-3) |
| `is_rural` | TRUE if nonmetro county (RUCC 4-9) |
| `rural_urban_cat` | Category: Metro, Nonmetro-Adjacent, Nonmetro-Nonadjacent |

---

## KEY CHANGES SUMMARY

### 1. New Data Processing Scripts
| Script | Purpose | Output |
|--------|---------|--------|
| `aggregate_ookla_to_county.R` | Aggregates 17M Ookla tiles to county level | ookla_2020_county_clean.rds |
| `process_fcc_2025_may.R` | Processes FCC May 2025 BDC data | fcc_2025_may_clean.rds |
| `process_usda_rucc.R` | Processes USDA rural-urban codes | usda_rucc_2023_clean.rds |

### 2. Configurable FCC Data Year
```r
# In setup chunk - can now toggle between years
USE_FCC_2025 <- TRUE   # Use May 2025 data (default)
USE_FCC_2025 <- FALSE  # Use Dec 2020 data (original)
```

### 3. New Visualization Section (6.5)
| Plot | Description | Insight |
|------|-------------|---------|
| 6.5.1 | Box plots: Speed & latency by rural-urban | Shows urban-rural speed gap |
| 6.5.2 | Density: Speed distribution by RUCC | Visualizes 9-level rural gradient |
| 6.5.3 | Scatter: FCC coverage vs actual Ookla speeds | Tests if coverage = reality |
| 6.5.4 | Scatter: SVI vs speeds/latency | Links vulnerability to connectivity |
| 6.5.5 | Correlation heatmap | Shows variable relationships |
| 6.5.6 | Stacked bar: Speed tiers by area type | Quantifies digital divide |
| 6.5.7 | Summary statistics table | Key metrics by rural-urban |
| 6.5.8 | Choropleth map (optional) | Geographic visualization |

### 4. Enhanced Merge Pipeline
**Before:**
```
FCC → SVI → Airband → merged_fcc_svi_airband_2020.rds
```

**After:**
```
FCC → SVI → Airband → Ookla → USDA RUCC → merged_master_2020.rds
```

### 5. Bug Fixes Applied
| Issue | Fix |
|-------|-----|
| Correlation heatmap NA error | Removed zero-variance tier1, added na.omit() |
| FCC 2025 duplicate rows | Filtered for area_data_type="Total" only |
| Ookla tile-to-county mapping | Created spatial join with proper CRS handling |

---

## KEY FINDINGS ENABLED BY CHANGES

### The Rural Digital Divide (NEW ANALYSIS)
| Area Type | Counties | Avg Download | Avg Latency | % Below 25 Mbps |
|-----------|----------|--------------|-------------|-----------------|
| Metro | 1,179 | 110 Mbps | 32 ms | 3.9% |
| Nonmetro-Adjacent | 654 | 82 Mbps | 45 ms | 2.8% |
| **Nonmetro-Remote** | **1,300** | **52 Mbps** | **78 ms** | **25.1%** |

**Key Insight:** Remote rural counties are **6x more likely** to lack basic broadband (25 Mbps) compared to metro areas.

### FCC Coverage vs Reality Gap
- FCC reports 99.97% of counties have 25/3 Mbps "available"
- Ookla shows actual median speeds vary from 20-150 Mbps by county
- **Coverage does not equal actual performance**

### Correlation Discoveries
- Strong negative correlation: RUCC ↔ Download Speed (-0.4)
- Positive correlation: SVI ↔ Latency (+0.3)
- Socially vulnerable communities have slower, less reliable internet

---

## TECHNICAL IMPROVEMENTS

### Before: Limited Analysis
```r
# Could only analyze:
model <- lm(outcome ~ tier3 + svi_overall + airband_usage, data = merged)
```

### After: Rich Multi-dimensional Analysis
```r
# Can now analyze:
model <- lm(avg_download_mbps ~
              svi_overall +
              rucc_2023 +
              rural_urban_cat +
              coverage_25_3 +
              airband_usage,
            data = merged_master)

# Can stratify by rural-urban:
metro_analysis <- merged_master %>% filter(is_metro == TRUE)
rural_analysis <- merged_master %>% filter(is_rural == TRUE)
```

---

## FILES CREATED/MODIFIED

### New Files Created
| File | Lines | Purpose |
|------|-------|---------|
| `scripts/aggregate_ookla_to_county.R` | 139 | Ookla data processing |
| `scripts/process_fcc_2025_may.R` | 127 | FCC 2025 processing |
| `scripts/process_usda_rucc.R` | 95 | USDA RUCC processing |
| `README.md` | 180 | Project documentation |
| `PROJECT_CHANGES.md` | This file | Change documentation |

### Files Modified
| File | Changes |
|------|---------|
| `digital_divide_project.Rmd` | +500 lines: New sections 5.5, 5.6, 6.5; configurable FCC year; enhanced merges |

### Data Files Created
| File | Size | Records |
|------|------|---------|
| `ookla_2020_county_clean.rds` | 123 KB | 3,124 counties |
| `fcc_2025_may_clean.rds` | ~200 KB | 3,232 counties |
| `usda_rucc_2023_clean.rds` | ~150 KB | 3,235 counties |
| `merged_master_2020.rds` | ~300 KB | 3,141 counties, 34 variables |

---

## CONCLUSION

The Digital Divide Project has been transformed from a basic broadband availability analysis into a comprehensive multi-source study that can:

1. **Measure actual internet performance** (not just availability)
2. **Stratify analysis by rural-urban classification**
3. **Compare FCC reported coverage with real-world speeds**
4. **Use the latest 2025 FCC data or 2020 data**
5. **Visualize the digital divide across multiple dimensions**

The enhanced project provides actionable insights into broadband inequity, with remote rural areas clearly identified as having the largest gaps in internet access and quality.

---

*Document generated: January 5, 2026*
*Project enhanced with Claude Code assistance*
