library(tidyverse)
library(rvest)
library(xml2)


url <- "https://apps.occ.gov/CAAS_CATS/Default.aspx"

sesh <- rvest::html_session(url = url)

form <- rvest::html_form(
  xml2::read_html(url)
)[[3]]


# Define Filter Criteria --------------------------------------------------

# Date Range Filtering
date_start <- "3/20/2020"
date_end <- "3/30/2020"

# Bank Name Filtering
bank_name <- "bank"

charter_num <- NULL

# Modify the form
rvest::set_values(
  form, 
  `ctl00$CAAS_Content$txtBankName` = bank_name, 
  `ctl00$CAAS_Content$txtStartDate` = date_start, 
  `ctl00$CAAS_Content$txtEndDate` = date_end, 
  `ctl00$CAAS_Content$txtCharter` = charter_num
)




