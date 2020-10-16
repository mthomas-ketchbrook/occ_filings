# Convert SQLite database to .csv file
library(tidyverse)
library(RSQLite)
library(lubridate)

source("funs.R")

data <- get_occ_data() %>% 
  dplyr::filter(Date >= max(Date) %m-% days(7))   # Keep only data in last week

readr::write_csv(
  data, 
  path = "current_data.csv"
)