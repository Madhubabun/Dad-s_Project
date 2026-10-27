"""Fetches the rain forecast for Masarakal from Open-Meteo (free, no key).

Run every hour. Field names were checked against the live API
(backend/inspect/inspect_weather.py).
"""
import requests

from common import load_config, now_ist, run_source

URL = "https://api.open-meteo.com/v1/forecast"


def fetch_forecast(cfg: dict) -> dict:
    loc = cfg["location"]
    params = {
        "latitude": loc["latitude"],
        "longitude": loc["longitude"],
        "timezone": loc["timezone"],
        "forecast_days": 5,  # today + 4-day outlook
        "current": "precipitation,weather_code,wind_speed_10m",
        "hourly": "precipitation_probability,precipitation,weather_code,wind_speed_10m",
        "daily": "precipitation_probability_max,precipitation_sum,weather_code,wind_speed_10m_max",
    }
    r = requests.get(URL, params=params, timeout=30)
    r.raise_for_status()
    return r.json()


def summarise(raw: dict, cfg: dict, now) -> dict:
    """Turns the raw forecast into the small weather section for data.json.

    The one-line summary is sent as a "kind" plus an hour; the app turns it
    into Telugu or English words, so all wording lives in the app.
    """
    w = cfg["weather"]
    hourly = raw["hourly"]
    today = now.strftime("%Y-%m-%d")
    this_hour = now.strftime("%Y-%m-%dT%H:00")

    # Hours from now until midnight.
    rest = [
        i for i, t in enumerate(hourly["time"]) if t.startswith(today) and t >= this_hour
    ]
    chances = [hourly["precipitation_probability"][i] or 0 for i in rest]
    rain_mm = sum(hourly["precipitation"][i] or 0 for i in rest)
    wind = [hourly["wind_speed_10m"][i] or 0 for i in rest]
    now_chance = chances[0] if chances else 0
    max_chance = max(chances, default=0)

    # First hour when rain becomes likely.
    from_hour = None
    for i in rest:
        if (hourly["precipitation_probability"][i] or 0) >= w["likely_chance"]:
            from_hour = int(hourly["time"][i][11:13])
            break

    if max_chance >= w["likely_chance"]:
        kind = "heavy" if rain_mm >= w["heavy_mm"] else "likely"
    elif max_chance >= w["small_chance"]:
        kind = "small"
    else:
        kind = "none"

    daily = raw["daily"]
    days = []
    for i, date in enumerate(daily["time"]):
        if date <= today:
            continue
        days.append(
            {
                "date": date,
                "rain_chance": daily["precipitation_probability_max"][i] or 0,
                "rain_mm": round(daily["precipitation_sum"][i] or 0, 1),
                "code": daily["weather_code"][i],
            }
        )

    return {
        "now": {
            "rain_chance": now_chance,
            "rain_mm": round(raw.get("current", {}).get("precipitation") or 0, 1),
            "code": raw.get("current", {}).get("weather_code"),
        },
        "today": {
            "rain_chance": max_chance,
            "rain_mm": round(rain_mm, 1),
            "wind_max_kmh": round(max(wind, default=0)),
        },
        "summary": {"kind": kind, "from_hour": from_hour},
        "days": days[:4],
    }


def main() -> None:
    cfg = load_config()
    run_source("weather", lambda _previous: summarise(fetch_forecast(cfg), cfg, now_ist()))


if __name__ == "__main__":
    main()
