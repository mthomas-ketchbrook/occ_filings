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


generate_chloropleth_data <- function(data, state_lookup_tbl, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(Action %in% action_filter) %>%
    dplyr::filter(Date >= date_1 & Date <= date_2) %>%
    dplyr::filter(Type %in% type_filter) %>%
    dplyr::filter(!is.na(State)) %>%
    dplyr::count(State, name = "Filings") %>% 
    dplyr::full_join(
      state_lookup_tbl, 
      by = c("State" = "StateAbb")
    ) %>% 
    dplyr::mutate(Filings = ifelse(is.na(Filings), 0, Filings)) %>% 
    dplyr::rename(StateAbb = State) %>% 
    dplyr::arrange(StateName)
  
}


generate_chloropleth_chart <- function(chloropleth_data) {
  
  plot_data <- chloropleth_data %>% 
    dplyr::mutate(hover = paste(StateName, "<br>", Filings))
  
  # give state boundaries a white border
  l <- list(
    color = plotly::toRGB("white"), 
    width = 2
  )
  
  # specify some map projection/options
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = TRUE,
    lakecolor = plotly::toRGB('white')
  )
  
  plotly::plot_geo(
    plot_data, 
    locationmode = 'USA-states', 
    width = 1000
  ) %>% 
    plotly::add_trace(
      z = ~Filings,
      # text = ~hover, 
      locations = ~StateAbb,
      color = ~Filings, 
      colors = 'Purples'
    ) %>% 
    plotly::colorbar(title = "Number of Filings") %>% 
    plotly::layout(
      title = 'OCC Filings by State',
      geo = g, 
      autosize = F
    )
  
}