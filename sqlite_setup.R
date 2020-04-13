library(DBI)
library(RSQLite)

# Create SQLite database
con <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
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

