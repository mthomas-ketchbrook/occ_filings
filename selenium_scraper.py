from selenium.webdriver import Chrome
import pandas as pd
import numpy as np
from selenium.webdriver.common.keys import Keys
import bs4 as bs
from selenium.webdriver.support.ui import Select

webdriver = "C:/Users/18602/AppData/Local/Programs/Python/Python37/Lib/site-packages/selenium/webdriver/chrome/chromedriver.exe"

driver = Chrome(webdriver)

driver.get('https://apps.occ.gov/CAAS_CATS/Default.aspx')

# Define Parameters
start_date = "3/30/2020"
end_date = "3/30/2020"
bank_name = "bank"
charter_number = ""
occ_control_number = ""
action = "Approved"   # or "All"
state = ""   # or 2-Letter capitalized state abbreviation (e.g., "CT")
hq_or_branch = "1"   # "0" == "Bank Headquarters Location"; "1" == "Branch Location"





# Function to clear a non-blank text box form entry and replace with defined new text
def clear_and_replace_text(xpath, new_text):
  driver.find_element_by_xpath(xpath).clear()
  driver.find_element_by_xpath(xpath).send_keys(new_text)

# Edit Start Date and End Date
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtStartDate')]", start_date)
clear_and_replace_text("//*[(@id = 'CAAS_Content_txtEndDate')]", end_date)

# Fill Bank Name
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtBankName')]").send_keys(bank_name)

# Fill Charter Number (can be Full or Partial)
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtCharter')]").send_keys(charter_number)

# Fill OCC Control Number
driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_txtControl')]").send_keys(occ_control_number)

# Select Action from drop-down list
select = Select(driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_Action_DropDownList')]"))
select.select_by_visible_text(action)

# Select State from drop-down list
select = Select(driver.find_element_by_xpath("//*[(@id = 'CAAS_Content_State_DropDownList')]"))
select.select_by_visible_text(state)

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
df = pd.DataFrame(np.array(data).reshape(num_rows, num_cols), columns = headers)

df.to_csv(r'C:/Users/18602/Desktop/test_selenium.csv', index = False, header = True)
		    



