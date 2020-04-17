library(tidyverse)
library(RSocrata)

ct_farms <- RSocrata::read.socrata(url = "https://data.ct.gov/resource/hma6-9xbg.csv")

new <- ct_farms %>% 
  tibble::as_tibble() %>% 
  dplyr::mutate(
    farm_name = ifelse(farm_name == "", NA, farm_name), 
    category = stringr::str_to_title(category), 
    item = stringr::str_to_title(item), 
    zipcode = substr(zipcode, 1, 5), 
    location_1 = stringr::str_split(location_1, pattern = "\n")
  ) %>% 
  dplyr::mutate(
    category = dplyr::case_when(
      category == "Commercialkitchen" ~ "Commercial Kitchen", 
      category == "Csa" ~ "CSA", 
      category == "Cutflowers" ~ "Cut Flowers", 
      category == "Farmerpledge" ~ "Farmers Pledge", 
      category == "Farmproducts" ~ "Farm Products", 
      category == "Maplesyrup" ~ "Maple Syrup", 
      category == "Nursery" ~ "Nursery/Greenhouse", 
      TRUE ~ category
    )
  )
  
