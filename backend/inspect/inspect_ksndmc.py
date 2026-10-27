"""Looks at the KSNDMC website to find where daily reservoir levels are
published, and prints what that page looks like (links, tables, text near
'Narayanpur'). Nothing is assumed about the page layout."""
import re

import requests
from bs4 import BeautifulSoup

HEADERS = {"User-Agent": "Mozilla/5.0 (RaitheRaju data check)"}
START_PAGES = ["https://www.ksndmc.org/", "https://ksndmc.org/"]
KEYWORDS = re.compile(r"reservoir|dam|storage|jalashaya|water level|daily report", re.I)
DAM_WORDS = re.compile(r"narayan|basava|almatti", re.I)


def fetch(url):
    try:
        r = requests.get(url, headers=HEADERS, timeout=60)
        print(f"\n===== {url} -> HTTP {r.status_code}, {len(r.content)} bytes, {r.headers.get('content-type')}")
        return r
    except Exception as e:  # noqa: BLE001 - we want to see every failure
        print(f"\n===== {url} -> FAILED: {e}")
        return None


def describe(r):
    soup = BeautifulSoup(r.text, "html.parser")
    print("title:", soup.title.string.strip() if soup.title and soup.title.string else None)
    links = []
    for a in soup.find_all("a", href=True):
        text = " ".join(a.get_text().split())
        if KEYWORDS.search(text) or KEYWORDS.search(a["href"]):
            links.append((text, requests.compat.urljoin(r.url, a["href"])))
    print("interesting links:")
    for text, href in links:
        print(f"  {text!r} -> {href}")
    for i, table in enumerate(soup.find_all("table")):
        rows = table.find_all("tr")
        print(f"table {i}: {len(rows)} rows")
        for row in rows[:4]:
            print("   |", " | ".join(" ".join(c.get_text().split()) for c in row.find_all(["th", "td"])))
        for row in rows:
            if DAM_WORDS.search(row.get_text()):
                print("   DAM ROW |", " | ".join(" ".join(c.get_text().split()) for c in row.find_all(["th", "td"])))
    text = " ".join(soup.get_text().split())
    for m in DAM_WORDS.finditer(text):
        print("  near dam word:", text[max(0, m.start() - 200): m.end() + 300])
    return links


seen = set()
for start in START_PAGES:
    r = fetch(start)
    if r is None or not r.ok:
        continue
    for _, href in describe(r)[:15]:
        if href in seen:
            continue
        seen.add(href)
        sub = fetch(href)
        if sub is not None and sub.ok and "html" in (sub.headers.get("content-type") or ""):
            describe(sub)
    break
