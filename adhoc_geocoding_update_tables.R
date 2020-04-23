library(DBI)
library(RSQLite)
library(tidyverse)

# Create SQLite database
con <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
)

hq_data <- readr::read_csv(
  file = "historical_hq_data_geo_20200423.csv", 
  col_types = cols(
    Action = col_character(),
    Date = col_character(),
    Type = col_character(),
    ApplicationNumber = col_character(),
    BankName = col_character(),
    Location = col_character(),
    City = col_character(),
    State = col_character(),
    County = col_character(),
    EndCmtPd = col_character(),
    Coordinates = col_character()
  )
)

branch_data <- readr::read_csv(
  file = "historical_branch_data_geo_20200423.csv", 
  col_types = cols(
    Action = col_character(),
    Date = col_character(),
    Type = col_character(),
    ApplicationNumber = col_character(),
    BranchName = col_character(),
    Location = col_character(),
    City = col_character(),
    State = col_character(),
    County = col_character(),
    EndCmtPd = col_character(),
    Coordinates = col_character()
  )
)

# Create HQ Table
RSQLite::dbWriteTable(
  conn = con,
  name = "OCCFilingsHQ",
  value = hq_data
)

# Create Branch Table
RSQLite::dbWriteTable(
  conn = con,
  name = "OCCFilingsBranch",
  value = branch_data
)

# Example query
RSQLite::dbGetQuery(
  conn = con,
  statement = "SELECT * FROM OCCFilingsHQ"
) %>% 
  tibble::as_tibble()