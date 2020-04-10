library(tidyverse)
library(rvest)
library(xml2)


url <- "https://apps.occ.gov/CAAS_CATS/Default.aspx"

sesh <- rvest::html_session(
  url = url#, 
  # httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36")
)

sesh %>% rvest::follow_link(xpath = "//*[(@id = \"CAAS_Content_Search_Button\")]") %>% 
  html_nodes("#CAAS_Content_labelStartDate") %>% 
  html_text()

# sesh %>% 
#   html_nodes("form") %>% 
#   purrr::pluck(3) %>% 
#   html_form()

form <- rvest::html_form(sesh)[[3]]


# Define Filter Criteria --------------------------------------------------

# Date Range Filtering
date_start <- "3/30/2020"
date_end <- "3/30/2020"

# Enter Bank Name
bank_name <- "bank"

# Enter Charter Number
charter_num <- NULL

# Enter OCC Control Number (full or partial)
control_num <- NULL


# Capture the Unfilled Form -----------------------------------------------

# form_unfilled <- sesh %>% rvest::html_node("Form2") %>% html_form()


# Modify the Form ---------------------------------------------------------

filled_form <- rvest::set_values(
  form, 
  `ctl00$CAAS_Content$txtStartDate` = date_start, 
  `ctl00$CAAS_Content$txtEndDate` = date_end
)

new_sesh <- rvest::submit_form(
  session = sesh, 
  form = form, 
  submit = "ctl00$CAAS_Content$Search_Button"
)

new_sesh %>% 
  rvest::html_nodes("CAAS_Content_CAAS_List_GridView") %>% 
  rvest::html_table()




