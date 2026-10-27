"""Prints raw paddy price data for Raichur district from data.gov.in, so we
can see which markets, commodity names and varieties really appear.

The resource id below is the one listed on data.gov.in for "Current daily
price of various commodities from various markets (Mandi)". This script
checks it: the response's title and field list are printed first.
"""
import json
import os
import sys
from collections import Counter

import requests

KEY = os.environ.get("DATA_GOV_IN_API_KEY", "")
if not KEY:
    print("DATA_GOV_IN_API_KEY secret is not set yet - skipping.")
    sys.exit(0)

RESOURCE = "9ef84268-d588-465a-a308-a864a43d0070"
URL = f"https://api.data.gov.in/resource/{RESOURCE}"


def get(params):
    r = requests.get(URL, params={"api-key": KEY, "format": "json", **params}, timeout=60)
    print("HTTP", r.status_code, "for", {k: v for k, v in params.items()})
    try:
        return r.json()
    except ValueError:
        print(r.text[:1000])
        return {}


# 1. What is this resource, and what are its fields?
first = get({"limit": 2})
print("title:", first.get("title"))
print("updated:", first.get("updated_date"))
print("total records:", first.get("total"))
print("fields:", json.dumps(first.get("field"), indent=1))
print("sample records:", json.dumps(first.get("records"), indent=1, ensure_ascii=False))

# 2. Everything for Raichur district today. Try both filter styles,
#    because the API has used both.
for filters in (
    {"filters[state]": "Karnataka", "filters[district]": "Raichur"},
    {"filters[state.keyword]": "Karnataka", "filters[district]": "Raichur"},
):
    data = get({"limit": 1000, **filters})
    records = data.get("records") or []
    print(f"{len(records)} records with {filters}")
    if not records:
        continue
    print("markets:", Counter(r.get("market") for r in records))
    print("commodities:", Counter(r.get("commodity") for r in records))
    for r in records:
        if "paddy" in str(r.get("commodity", "")).lower() or "rice" in str(r.get("commodity", "")).lower():
            print(json.dumps(r, ensure_ascii=False))
    break

# 3. All Karnataka paddy, to find nearby markets that do report it.
data = get({"limit": 1000, "filters[state]": "Karnataka", "filters[commodity]": "Paddy(Dhan)(Common)"})
records = data.get("records") or []
print(f"{len(records)} Karnataka 'Paddy(Dhan)(Common)' records")
for r in records:
    print(json.dumps(r, ensure_ascii=False))
