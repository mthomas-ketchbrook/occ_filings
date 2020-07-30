# Convert SQLite database to .csv file
library(tidyverse)
library(RSQLite)
library(lubridate)

source("funs.R")

data <- get_occ_data() %>% 
  dplyr::select(
    Action, 
    `Receipt Date` = Date, 
    Type, 
    `Application Number` = ApplicationNumber, 
    `Bank Name` = BankName, 
    `Branch Name` = BranchName, 
    `Branch Address` = Location, 
    City, 
    State, 
    County
  ) %>% 
  dplyr::filter(`Receipt Date` >= as.Date("2020-05-01"))