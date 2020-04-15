import sqlite3

conn = sqlite3.connect('occ-warehouse.sqlite')

c = conn.cursor()

# c.execute("SELECT * FROM OCCFilings")

def sql_fetch(con):

    cursorObj = con.cursor()

    cursorObj.execute('SELECT name from sqlite_master where type= "table"')

    print(cursorObj.fetchall())

sql_fetch(conn)

print(c.fetchall())

for row in c.execute('SELECT * FROM OCCFilingsBranch'):
    print(row)
    
for row in c.execute('SELECT * FROM OCCFilingsHQ'):
    print(row)
