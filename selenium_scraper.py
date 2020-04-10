from selenium.webdriver import Chrome
import pandas as pd
import numpy as np
from selenium.webdriver.common.keys import Keys
import bs4 as bs

webdriver = "C:/Users/18602/AppData/Local/Programs/Python/Python37/Lib/site-packages/selenium/webdriver/chrome/chromedriver.exe"

driver = Chrome(webdriver)

driver.get('https://apps.occ.gov/CAAS_CATS/Default.aspx')

# Define Parameters
start_date = "3/30/2020"
end_date = "3/30/2020"
bank_name = "bank"


# Function to clear a non-blank text box form entry and replace with defined new text
def clear_and_replace_text(xpath, new_text):
  driver.find_element_by_xpath(xpath).clear()
  driver.find_element_by_xpath(xpath).send_keys(new_text)

# Edit Start Date and End Date
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtStartDate')]", start_date)
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtEndDate')]", end_date)

# Fill Bank Name
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtBankName')]").send_keys(bank_name)

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
df = pd.DataFrame(np.array(data).reshape(num_rows, num_cols), columns = headers)

df.to_csv(r'C:/Users/18602/Desktop/test_selenium.csv', index = False, header = True)
		    



