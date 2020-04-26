library(tidyverse)
library(shiny)
library(shinyWidgets)
library(shinythemes)
# library(shinyjs)
library(RSQLite)
library(DT)
library(plotly)
library(leaflet)

source("funs.R")

master_tbl <- get_occ_data()

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
              shiny::br(), 
              leaflet::leafletOutput(outputId = "bubble_leaflet")
            )
            
          )
          
        )
        
      )
      
    )
    
  )
  
)


# Server ----
server <- function(input, output, session) {
  
  # output$branch_dt <- DT::renderDT({
  #   master_tbl %>% 
  #     dplyr::filter(
  #       Date >= input$date_filter[1] & 
  #         Date <= input$date_filter[2]
  #     )
  # })
  
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
  
  output$chl_dt <- DT::renderDT({
    chloropleth_data()
  })
  
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
  
  
}

shinyApp(ui, server)