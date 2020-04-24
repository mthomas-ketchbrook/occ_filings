library(tidyverse)
library(RSQLite)

# Get Branch filings
branch_data <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
) %>% 
  # Example query
  RSQLite::dbGetQuery(
    statement = "SELECT * FROM OCCFilingsBranch"
  ) %>% tibble::as_tibble()

# Get HQ filings
hq_data <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
) %>% 
  # Example query
  RSQLite::dbGetQuery(
    statement = "SELECT * FROM OCCFilingsHQ"
  ) %>% tibble::as_tibble()

RSQLite::dbDisconnect(
  RSQLite::dbConnect(
    drv = RSQLite::SQLite(), 
    "occ-warehouse.sqlite"
  )
)

master_tbl <- branch_data %>% 
  dplyr::left_join(
    hq_data %>% 
      dplyr::select(Date, BankName, ApplicationNumber), 
    by = c("Date", "ApplicationNumber")
  ) %>% 
  unique()



chl_data <- master_tbl %>% 
  dplyr::filter(!is.na(State)) %>% 
  dplyr::mutate(state = tolower(State)) %>% 
  dplyr::count(state, name = "Number of Filings")

ggplot2::ggplot(
  chl_data, 
  ggplot2::aes(fill = `Number of Filings`)
) + 
  ggplot2::geom_map(
    ggplot2::aes(map_id = state), 
    map = m
  ) + 
  ggplot2::expand_limits(
    x = m$long, 
    y = m$lat
  ) + 
  ggplot2::ggtitle(
    glue::glue(
      "Number of Filings by State", 
      .sep = "\n"
    )
  )+ 
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(), 
    axis.text.x = ggplot2::element_blank(), 
    axis.ticks.x = ggplot2::element_blank(), 
    axis.title.y = ggplot2::element_blank(), 
    axis.text.y = ggplot2::element_blank(), 
    axis.ticks.y = ggplot2::element_blank() 
  )
  


