# Convert SQLite database to .csv file
library(tidyverse)
# library(RSQLite)
library(lubridate)

branch_data <- read.csv(
  file = "data/occ_filings_branch_20200501_thru_20200731.csv"
)

branch_data_slash <- branch_data[1:272, ]

branch_data_hyphen <- branch_data[273:1335, ]

branch_data <- branch_data_slash %>% 
  dplyr::mutate(Date = as.Date(Date, "%m/%d/%Y")) %>% 
  dplyr::bind_rows(
    branch_data_hyphen %>% 
      dplyr::mutate(Date = as.Date(Date))
  )

hq_data <- read.csv(
  file = "data/occ_filings_hq_20200501_thru_20200731.csv"
) %>% 
  dplyr::mutate(Date = as.Date(Date))

data <- branch_data %>% 
  dplyr::left_join(
    hq_data %>%
      dplyr::select(Date, BankName, ApplicationNumber),
    by = c("Date", "ApplicationNumber")
  ) %>%
  unique() %>%
  dplyr::mutate(Date = as.Date(Date)) %>%
  dplyr::arrange(Date) %>% 
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
  )

data %>% 
  write.csv(
    file = "data/occ_filings_20200501_thru_20200731.csv", 
    na = "", 
    row.names = FALSE
  )
