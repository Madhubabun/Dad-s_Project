"""Saves raw copies of web pages into inspect-output/, so they can be studied
offline (the workflow pushes that folder to the `inspect-output` branch).
Usage: python save_pages.py URL [URL ...]"""
import re
import sys
from pathlib import Path

import requests

OUT = Path("inspect-output")
OUT.mkdir(exist_ok=True)
HEADERS = {"User-Agent": "Mozilla/5.0 (RaitheRaju data check)"}

for url in sys.argv[1:]:
    name = re.sub(r"[^A-Za-z0-9]+", "_", url.split("://", 1)[-1]).strip("_")[:120]
    try:
        r = requests.get(url, headers=HEADERS, timeout=60)
        ext = ".pdf" if "pdf" in (r.headers.get("content-type") or "") else ".html"
        (OUT / (name + ext)).write_bytes(r.content)
        (OUT / (name + ".headers.txt")).write_text(
            f"{r.status_code} {r.url}\n" + "\n".join(f"{k}: {v}" for k, v in r.headers.items())
        )
        print("saved", url, r.status_code, len(r.content))
    except Exception as e:  # noqa: BLE001
        (OUT / (name + ".error.txt")).write_text(str(e))
        print("FAILED", url, e)
