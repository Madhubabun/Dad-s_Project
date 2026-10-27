import pytest

from common import load_config
from dam import parse_report

# Lines copied from the real KSNDMC report of 27-10-2026 (text extracted by
# pdfplumber), shortened to the parts the parser uses.
REPORT = """Report Updated on 27-10-2026 at 04:45 PM
Karnataka State Natural Disaster Monitoring Centre (KSNDMC)
Major Reservoir - Level, Storage, Flows 27-10-2026
11 Malaprabha 633.80 629.39 633.80 2079.50 2065.02 2079.50 37.73 20.91 37.73 55 0 194 18 6
12 Almatti 519.60 516.10 519.57 1704.81 1693.32 1704.70 123.08 74.37 123.08 60 0 275 326 252
13 Narayanapura 492.25 488.74 491.59 1615.00 1603.56 1612.91 33.31 19.73 30.44 59 107 1629 249 249
Krishna Basin 422.45 266.86 392.61 63 0 14436 550 355
"""

DAMS = load_config()["dam"]["dams"]


def test_reads_narayanpur_and_almatti():
    r = parse_report(REPORT, DAMS)
    assert r["date"] == "2026-10-27"
    nar, alm = r["dams"]
    assert nar["id"] == "narayanpur"
    assert nar["level_m"] == 488.74
    assert nar["full_level_m"] == 492.25
    assert nar["storage_tmc"] == 19.73
    assert nar["full_storage_tmc"] == 33.31
    assert nar["percent"] == 59
    assert nar["inflow_cusecs"] == 107
    assert nar["outflow_cusecs"] == 1629
    assert alm["id"] == "almatti" and alm["percent"] == 60


def test_data_date_comes_from_title_not_report_date():
    # The 24-10 report really contained data of 19-10.
    text = REPORT.replace("Flows 27-10-2026", "Flows 19-10-2026")
    assert parse_report(text, DAMS)["date"] == "2026-10-19"


def test_changed_layout_is_an_error_not_wrong_numbers():
    with pytest.raises(ValueError):
        parse_report("Major Reservoir - Level, Storage, Flows 27-10-2026\nnothing here", DAMS)
    broken = REPORT.replace("488.74", "4887.4")
    with pytest.raises(ValueError):
        parse_report(broken, DAMS)
