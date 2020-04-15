library(DBI)
library(RSQLite)

# Create SQLite database
con <- RSQLite::dbConnect(
  drv = RSQLite::SQLite(), 
  "occ-warehouse.sqlite"
)

headers_hq <- tibble::tibble(
  Action = character(0), 
  Date = character(0), 
  Type = character(0), 
  ApplicationNumber = character(0), 
  BankName = character(0), 
  Location = character(0), 
  City = character(0), 
  State = character(0), 
  County = character(0), 
  EndCmtPd  = character(0)
)

headers_branch <- tibble::tibble(
  Action = character(0), 
  Date = character(0), 
  Type = character(0), 
  ApplicationNumber = character(0), 
  BranchName = character(0), 
  Location = character(0), 
  City = character(0), 
  State = character(0), 
  County = character(0), 
  EndCmtPd  = character(0)
)

# Create HQ Table
RSQLite::dbWriteTable(
  conn = con, 
  name = "OCCFilingsHQ", 
  value = headers_hq
)

# Create Branch Table
RSQLite::dbWriteTable(
  conn = con, 
  name = "OCCFilingsBranch", 
  value = headers_branch
)

# List tables in the database
RSQLite::dbListTables(conn = con)

# Example query
# RSQLite::dbGetQuery(
#   conn = con, 
#   statement = "SELECT * FROM OCCFilings"
# )

