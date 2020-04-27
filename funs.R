# Function to load data from SQLite database
get_occ_data <- function() {
  
  con <- RSQLite::dbConnect(
    drv = RSQLite::SQLite(), 
    "occ-warehouse.sqlite"
  )
  
  print("Connected to SQLite database")
  
  # Get Branch filings
  branch_data <- RSQLite::dbGetQuery(
    conn = con, 
    statement = "SELECT * FROM OCCFilingsBranch"
  ) %>% tibble::as_tibble()
  
  # Get HQ filings
  hq_data <- RSQLite::dbGetQuery(
    conn = con, 
    statement = "SELECT * FROM OCCFilingsHQ"
  ) %>% tibble::as_tibble()
  
  RSQLite::dbDisconnect(conn = con)
  
  print("Disconnected from SQLite database")
  
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


generate_DT_data <- function(data, state_lookup_tbl, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(Action %in% action_filter) %>%
    dplyr::filter(Date >= date_1 & Date <= date_2) %>%
    dplyr::filter(Type %in% type_filter) %>% 
    dplyr::mutate(CoordsAvail = ifelse(is.na(Coordinates), "No", "Yes")) %>% 
    dplyr::rename(`Coordinates Available` = CoordsAvail) %>% 
    dplyr::select(Date, Action, Type, BankName, Location, City, State, `Coordinates Available`)
  
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
    showlakes = F
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
      colors = 'Blues'
    ) %>% 
    plotly::colorbar(title = "Number of Filings") %>% 
    plotly::layout(
      title = 'OCC Filings by State',
      geo = g, 
      autosize = F
    )
  
}


generate_bubble_data <- function(data, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(!is.na(Coordinates)) %>% 
    dplyr::filter(Action %in% action_filter) %>%
    dplyr::filter(Date >= date_1 & Date <= date_2) %>%
    dplyr::filter(Type %in% type_filter) %>%
    dplyr::mutate(
      lat = stringr::str_extract(
        string = Coordinates, 
        pattern = "(?<=[(])(.*?)(?=,)"   # extract everything after the "(" and before the ","
      ) %>% as.numeric(), 
      lon = stringr::str_extract(
        string = Coordinates, 
        pattern = "(?<=, )(.*?)(?=[,])"   # extract everything after the ", " and before the ")"
      ) %>% as.numeric()
    ) %>% 
    dplyr::select(Action, Type, Date, BankName, lat, lon)
  
}


generate_bubble_labels <- function(data) {
  
  sprintf(
    "<strong>%s</strong><br/>%s<br/>%s<br/>Filed On: %s",
    data$BankName, data$Action, data$Type, data$Date
  ) %>% lapply(shiny::HTML)
  
}
  

generate_trend_data <- function(data, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(Action %in% action_filter) %>%
    dplyr::filter(Date >= date_1 & Date <= date_2) %>%
    dplyr::filter(Type %in% type_filter) %>% 
    dplyr::count(Date, Type, name = "Number of Filings")
  
}


generate_trend_chart <- function(data) {
  
  p <- data %>% 
    dplyr::rename(`Filing Type` = Type) %>% 
    ggplot2::ggplot(
      ggplot2::aes(
        x = Date, 
        y = `Number of Filings`, 
        fill = `Filing Type`
      )
    ) + 
    ggplot2::geom_col(
      alpha = 0.7
    ) + 
    ggplot2::scale_fill_brewer(palette = "Set3") + 
    ggplot2::xlab("") + 
    ggplot2::ggtitle("Number of Filings by Date") +
    ggthemes::theme_economist()

  plotly::ggplotly(p)
  
}


generate_bar_data <- function(data, action_filter, date_1, date_2, type_filter) {
  
  data %>% 
    dplyr::filter(Action %in% action_filter) %>%
    dplyr::filter(Date >= date_1 & Date <= date_2) %>%
    dplyr::filter(Type %in% type_filter) %>% 
    dplyr::count(Action, Type, name = "Number of Filings")
  
}


generate_bar_chart <- function(data) {
  
  p <- data %>% 
    dplyr::rename(`Filing Type` = Type) %>% 
    ggplot2::ggplot(
      ggplot2::aes(
        x = `Filing Type`, 
        y = `Number of Filings`, 
        fill = Action
      )
    ) + 
    ggplot2::geom_col(
      alpha = 0.7
    ) + 
    ggplot2::scale_fill_brewer(palette = "Set3") + 
    ggplot2::xlab("") + 
    ggplot2::ggtitle("Number of Filings by Action & Filing Type") + 
    ggplot2::coord_flip() + 
    ggthemes::theme_economist()
  
  plotly::ggplotly(p)
  
}