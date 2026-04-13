# Scraping PSU Women's Basketball Data ----
## Get, Clean, and Organize the data to so that we
## can (eventually) recreate the visualization.

# Step 1: Load Packages ----
## Needed Packages: tidyverse, rvest
# install.packages("rvest")
library(tidyverse)
library(rvest)
library(ggrepel)
# Step 2: Load Data ----
## URLS for the data
### ESPN: https://www.espn.com/womens-college-basketball/team/stats/_/id/213
### PSU: https://gopsusports.com/sports/womens-basketball/roster?view=table

## Step 2A: Get the Data (ESPN) ----
### Step 2A-1: scrape the webpage for tables
espnRawList <- read_html(
  x = "https://www.espn.com/womens-college-basketball/team/stats/_/id/213"
) |>
  html_elements(css = "table") |>
  html_table()

### Step 2A-2: check the list for target tables
# View(espnRawList)

### We need the 1st and 2nd tables
### Step 2A-3: Extract and bind target tables together
espnStatsRaw <- bind_cols(espnRawList[[1]], espnRawList[[2]])

## Step 2B: Get PSU Roster Data ----
### Step 2B-1: scrape the webpage for tables
psuRawList <- read_html(
  x = "https://gopsusports.com/sports/womens-basketball/roster?view=table"
) |>
  html_elements(css = "table") |>
  html_table()

### Step 2B-2: check the list for target tables
# View(psuRawList)

### We need the 1st
### Step 2B-3: Extract the target table
psuRosterRaw <- psuRawList[[1]]

# Step 4: Clean the Data ----
## Step 4A: Wrangle the ESPN Data ----
espnWBBClean <- espnStatsRaw |>
  filter(Name != "Total") |> # Drop Total row
  separate_wider_delim( # Separate out name and position
    cols = Name,
    delim = " ",
    names = c("First", "Last", "positionLetter"),
    too_many = "merge"
  ) |>
  unite( # Merge name pieces back together
    col = "Name",
    First,
    Last,
    sep = " ",
    na.rm = TRUE
  ) |>
  mutate(
    Name = replace_when( # Add special characters to names that ESPN dropped
      Name,
      Name == "Vitoria Santana" ~ "Vitória Santana",
      Name == "Tea Cleante" ~ "Tèa Clèante"
    )
  )

## Step 4B: Wrangling PSU Data ----
psuRosterClean <- psuRosterRaw |>
  # Select only needed columns
  dplyr::select(`# Jersey Number`, Name, Position, Height) |>
  rename("Number" = `# Jersey Number`) |> # Fix improper column name
  separate_wider_delim( # Separate height values
    cols = Height,
    delim = "-",
    names = c("feet", "inches")
  ) |>
  mutate(
    Number = paste0("#", Number), # Format Jersey Number
    Height_in = parse_number(feet)*12 + parse_number(inches), # Calculate heights
    Name = str_squish(Name) # Remove extra spaces in names
  )

# Step 5: Combine Data Frames ----
psuWBB <- full_join(
  x = psuRosterClean, # Use PSU roster as base
  y = espnWBBClean,
  by = join_by(Name == Name)
)
psuPalette <- c()

ggplot(
  data = psuWBB,
  mapping = aes(
    x=Height_in,
    y=PTS,
    shape=Position,
    color = Position,
    label = Number,
  )
) +
  labs(
    title = "Penn State Women's Basketball Points by Height"
  ) +
  geom_point() +
  geom_text_repel()+
  theme_bw()+
  theme(
    legend.position = "bottom"
  )


ggplot(psuWBB) +
  aes(
    x = Height_in,
    y = PTS,
    colour = Position,
    shape = Position,
  ) +
  geom_point() +
  scale_color_hue(direction = 1) +
  theme_minimal()




