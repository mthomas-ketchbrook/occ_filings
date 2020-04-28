library(tidyverse)
library(shiny)
library(shinyWidgets)
library(shinythemes)
# library(RSQLite)
library(DT)
library(plotly)
library(leaflet)
library(ggthemes)
library(glue)
library(maps)

source("funs.R")

# master_tbl <- get_occ_data()

master_tbl <- readr::read_csv(
  file = "https://raw.githubusercontent.com/mthomas-ketchbrook/occ_filings/master/current_data.csv"
)

gg_data <- ggplot2::map_data("state")

state_lookup_tbl <- tibble::tibble(
  StateAbb = state.abb, 
  StateName = state.name
)

# UI ----
ui <- shiny::fluidPage(
  
  theme = shinythemes::shinytheme(theme = "spacelab"), 
  
  title = "OCC Filings Dashboard", 
  
  shiny::navbarPage(
    
    # Set the navbar title, embedded with hyperlink to Ketchbrook website
    title = "Ketchbrook Analytics" %>% 
      shiny::a(
        href = "https://www.ketchbrookanalytics.com/", 
        target = "_blank", 
        style = "color: white;"
      ), 
    
    collapsible = T, 
    inverse = T, 
    
    # "App" tab on the navbar ----
    shiny::tabPanel(
      title = "App", 
      value = "nav_page_1", 
      
      shiny::h1(
        "OCC Filings Dashboard"
      ), 
      
      shiny::hr(), 
      
      shiny::fluidRow(
        
        shiny::column(
          width = 4, 
          
          shiny::wellPanel(
            shiny::dateRangeInput(
              inputId = "date_filter", 
              label = "Set Start & End Dates", 
              start = min(master_tbl$Date), 
              end = max(master_tbl$Date)
            ), 
            shinyWidgets::pickerInput(
              inputId = "action_filter", 
              label = "Select an Action Type", 
              choices = unique(master_tbl$Action), 
              selected = "Consummated/Effective", 
              multiple = T
            ), 
            shinyWidgets::pickerInput(
              inputId = "type_filter", 
              label = "Select a Filing Type", 
              choices = unique(master_tbl$Type), 
              selected = "Branch Closings", 
              multiple = T
            )
          ), 
          
          shiny::wellPanel(
            shiny::p(
              class = "lead", 
              "Notes about this Page:"
            ), 
            shiny::p(
              "After altering a map visual, double-clicking anywhere on the map will return it to the default zoom."
            ), 
            shiny::p(
              "Only data where the value for `Coordinates Available` is marked \"Yes\" (in the table below) will display in the map on the ", 
              shiny::strong("Actual Locations"), 
              "tab."
            ), 
            shiny::span(
              glue::glue(
                "Data is available from", 
                "{format(min(as.Date(master_tbl$Date)), \"%b %d, %Y\")}", 
                "through", 
                "{format(max(as.Date(master_tbl$Date)), \"%b %d, %Y\")}.", 
                "For additional history, please contact", 
                .sep = " "
              ), 
              shiny::a(
                href = "mailto:info@ketchbrookanalytics.com", 
                target = "_blank", 
                "Ketchbrook Analytics."
              )
            )
            
          )
          
        ), 
        
        shiny::column(
          width = 8, 
          
          shiny::tabsetPanel(
            id = "tabset_geoms", 
            
            shiny::tabPanel(
              title = "State Level", 
              shiny::br(), 
              shiny::br(), 
              plotly::plotlyOutput(outputId = "chloropleth_plotly")
            ), 
            
            shiny::tabPanel(
              title = "Actual Locations", 
              shiny::br(), 
              leaflet::leafletOutput(outputId = "bubble_leaflet")
            ), 
            
            shiny::tabPanel(
              title = "Trend", 
              shiny::br(), 
              plotly::plotlyOutput(outputId = "trend_chart")
            ), 
            
            shiny::tabPanel(
              title = "Count", 
              shiny::br(), 
              plotly::plotlyOutput(outputId = "bar_chart")
            )
            
          )
          
        )
        
      ), 
      
      shiny::br(), 
      shiny::hr(), 
      
      shiny::fluidRow(
        
        DT::DTOutput(outputId = "dt_main")
        
      ), 
      
      shiny::br(), 
      shiny::br()
      
    ), 
    
    shiny::tabPanel(
      title = "About", 
      value = "nav_page_2", 
      
      # JumboTron Ad for Ketchbrook ----
      shiny::fluidRow(
        shiny::div(
          class = "jumbotron", 
          shiny::h1("Enjoying This App?"), 
          shiny::p(
            class = "lead", 
            "Check out what else Ketchbrook Analytics can do for you."
          ), 
          shiny::a(
            class = "btn btn-primary btn-lg", 
            href = "https://www.ketchbrookanalytics.com/", 
            target = "_blank", 
            "Visit Us"
          )
        )
      ), 
      
      shiny::fluidRow(
        
        shiny::column(
          width = 12, 
          class = "well", 
          
          shiny::p(
            class = "lead", 
            "About this Application"
          ), 
          
          shiny::span(
            paste(
              "The data displayed in this application uses data made publicly available by the Office of the Comptroller of the Currency. ", 
              "You can find the public filings "
            ), 
            shiny::a(
              href = "https://apps.occ.gov/CAAS_CATS/CAAS_List.aspx", 
              target = "_blank", 
              "here."
            )
          )
        )
        
      )
      
    )
    
  )
  
)


# Server ----
server <- function(input, output, session) {
  
  dt_data <- shiny::reactive({
    generate_DT_data(
      data = master_tbl, 
      action_filter = input$action_filter, 
      type_filter = input$type_filter, 
      date_1 = input$date_filter[1], 
      date_2 = input$date_filter[2]
    )
  })
  
  output$dt_main <- DT::renderDT(
    dt_data(), 
    filter = "top", 
    options = list(scrollx = TRUE), 
    rownames = FALSE
  )
  
  chloropleth_data <- shiny::reactive({
    generate_chloropleth_data(
      data = master_tbl, 
      state_lookup_tbl = state_lookup_tbl, 
      action_filter = input$action_filter, 
      type_filter = input$type_filter, 
      date_1 = input$date_filter[1], 
      date_2 = input$date_filter[2]
    )
  })
  
  # output$chl_dt <- DT::renderDT({
  #   chloropleth_data()
  # })
  
  output$chloropleth_plotly <- plotly::renderPlotly({
    generate_chloropleth_chart(
      chloropleth_data = chloropleth_data()
    )
  })
  
  bubble_data <- shiny::reactive({
    generate_bubble_data(
      data = master_tbl, 
      action_filter = input$action_filter, 
      type_filter = input$type_filter, 
      date_1 = input$date_filter[1], 
      date_2 = input$date_filter[2]
    )
  })
  
  bubble_labels <- shiny::reactive({
    generate_bubble_labels(data = bubble_data())
  })
  
  output$bubble_leaflet <- leaflet::renderLeaflet({
    
    shiny::validate(
      
      shiny::need(
        input$action_filter, 
        message = "No data to display"
      ), 
      
      shiny::need(
        input$type_filter, 
        message = "No data to display"
      )
      
    )
    
    leaflet::leaflet() %>% 
      leaflet::addProviderTiles(provider = providers$Esri) %>% 
      leaflet::addCircleMarkers(
        data = bubble_data(),
        lng = ~lon, 
        lat = ~lat, 
        weight = 10, 
        radius = 5,
        label = bubble_labels()
      )
  })
  
  trend_data <- shiny::reactive({
    generate_trend_data(
      data = master_tbl, 
      action_filter = input$action_filter, 
      type_filter = input$type_filter, 
      date_1 = input$date_filter[1], 
      date_2 = input$date_filter[2]
    )
  })
  
  output$trend_chart <- plotly::renderPlotly({
    generate_trend_chart(data = trend_data())
  })
  
  bar_data <- shiny::reactive({
    generate_bar_data(
      data = master_tbl, 
      action_filter = input$action_filter, 
      type_filter = input$type_filter, 
      date_1 = input$date_filter[1], 
      date_2 = input$date_filter[2]
    )
  })
  
  output$bar_chart <- plotly::renderPlotly({
    generate_bar_chart(data = bar_data())
  })
  
}

shiny::shinyApp(ui = ui, server = server)