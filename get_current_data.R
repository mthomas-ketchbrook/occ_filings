# Convert SQLite database to .csv file
library(tidyverse)
library(RSQLite)

source("funs.R")

data <- get_occ_data()

readr::write_csv(data, path = "current_data.csv")