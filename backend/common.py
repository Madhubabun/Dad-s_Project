"""Shared helpers for the backend scripts.

Each data source (weather, prices, dam) is fetched by its own script and
saved in its own file in the `site/` folder (a checkout of the `data`
branch). After every run the small `data.json` that the phone downloads is
rebuilt from those files.

If a fetch fails, the last good values are kept and marked "stale", the
error is written down, and the script exits with an error so the GitHub
Actions run shows red (and GitHub emails a failure notice).
"""
import json
import sys
import traceback
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

BACKEND = Path(__file__).resolve().parent
SITE = Path.cwd() / "site"  # the data branch is checked out here
IST = ZoneInfo("Asia/Kolkata")

# Sections that go into data.json, in this order.
SECTIONS = ["weather", "prices", "dam"]
SCHEMA_VERSION = 1


def load_config() -> dict:
    return json.loads((BACKEND / "config.json").read_text(encoding="utf-8"))


def now_ist() -> datetime:
    return datetime.now(IST).replace(microsecond=0)


def read_json(path: Path, default=None):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, ValueError):
        return default


def write_json(path: Path, data, pretty: bool = True) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if pretty:
        text = json.dumps(data, ensure_ascii=False, indent=1)
    else:
        text = json.dumps(data, ensure_ascii=False, separators=(",", ":"))
    path.write_text(text + "\n", encoding="utf-8")


def run_source(name: str, fetch) -> None:
    """Runs `fetch(previous_section)` and saves the result as `name`.json.

    `fetch` returns the new section (a dict). On any exception the previous
    section is kept with status "stale".
    """
    path = SITE / f"{name}.json"
    previous = read_json(path, {}) or {}
    ok = True
    try:
        section = fetch(previous)
        section["status"] = "ok"
        section["last_updated"] = now_ist().isoformat()
        section.pop("last_error", None)
    except Exception as e:  # noqa: BLE001 - any failure must keep old data
        ok = False
        traceback.print_exc()
        section = previous
        section["status"] = "stale"
        section["last_error"] = f"{now_ist().isoformat()}: {type(e).__name__}: {e}"[:300]
    write_json(path, section)
    build_data_json()
    if not ok:
        print(f"::error::{name} fetch failed; kept the last good data as stale.")
        sys.exit(1)


def build_data_json() -> None:
    """Combines the section files into the compact data.json for the phone."""
    data = {"schema": SCHEMA_VERSION}
    for name in SECTIONS:
        section = read_json(SITE / f"{name}.json")
        if section is not None:
            # last_error is for us, not for the phone.
            data[name] = {k: v for k, v in section.items() if k != "last_error"}
    # "version" changes only when the content changes, so the phone can
    # skip work when nothing is new.
    body = json.dumps(data, ensure_ascii=False, sort_keys=True)
    import hashlib

    data["version"] = hashlib.sha1(body.encode("utf-8")).hexdigest()[:12]
    write_json(SITE / "data.json", data, pretty=False)
    size = (SITE / "data.json").stat().st_size
    print(f"data.json is {size} bytes")
    if size > 20_000:
        print("::warning::data.json is over the 20 KB target")
