import pandas as pd
import numpy as np
import datetime
import geopy
from geopy.extra.rate_limiter import RateLimiter

df1 = pd.read_csv("historical_hq_data_20200423.csv")

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
df1.to_csv("historical_hq_data_geo_20200423.csv", index = False, header = True)

print("Success")
