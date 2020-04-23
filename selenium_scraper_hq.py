from selenium.webdriver import Chrome
import pandas as pd
import numpy as np
from selenium.webdriver.common.keys import Keys
import bs4 as bs
from selenium.webdriver.support.ui import Select
import sqlite3
import datetime
import geopy
from geopy.extra.rate_limiter import RateLimiter

# Estbalish browsing session
webdriver = "C:/Users/18602/AppData/Local/Programs/Python/Python37/Lib/site-packages/selenium/webdriver/chrome/chromedriver.exe"
driver = Chrome(webdriver)
driver.get('https://apps.occ.gov/CAAS_CATS/Default.aspx')

# Get Start & End dates based upon the system date
end_date = datetime.date.today() - datetime.timedelta(days = 1)
end_year = str(end_date.year)
end_month = str(end_date.month)
end_day = str(end_date.day)

# if the system date is Monday, subtract 2 days for the start date
# so that we can capture Friday, Saturday & Sunday data (assuming this script
# only runs on weekdays)
if datetime.date.today().weekday() == 0:
   start_date = datetime.date.today() - datetime.timedelta(days = 3)
else: 
   start_date = end_date

start_year = str(start_date.year)
start_month = str(start_date.month)
start_day = str(start_date.day)

# Format the Start Date & End Date appropriately for website
end_date = end_month + "/" + end_day + "/" + end_year
start_date = start_month + "/" + start_day + "/" + start_year

# Define Parameters
# start_date = "3/1/2020"
# bank_name = "bank"
# charter_number = ""
# occ_control_number = ""
# action = "All"   # or "All"
# state = ""   # or 2-Letter capitalized state abbreviation (e.g., "CT")
hq_or_branch = "0"   # "0" == "Bank Headquarters Location"; "1" == "Branch Location"


# Function to clear a non-blank text box form entry and replace with defined new text
def clear_and_replace_text(xpath, new_text):
  driver.find_element_by_xpath(xpath).clear()
  driver.find_element_by_xpath(xpath).send_keys(new_text)

# Edit Start Date and End Date
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtStartDate')]", start_date)
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtEndDate')]", end_date)

# Fill Bank Name
# driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtBankName')]").send_keys(bank_name)

# Fill Charter Number (can be Full or Partial)
# driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtCharter')]").send_keys(charter_number)

# Fill OCC Control Number
# driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtControl')]").send_keys(occ_control_number)

# Select Action from drop-down list
# select = Select(driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_Action_DropDownList')]"))
# select.select_by_visible_text(action)

# Select State from drop-down list
# select = Select(driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_State_DropDownList')]"))
# select.select_by_visible_text(state)

# Click Radio Button for Headquarters vs. Branch
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_HQorBranchLocation_RadioButtonList_" + hq_or_branch + "')]").click()

# Click the "Search" button
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_Search_Button')]").click()

# Create array containing table header names
headers = []

for row in driver.find_elements_by_css_selector("#CAAS_Content_CAAS_List_GridView"):
    cell = row.find_elements_by_tag_name("th")
    for c in cell:
        headers.append(c.text)

# Create array containing table data
data = []

for row in driver.find_elements_by_css_selector("#CAAS_Content_CAAS_List_GridView"):
	  cell = row.find_elements_by_tag_name("td")
	  for c in cell:
		    data.append(c.text)

# Capture the number of rows of data in the table
num_rows = len(data) / len(headers)
num_rows = int(num_rows)
# Capture the number of column headers in the table
num_cols = len(headers)
num_cols = int(num_cols)

# Create a DataFrame containing the table & data
df1 = pd.DataFrame(np.array(data).reshape(num_rows, num_cols), columns = headers)

# Drop the first column which contains the "Details" links on the web
df1 = df1.drop(df1.columns[[0]], axis = 1)

# Remove whitespace in column names
df1.columns = df1.columns.str.replace(' ', '')

# Create new "FullAddress" temporary column
df1['FullAddress'] = df1['Location'] + "," + df1['City'] + "," + df1['State']

# Set up API calls
locator = geopy.Nominatim(user_agent = "myGeocoder")
geocode = RateLimiter(locator.geocode, min_delay_seconds = 1)

# Get Lat/Lon/Ele data
coords = df1['FullAddress'].apply(geocode)

# Create longitude, latitude and altitude from location column (returns tuple)
coords2 = coords.apply(lambda loc: tuple(loc.point) if loc else None)

# print(coords2)

df1['Coordinates'] = coords2

# Drop the 'FullAddress' temporary column
df1 = df1.drop(df1.columns[[10]], axis = 1)

# Write DataFrame to a .csv
# df1.to_csv(r'C:/Users/18602/Desktop/test_selenium.csv', index = False, header = True)
		    
# Create connection to SQLite db
conn = sqlite3.connect('occ-warehouse.sqlite')

# Write first DataFrame to SQLite database
df1.to_sql(name = 'OCCFilingsHQ', con = conn, if_exists = 'append', index = False)

