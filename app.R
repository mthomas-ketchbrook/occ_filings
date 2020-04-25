library(tidyverse)
library(shiny)
library(shinyWidgets)
library(shinythemes)
# library(shinyjs)
library(RSQLite)
library(DT)
library(plotly)

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
          # DT::DTOutput(outputId = "chl_dt"), 
          # shiny::plotOutput(outputId = "chloropleth_chart"), 
          # shiny::br(), 
          shiny::tabsetPanel(
            id = "tabset_geoms", 
            
            shiny::tabPanel(
              title = "State Level", 
              shiny::br(), 
              shiny::br(), 
              plotly::plotlyOutput(outputId = "chloropleth_plotly")
            ), 
            
            shiny::tabPanel(
              title = "Actual Locations"
            )
            
          )
          
        )
        
      )
      
    ), 
    
    # "About" tab on the navbar ----
    shiny::tabPanel(
      title = "Raw Data", 
      value = "nav_page_2", 
      
      shiny::h1(
        "Data Table of OCC Filings"
      ), 
      
      shiny::div(
        class = "container", 
        DT::DTOutput("branch_dt")
      )
      
    )
    
  )
  
)


# Server ----
server <- function(input, output, session) {
  
  output$branch_dt <- DT::renderDT({
    master_tbl %>% 
      dplyr::filter(
        Date >= input$date_filter[1] & 
          Date <= input$date_filter[2]
      )
  })
  
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
  
  
}

shinyApp(ui, server)