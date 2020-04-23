library(tidyverse)
library(shiny)
# library(shinyWidgets)
library(shinythemes)
# library(shinyjs)
library(RSQLite)
library(DT)

# Create SQLite database
branch_data <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
) %>% 
  # Example query
  RSQLite::dbGetQuery(
    statement = "SELECT * FROM OCCFilingsBranch"
  ) %>% tibble::as_tibble()





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
        style = "font-color: white;"
      ), 
    
    collapsible = T, 
    inverse = T, 
    
    # "App" tab on the navbar ----
    shiny::tabPanel(
      title = "App", 
      value = "nav_page_1", 
      
      shiny::h1(
        "OCC Filings Dashboard"
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
    branch_data
  })
  
}

shinyApp(ui, server)