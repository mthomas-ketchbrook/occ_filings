# Function to load data from SQLite database
get_occ_data <- function() {
  
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
  
  branch_data %>% 
    dplyr::left_join(
      hq_data %>% 
        dplyr::select(Date, BankName, ApplicationNumber), 
      by = c("Date", "ApplicationNumber")
    ) %>% 
    unique() %>% 
    dplyr::mutate(Date = as.Date(Date)) %>% 
    dplyr::arrange(Date)
  
}


generate_chloropleth_data <- function(data, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(Action %in% action_filter) %>% 
    dplyr::filter(Date >= date_1 & Date <= date_2) %>% 
    dplyr::filter(Type %in% type_filter) %>% 
    dplyr::filter(!is.na(State)) %>% 
    dplyr::mutate(state = tolower(State)) %>%
    dplyr::count(state, name = "Number of Filings")
  
}


generate_chloropleth_chart <- function(chloropleth_data, gg_data) {
  
  p <- ggplot2::ggplot(
    chloropleth_data, 
    ggplot2::aes(fill = `Number of Filings`)
  ) + 
    ggplot2::geom_map(
      ggplot2::aes(map_id = state), 
      map = gg_data
    ) + 
    ggplot2::expand_limits(
      x = gg_data$long, 
      y = gg_data$lat
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
  
  p <- plotly::ggplotly(p)
  
  return(p)
  
}