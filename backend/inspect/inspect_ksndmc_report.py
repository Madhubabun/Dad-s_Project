"""Asks KSNDMC for the daily "Reservoir Level and Capacity" report the same
way its Daily Reports page does (POST /en/Root/GetMGR), and saves the
answer and the PDF it points to into inspect-output/."""
import json
from datetime import date, timedelta
from pathlib import Path

import requests

BASE = "https://ksndmc.org"
OUT = Path("inspect-output")
OUT.mkdir(exist_ok=True)
S = requests.Session()
S.headers["User-Agent"] = "Mozilla/5.0 (RaitheRaju data check)"
S.get(BASE + "/en/Reports/Daily", timeout=60)

answers = []
for back in range(0, 4):
    day = (date.today() - timedelta(days=back)).isoformat()
    form = {"PType": "Daily", "Category": "Report",
            "ReportType": "Reservoir Level and Capacity", "ReportDate": day}
    r = S.post(BASE + "/en/Root/GetMGR", data=form, timeout=60)
    print(day, r.status_code, r.text[:300])
    answers.append({"day": day, "status": r.status_code, "answer": r.text[:3000]})
    try:
        res = r.json()
    except ValueError:
        continue
    url = res.get("pdfurl") if isinstance(res, dict) else None
    if url:
        url = requests.compat.urljoin(BASE, url)
        pdf = S.get(url, timeout=120)
        print("  pdf", url, pdf.status_code, pdf.headers.get("content-type"), len(pdf.content))
        (OUT / f"reservoir_{day}.pdf").write_bytes(pdf.content)
        answers[-1]["pdfurl"] = url

(OUT / "ksndmc_report.json").write_text(json.dumps(answers, indent=1, ensure_ascii=False))
