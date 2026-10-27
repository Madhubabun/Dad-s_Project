from datetime import datetime

from common import IST, load_config
from weather import summarise


def raw_forecast(chances, mm):
    """24 hours of today plus 4 more days, in the shape Open-Meteo returns."""
    times = [f"2026-10-27T{h:02d}:00" for h in range(24)]
    return {
        "current": {"precipitation": 0.0, "weather_code": 1},
        "hourly": {
            "time": times,
            "precipitation_probability": chances,
            "precipitation": mm,
            "weather_code": [1] * 24,
            "wind_speed_10m": [10.0] * 24,
        },
        "daily": {
            "time": ["2026-10-27", "2026-10-28", "2026-10-29", "2026-10-30", "2026-10-31"],
            "precipitation_probability_max": [0, 22, 35, 24, 16],
            "precipitation_sum": [0.0, 1.6, 11.5, 0.0, 0.0],
            "weather_code": [3, 55, 81, 1, 3],
        },
    }


NOW = datetime(2026, 10, 27, 10, 20, tzinfo=IST)


def test_no_rain():
    s = summarise(raw_forecast([0] * 24, [0.0] * 24), load_config(), NOW)
    assert s["summary"] == {"kind": "none", "from_hour": None}
    assert [d["date"] for d in s["days"]] == ["2026-10-28", "2026-10-29", "2026-10-30", "2026-10-31"]


def test_heavy_rain_after_4pm_ignores_past_hours():
    chances = [90] * 10 + [10] * 6 + [80] * 8  # rain in the early morning is already over
    mm = [5.0] * 10 + [0.0] * 6 + [3.0] * 8
    s = summarise(raw_forecast(chances, mm), load_config(), NOW)
    assert s["summary"] == {"kind": "heavy", "from_hour": 16}
    assert s["today"]["rain_chance"] == 80
    assert s["today"]["rain_mm"] == 24.0
    assert s["now"]["rain_chance"] == 10


def test_small_chance():
    s = summarise(raw_forecast([40] * 24, [0.1] * 24), load_config(), NOW)
    assert s["summary"]["kind"] == "small"
