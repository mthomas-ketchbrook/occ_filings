# Convert SQLite database to .csv file
library(tidyverse)
library(RSQLite)
library(lubridate)

source("funs.R")

data <- get_occ_data() %>% 
  dplyr::filter(Date >= max(Date) %m-% months(1))   # Keep only data in last month

readr::write_csv(
  data, 
  path = "current_data.csv"
)