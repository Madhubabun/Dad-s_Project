"""Gets the Narayanpur (and Almatti) dam levels from KSNDMC's daily
"Reservoir Level and Capacity" report.

How it works (checked against the live site with backend/inspect/):
1. POST /en/Root/GetMGR with the report type and date, the same request the
   "Daily Reports" page makes. The answer holds a link to a PDF.
2. Download the PDF. It has one table, one row per reservoir:
   Sl.No, Name, FRL(m), RL today(m), RL last year(m), FRL(ft), RL today(ft),
   RL last year(ft), Gross capacity(TMC), Storage today(TMC),
   Storage last year(TMC), % full, Inflow(cusecs), Outflow(cusecs),
   Cumulative inflow(TMC), Cumulative outflow(TMC)
3. The date of the data is in the title ("... Flows 27-10-2026"); it can be
   older than the report date, so that date is what the app shows.

Run at about 10:30 AM and again at 5 PM IST.
"""
import html
import io
import re
from datetime import date, datetime, timedelta

import pdfplumber
import requests

from common import load_config, now_ist, run_source

BASE = "https://ksndmc.org"
REPORT_TYPE = "Reservoir Level and Capacity"
HEADERS = {"User-Agent": "Mozilla/5.0 (RaitheRaju farm app; daily dam level)"}
NUMBER = r"(-?\d+(?:\.\d+)?)"


def download_report(day: date) -> str | None:
    """Returns the report text for `day`, or None if KSNDMC has none."""
    s = requests.Session()
    s.headers.update(HEADERS)
    form = {"PType": "Daily", "Category": "Report", "ReportType": REPORT_TYPE,
            "ReportDate": day.isoformat()}
    r = s.post(BASE + "/en/Root/GetMGR", data=form, timeout=60)
    r.raise_for_status()
    answer = r.json()
    if answer.get("result") != "Success" or not answer.get("pdfurl"):
        print(f"No report for {day}: {answer.get('msg')}")
        return None
    url = requests.compat.urljoin(BASE, html.unescape(answer["pdfurl"]))
    pdf = s.get(url, timeout=180)
    pdf.raise_for_status()
    with pdfplumber.open(io.BytesIO(pdf.content)) as doc:
        return "\n".join(page.extract_text() or "" for page in doc.pages)


def parse_report(text: str, dams: list[dict]) -> dict:
    """Finds the data date and the row of each dam in the report text."""
    m = re.search(r"Flows\s+(\d{2})-(\d{2})-(\d{4})", text)
    if not m:
        raise ValueError("data date not found in report")
    data_date = date(int(m[3]), int(m[2]), int(m[1])).isoformat()

    found = []
    for dam in dams:
        row = re.search(
            rf"^\s*\d+\s+[A-Za-z. ]*?{dam['match']}[A-Za-z. ]*?((?:\s+{NUMBER}){{14}})\s*$",
            text,
            re.IGNORECASE | re.MULTILINE,
        )
        if not row:
            print(f"::warning::{dam['id']} not found in the report")
            continue
        n = [float(x) for x in row[1].split()]
        found.append({
            "id": dam["id"],
            "date": data_date,
            "full_level_m": n[0],
            "level_m": n[1],
            "last_year_level_m": n[2],
            "full_storage_tmc": n[6],
            "storage_tmc": n[7],
            "last_year_storage_tmc": n[8],
            "percent": n[9],
            "inflow_cusecs": n[10],
            "outflow_cusecs": n[11],
        })
    if not found:
        raise ValueError("no dam rows found; the report layout may have changed")
    # Sanity checks, so a misread column never reaches Dad's phone.
    for d in found:
        if not (0 <= d["percent"] <= 110 and 0 < d["level_m"] <= d["full_level_m"] + 2):
            raise ValueError(f"values for {d['id']} look wrong: {d}")
    return {"date": data_date, "dams": found}


def fetch(previous: dict) -> dict:
    cfg = load_config()["dam"]
    manual = cfg.get("manual", {})
    if manual.get("enabled"):
        dams = [dict(d, date=manual["date"]) for d in manual["dams"]]
        return {"source": "manual", "dams": dams}

    today = now_ist().date()
    # Today's report first; before it is published, yesterday's.
    for day in (today, today - timedelta(days=1)):
        text = download_report(day)
        if text:
            parsed = parse_report(text, cfg["dams"])
            old_date = max((d.get("date", "") for d in previous.get("dams", [])), default="")
            if parsed["date"] < old_date:
                # Never replace newer data with an older report.
                return {k: v for k, v in previous.items() if k not in ("status", "last_updated")}
            return {"source": "ksndmc", "dams": parsed["dams"]}
    raise RuntimeError("KSNDMC has no reservoir report for today or yesterday")


if __name__ == "__main__":
    run_source("dam", fetch)
