library(DBI)
library(RSQLite)

# Create SQLite database
con <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
)

headers <- data.frame(
  Action = NULL, 
  Date = NULL, 
  Type = NULL,
  `Application Number` = NULL, 
  `Bank Name` = NULL, 
  Location = NULL, 
  City = NULL,
  State = NULL,
  County = NULL, 
  `End Cmt Pd` = NULL
)

RSQLite::dbWriteTable(
  conn = con, 
  name = "mtcars", 
  value = mtcars
)


RSQLite::dbListTables(conn = con)

RSQLite::dbGetQuery(
  conn = con, 
  statement = "SELECT * FROM mtcars"
)

