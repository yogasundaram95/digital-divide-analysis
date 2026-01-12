# The Digital Divide Project: A Beginner's Guide

## Table of Contents
1. [What is the Digital Divide?](#what-is-the-digital-divide)
2. [What Does This Project Do?](#what-does-this-project-do)
3. [The Data We Use](#the-data-we-use)
4. [How the Analysis Works](#how-the-analysis-works)
5. [What We Discovered](#what-we-discovered)
6. [How to Run the Code](#how-to-run-the-code)
7. [Understanding the Output](#understanding-the-output)
8. [Glossary](#glossary)

---

## What is the Digital Divide?

### Imagine This...

Imagine you and your friend both have homework to do. You have fast internet at home - you can watch videos, download files, and video chat with your teacher easily. But your friend lives in a rural area where the internet is super slow - videos buffer forever, downloads take hours, and video calls keep freezing.

**That difference is called the "Digital Divide."**

It's the gap between people who have good access to the internet and computers, and people who don't.

### Why Does It Matter?

In today's world, you need the internet for almost everything:
- **School**: Online classes, homework research, educational videos
- **Jobs**: Applying for jobs, working from home, learning new skills
- **Healthcare**: Video doctor visits (telehealth), health information
- **Government**: Paying taxes, getting benefits, voting information
- **Daily Life**: Banking, shopping, staying connected with family

If you don't have good internet, you're left behind. It's like everyone else has a car, but you have to walk everywhere.

### The Big Questions We're Trying to Answer

1. **Where** in the United States do people have bad internet?
2. **Who** is most affected? (Poor communities? Rural areas? Certain races?)
3. **Why** do some places have bad internet while others don't?
4. **What** can the government do to fix it?

---

## What Does This Project Do?

### The Mission

This project is like being a detective. We gather clues (data) from different sources, put them together, and figure out:

```
Which counties in America need the most help getting better internet?
```

### The Approach

We look at **every county** in the United States (there are about 3,100 of them!) and measure:

1. **Do they HAVE internet available?** (Can they buy it if they want?)
2. **Do they actually USE internet?** (Are people connected?)
3. **How FAST is their internet?** (Is it actually good?)
4. **How VULNERABLE is the community?** (Are they poor? Elderly? Minorities?)

Then we combine all this information to create a **Priority Score** - a number that tells us which counties need help the most.

### Think of It Like a Hospital Triage

When lots of patients come to a hospital emergency room, doctors don't help them in the order they arrived. They check who is most sick and help them first.

Our project does the same thing for internet access - we figure out which counties are most "sick" (digitally) so the government knows where to send help first.

---

## The Data We Use

We use **6 different datasets** - like 6 different puzzle pieces that fit together to show the full picture.

### 1. FCC Broadband Data (The "Official" Map)

**What it is**: The government (FCC) asks internet companies "Where do you offer service?"

**What it tells us**: Which areas have internet available (at least on paper)

**The Problem**: Companies often exaggerate! They say "We cover this whole area" when really they only cover part of it.

```
Think of it like a pizza delivery app saying "We deliver to your neighborhood"
but when you try to order, they say "Sorry, not your specific street."
```

**File**: `raw_data/fcc/form477_fcc_data.csv`

---

### 2. Ookla Speedtest Data (The "Reality Check")

**What it is**: Real speed tests from real people using Speedtest.net

**What it tells us**: How fast internet ACTUALLY is (not what companies promise)

**Why it's important**: This is the truth! Real people testing their real internet speeds.

```
It's like the difference between a restaurant menu saying "Delivery in 30 minutes"
vs. actually timing how long your pizza takes to arrive.
```

**Files**: `raw_data/ookla/` (quarterly data from 2020)

**Key measurements**:
- **Download speed** (Mbps): How fast you can get stuff FROM the internet
- **Upload speed** (Mbps): How fast you can send stuff TO the internet
- **Latency** (ms): How long it takes for a signal to go back and forth (lower is better)

---

### 3. Microsoft Airband Data (The "Gap Finder")

**What it is**: Microsoft compared FCC's "availability" data with actual usage patterns

**What it tells us**: The gap between "internet is available" and "people actually use it"

**Why it matters**: Just because internet is available doesn't mean people can afford it or know how to use it!

```
It's like a gym being open in your neighborhood - just because it's there
doesn't mean everyone can afford the membership or knows how to use the equipment.
```

**File**: `raw_data/microsoft/broadband_data_2020.csv`

---

### 4. CDC Social Vulnerability Index (SVI)

**What it is**: A score that measures how "vulnerable" a community is

**What it tells us**: Which communities might struggle more during emergencies or have fewer resources

**Components** (4 themes):
1. **Socioeconomic**: Income, poverty, employment, education
2. **Household Composition**: Elderly, disabled, single parents, children
3. **Minority Status**: Race, ethnicity, English language ability
4. **Housing/Transportation**: Housing type, crowding, vehicle access

**Score range**: 0 to 1 (higher = more vulnerable)

```
Think of SVI like a "difficulty level" for a community.
A high score means life is harder there - less money, more challenges.
```

**File**: `raw_data/svi/SVI_2020_US_county.csv`

---

### 5. USDA Rural-Urban Codes

**What it is**: A classification of how "rural" or "urban" each county is

**Categories**:
| Code | What it means |
|------|---------------|
| 1 | Big city (1 million+ people) |
| 2-3 | Medium/small metro areas |
| 4-6 | Near a city but not in it |
| 7-9 | Rural (far from cities) |

**Why it matters**: Rural areas often have worse internet because it's expensive to build infrastructure where few people live.

```
Imagine you're a pizza shop. Would you rather deliver to an apartment building
with 100 families, or drive 30 miles to deliver to one house?
Internet companies think the same way.
```

**File**: `raw_data/usda_rucc_2023.csv`

---

### 6. Census Data (ACS)

**What it is**: Survey data about American households

**What we use**:
- **Income**: How much money do households make?
- **Education**: How many people went to college?
- **Internet access**: Do households have internet subscriptions?
- **Computers**: Do households have computers/tablets/smartphones?

**Files**: `raw_data/census/` (multiple tables)

---

## How the Analysis Works

### Step 1: Clean the Data (Washing the Ingredients)

Before you cook, you wash your vegetables. Before we analyze, we clean our data.

**What we do**:
- Remove errors and impossible values
- Make sure all counties use the same ID codes
- Convert everything to the same format
- Handle missing data

```r
# Example: If someone's income is listed as -$50,000, that's an error!
# We either fix it or remove that row.
```

---

### Step 2: Merge the Datasets (Assembling the Puzzle)

Each dataset is one puzzle piece. We connect them using the **county ID** (called FIPS code).

```
FIPS Code = A 5-digit number that uniquely identifies each county
Example: 06037 = Los Angeles County, California
         17031 = Cook County (Chicago), Illinois
```

**The merge process**:
```
FCC Data ----+
             |
Ookla Data --+
             |
Microsoft ---+--> MASTER DATASET (all info in one place)
             |
SVI Data ----+
             |
Census Data -+
             |
USDA Codes --+
```

---

### Step 3: Create New Measurements (Building Better Tools)

We combine the raw data to create more useful measurements:

#### Digital Vulnerability Score
```
Digital Vulnerability =
    50% x Social Vulnerability (SVI) +
    30% x (1 - Broadband Usage) +
    20% x No Internet Access Rate
```

**Translation**: Counties are more vulnerable if they have:
- High social vulnerability (poor, elderly, minorities)
- Low broadband usage
- Many households without internet

#### Broadband Gap
```
Broadband Gap = FCC Availability - Actual Usage
```

**Translation**: The difference between "internet is available" and "people actually use it"

A big gap means something is blocking people from using available internet (cost? knowledge? quality?)

#### CDVI (Composite Digital Vulnerability Index)
A super-score that combines EVERYTHING:
- Digital deprivation
- Technology access gap
- Infrastructure gap
- Socioeconomic vulnerability
- Community vulnerability
- Education levels

---

### Step 4: Analyze Patterns (Detective Work)

#### Regression Analysis (Finding Relationships)
We ask: "What factors predict bad internet access?"

```
Bad Internet = caused by (Rural location? + Poverty? + Low education? + ???)
```

**Finding**: All of these matter! Rural + Poor + Less educated = Much worse internet access

#### Spatial Analysis (Looking at Maps)
We check: "Do nearby counties have similar problems?"

**Finding**: YES! Digital disadvantage clusters in regions. If one county has bad internet, its neighbors probably do too.

```
It's like how one bad apple can spoil the bunch -
or how one good coffee shop can attract more businesses nearby.
```

#### Machine Learning (Computer Pattern Recognition)
We train computers to predict which counties will have the worst internet.

**Best predictors**:
1. Social Vulnerability Index (SVI)
2. Households without computers
3. Income levels
4. Education levels
5. Rural classification

---

### Step 5: Create Priority Rankings

We calculate a **Priority Score** for each county:

```
Priority Score =
    40% x CDVI (vulnerability index) +
    25% x Technology access gap +
    20% x Adoption efficiency need +
    15% x Return on connectivity potential
```

Then we rank all 3,100+ counties from highest to lowest priority.

---

## What We Discovered

### Discovery 1: The FCC is Wrong (A Lot)

**The Problem**:
- FCC says: "100% of locations have 25 Mbps available"
- Reality: 12.4% of counties have actual speeds BELOW 25 Mbps

**Worst Examples**:
| County | State | FCC Says | Actual Speed |
|--------|-------|----------|--------------|
| Keya Paha | Nebraska | 100% covered | 0.4 Mbps |
| Garfield | Montana | 100% covered | 2.4 Mbps |
| Kusilvak | Alaska | 100% covered | 2.5 Mbps |

**Why This Matters**: Government policies based on FCC data will miss the counties that need help most!

---

### Discovery 2: Rural America is Left Behind

| Area Type | Avg Download Speed | % Below 25 Mbps |
|-----------|-------------------|-----------------|
| Metro (cities) | 110 Mbps | 3.9% |
| Near cities | 82 Mbps | 2.8% |
| **Remote rural** | **52 Mbps** | **25.1%** |

**Translation**: If you live far from a city, you're **6 times more likely** to have bad internet.

---

### Discovery 3: Vulnerability + Bad Internet = Double Trouble

Counties with high social vulnerability (poor, elderly, minority communities) ALSO tend to have worse internet. It's a double whammy:

- They have less money to afford internet
- They have fewer resources to learn digital skills
- Companies don't invest in infrastructure there
- They get left further behind

---

### Discovery 4: Big Cities Have Problems Too

Our top 20 priority counties are all BIG METRO AREAS:
1. Los Angeles, CA
2. Cook County (Chicago), IL
3. Harris County (Houston), TX
4. Miami-Dade, FL
5. Brooklyn, NY

**Why?** Even though the *percentage* of people with bad internet is lower in cities, the *total number* of people affected is huge. Los Angeles alone has more underserved people than entire rural states.

---

## How to Run the Code

### What You Need (Prerequisites)

#### 1. Install R
R is a programming language for statistics.

**Download from**: https://cran.r-project.org/

**How to check if you have it**:
```bash
R --version
```
You should see something like "R version 4.x.x"

#### 2. Install RStudio (Recommended)
RStudio makes R easier to use with a nice interface.

**Download from**: https://posit.co/download/rstudio-desktop/

#### 3. Install Required Packages
Open R or RStudio and run:

```r
# This installs all the packages you need
install.packages(c(
  "tidyverse",     # Data manipulation and visualization
  "sf",            # Spatial/geographic data
  "spdep",         # Spatial statistics
  "spatialreg",    # Spatial regression models
  "caret",         # Machine learning
  "randomForest",  # Random forest models
  "xgboost",       # XGBoost models
  "MatchIt",       # Propensity score matching
  "corrplot",      # Correlation plots
  "knitr",         # Report generation
  "rmarkdown"      # R Markdown documents
))
```

This might take 10-15 minutes. Go get a snack!

---

### The Project Files

```
digital_divide_project/
│
├── digital_divide_project.Rmd    # THE MAIN FILE - all the analysis
├── digital_divide_project.html   # The finished report (open in browser)
├── README.md                     # Project description
├── BEGINNERS_GUIDE.md           # This file you're reading!
│
├── raw_data/                     # Original data files
│   ├── fcc/                      # FCC broadband data
│   ├── svi/                      # Social vulnerability data
│   ├── microsoft/                # Microsoft Airband data
│   ├── census/                   # Census/ACS data
│   ├── ookla/                    # Speed test data
│   └── geographic/               # Map shapefiles
│
├── processed_data/               # Cleaned data (created by the code)
│   ├── analysis_2020_county_final.rds
│   ├── merged_fcc_svi_airband_ookla_2020.rds
│   └── ... (many other files)
│
├── scripts/                      # Helper scripts
│   ├── aggregate_ookla_to_county.R
│   ├── process_fcc_2025_may.R
│   ├── process_usda_rucc.R
│   ├── policy_enhancements.Rmd
│   └── run_policy_analysis.R
│
└── outputs/                      # Results
    ├── digital_divide_project.html
    └── top_20_priority_counties.csv
```

---

### Running the Main Analysis

#### Option 1: Open the Finished Report (Easiest)

Just open `digital_divide_project.html` in your web browser. Everything has already been run!

```bash
# On Mac:
open digital_divide_project.html

# On Windows:
start digital_divide_project.html
```

#### Option 2: Run the Full Analysis (Takes 30-60 minutes)

1. **Open RStudio**

2. **Open the project file**:
   - File → Open Project
   - Select `digital_divide_project.Rproj`

3. **Open the main R Markdown file**:
   - File → Open File
   - Select `digital_divide_project.Rmd`

4. **Click "Knit"** (the button with a yarn ball icon)
   - This runs all the code and creates the HTML report
   - It takes 30-60 minutes because there's a LOT of data

#### Option 3: Run Code Chunk by Chunk (For Learning)

In RStudio with `digital_divide_project.Rmd` open:

1. Click inside any code chunk (the gray boxes)
2. Press **Ctrl+Shift+Enter** (Windows) or **Cmd+Shift+Enter** (Mac)
3. Watch it run!

**Tip**: Run chunks in order from top to bottom. Later chunks depend on earlier ones.

---

### Running the Policy Analysis Script

This is a simpler script that shows the key findings:

```bash
cd /path/to/digital_divide_project
Rscript scripts/run_policy_analysis.R
```

**What it outputs**:
1. Spatial model comparison
2. Top 20 priority counties
3. FCC vs. Ookla gap analysis
4. A CSV file with priority counties

---

### Common Problems and Solutions

#### Problem: "Package not found"
```r
# Solution: Install the missing package
install.packages("package_name")
```

#### Problem: "File not found"
Make sure you're in the right directory:
```r
# Check current directory
getwd()

# Change to project directory
setwd("/path/to/digital_divide_project")
```

#### Problem: "Out of memory"
The spatial data is big! Try:
- Close other programs
- Restart R and try again
- On a computer with at least 8GB RAM

#### Problem: "Knitting fails"
Try running chunk by chunk to find the error:
1. Run → Run All Chunks Above
2. Then run each remaining chunk one at a time
3. The one that fails will show an error message

---

## Understanding the Output

### The Main Report (HTML File)

The report has these sections:

1. **Introduction**: What the project is about
2. **Data Loading**: Bringing in all the data files
3. **Data Cleaning**: Fixing errors and formatting
4. **Exploratory Analysis**: Charts and maps showing patterns
5. **Regression Models**: Statistical analysis of what causes bad internet
6. **Machine Learning**: Computer predictions of vulnerable counties
7. **Spatial Analysis**: Map-based patterns
8. **Policy Simulation**: Testing different ways to allocate money
9. **Recommendations**: What the government should do

### Key Visualizations

#### Choropleth Maps (Colored Maps)
- **Dark red** = Bad (low internet, high vulnerability)
- **Light/white** = Good (high internet, low vulnerability)

#### Scatter Plots (Dots)
- Each dot is one county
- Look for patterns (dots going up-right or down-right)

#### Bar Charts
- Compare categories (Metro vs. Rural)
- Taller bars = higher values

### Key Numbers to Look For

| Metric | Good Value | Bad Value |
|--------|------------|-----------|
| Broadband usage | > 70% | < 30% |
| Download speed | > 100 Mbps | < 25 Mbps |
| SVI score | < 0.3 | > 0.7 |
| CDVI score | < 0 (negative) | > 1 |
| Priority tier | Tier 4 | Tier 1 |

---

## Glossary

| Term | Simple Explanation |
|------|-------------------|
| **ACS** | American Community Survey - census data about households |
| **Broadband** | Fast internet (at least 25 Mbps download) |
| **CDVI** | Composite Digital Vulnerability Index - our main score for how much a county needs help |
| **Census tract** | A small geographic area (smaller than county) |
| **County** | A division of a state (like Cook County in Illinois) |
| **Download speed** | How fast you can get stuff FROM the internet |
| **FCC** | Federal Communications Commission - the government agency that regulates internet |
| **FIPS code** | A 5-digit number that identifies each county |
| **Latency** | The delay when sending data back and forth (measured in milliseconds) |
| **Mbps** | Megabits per second - a measure of internet speed |
| **OLS** | Ordinary Least Squares - a basic statistical method |
| **Ookla** | The company that runs Speedtest.net |
| **R** | A programming language for statistics |
| **RDS** | R Data Serialization - a file format for saving R data |
| **Rmd** | R Markdown - a file that combines text and code |
| **Rural** | Areas far from cities with low population |
| **SAR** | Spatial Autoregressive model - accounts for neighbor effects |
| **SEM** | Spatial Error Model - accounts for geographic patterns in errors |
| **Shapefile** | A file format for geographic/map data |
| **SVI** | Social Vulnerability Index - CDC's measure of community vulnerability |
| **Upload speed** | How fast you can send stuff TO the internet |
| **Urban** | Cities and densely populated areas |
| **USDA** | US Department of Agriculture - provides rural classifications |

---

## Quick Reference Card

### Most Important Files
| File | What It Is |
|------|------------|
| `digital_divide_project.html` | The finished report - OPEN THIS FIRST |
| `digital_divide_project.Rmd` | The main code - edit this to change analysis |
| `outputs/top_20_priority_counties.csv` | List of counties needing most help |

### Most Important Metrics
| Metric | What It Means |
|--------|---------------|
| **Priority Score** | Which counties need help most (higher = more urgent) |
| **CDVI** | How digitally vulnerable a county is |
| **Broadband Gap** | Difference between available internet and actual usage |

### Key Findings (Remember These!)
1. **FCC data overstates coverage** - don't trust it alone
2. **Rural areas have 6x worse internet** than cities
3. **Vulnerable communities get hit hardest** - poverty + bad internet
4. **Big cities have lots of underserved people** too (by total numbers)
5. **Nearby counties cluster together** - regional approaches work best

---

## Need More Help?

1. **Read the README.md** - more technical details
2. **Check PROJECT_CHANGES.md** - history of what was added
3. **Look at the HTML report** - see all the visualizations
4. **Run the code chunk by chunk** - learn by doing!

---

*This guide was created to make data science accessible to everyone. You don't need to be an expert to understand why internet access matters and how we can fix the digital divide!*
