"""Calls the two data URLs used by the KSNDMC "Query Interface" page
(found in its HTML) and saves the raw answers to inspect-output/.

  /en/Root/YearlyWeek          -> list of weeks for a year
  /en/QueryInterface/GVReservoir -> FLOW_DATE, PRESENT_STORAGE, RES_LEVEL,
                                    INFLOW, OUTFLOW for one reservoir/week

The page uses a Syncfusion grid; it is not documented which body shape the
server expects, so a few shapes are tried and all answers are saved.
"""
import json
from pathlib import Path

import requests

BASE = "https://ksndmc.org"
OUT = Path("inspect-output")
OUT.mkdir(exist_ok=True)
S = requests.Session()
S.headers["User-Agent"] = "Mozilla/5.0 (RaitheRaju data check)"
S.get(BASE + "/en/QueryInterface", timeout=60)  # pick up any cookies

log = []


def post(path, body, label):
    try:
        r = S.post(BASE + path, json=body, timeout=60)
        text = r.text
        log.append({"label": label, "path": path, "body": body, "status": r.status_code,
                    "type": r.headers.get("content-type"), "answer": text[:20000]})
        print(label, r.status_code, len(text), text[:200].replace("\n", " "))
        return r
    except Exception as e:  # noqa: BLE001
        log.append({"label": label, "path": path, "body": body, "error": str(e)})
        print(label, "FAILED", e)


# Run 1 showed: parameters go at the top level of the body, and the
# reservoir query returns nothing without a week.
r = post("/en/Root/YearlyWeek", {"yr": 2026, "requiresCounts": False}, "weeks-2026")
weeks = [w["Value"] for w in (r.json() if r is not None and r.ok else [])]
print("weeks:", weeks)

# Run 2: top-level parameters with a week still gave nothing. Try the
# "params" shape and the "value" (Syncfusion addParams) shape, and 2025.
import itertools

for name, year, week in itertools.product(
    ["Narayanapura", "Narayanpura", "Alamatti"], [2026, 2025], ["30", "40"]
):
    args = {"CmbR": name, "CmbW": week, "CmbY": year}
    for shape, body in {
        "params": {"requiresCounts": True, "skip": 0, "take": 50, "params": args},
        "both": {"requiresCounts": True, "skip": 0, "take": 50, "params": args, **args},
    }.items():
        post("/en/QueryInterface/GVReservoir", body, f"res-{name}-{year}-w{week}-{shape}")
    # Plain form post, in case the server reads form fields.
    try:
        r = S.post(BASE + "/en/QueryInterface/GVReservoir", data=args, timeout=60)
        log.append({"label": f"form-{name}-{year}-w{week}", "status": r.status_code, "answer": r.text[:3000]})
        print("form", name, year, week, r.status_code, r.text[:200])
    except Exception as e:  # noqa: BLE001
        print("form FAILED", e)
(OUT / "ksndmc_api.json").write_text(json.dumps(log, indent=1, ensure_ascii=False))
