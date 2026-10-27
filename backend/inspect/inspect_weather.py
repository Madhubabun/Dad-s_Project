"""Prints the raw Open-Meteo forecast for Masarakal, so we can see the real
field names before writing the weather script."""
import json

import requests

URL = "https://api.open-meteo.com/v1/forecast"
PARAMS = {
    "latitude": 16.3694,
    "longitude": 77.0172,
    "timezone": "Asia/Kolkata",
    "forecast_days": 5,
    "current": "precipitation,weather_code,wind_speed_10m",
    "hourly": "precipitation_probability,precipitation,weather_code,wind_speed_10m",
    "daily": "precipitation_probability_max,precipitation_sum,weather_code,wind_speed_10m_max",
}

r = requests.get(URL, params=PARAMS, timeout=30)
print("HTTP", r.status_code)
data = r.json()
# Hourly lists are long: show only the first 6 hours of each.
for key, values in data.get("hourly", {}).items():
    data["hourly"][key] = values[:6]
print(json.dumps(data, indent=1, ensure_ascii=False))
