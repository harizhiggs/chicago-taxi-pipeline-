"""Generate synthetic Chicago taxi trips for local demo (Jan 2024)."""

from __future__ import annotations

import argparse
import random
import sys
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from paths import DEFAULT_RAW_CSV

COLUMNS = [
    "trip_id",
    "taxi_id",
    "trip_start_timestamp",
    "trip_end_timestamp",
    "trip_seconds",
    "trip_miles",
    "fare",
    "tips",
    "tolls",
    "extras",
    "payment_type",
    "company",
    "pickup_community_area",
    "dropoff_community_area",
]

PAYMENT_TYPES = ["Credit Card", "Cash", "Mobile", "Pcard", "Unknown"]
COMPANIES = [
    "Flash Cab",
    "Taxi Affiliation Services",
    "Chicago Independents",
    "Sun Taxi",
    "City Service",
]

# Common Chicago community areas (subset for realistic zones)
ZONES = list(range(1, 78))


def _random_trip_start(rng: random.Random, year: int, month: int) -> datetime:
    day = rng.randint(1, 28)
    hour_weights = [1] * 6 + [3] * 4 + [5] * 4 + [4] * 4 + [6] * 4 + [3] * 2
    hour = rng.choices(range(24), weights=hour_weights, k=1)[0]
    minute = rng.randint(0, 59)
    second = rng.randint(0, 59)
    return datetime(year, month, day, hour, minute, second)


def generate_trips(n_rows: int, seed: int = 42) -> pd.DataFrame:
    rng = random.Random(seed)
    rows: list[dict] = []

    for i in range(n_rows):
        start = _random_trip_start(rng, 2024, 1)
        miles = round(rng.uniform(0.5, 15.0), 2)
        seconds = max(60, int(miles * rng.uniform(180, 420)))
        end = start + timedelta(seconds=seconds)
        fare = round(max(3.25, 2.25 + miles * rng.uniform(2.0, 3.5)), 2)
        tips = round(fare * rng.choice([0, 0, 0.15, 0.18, 0.2]), 2)
        pickup = rng.choice(ZONES)
        dropoff = rng.choice(ZONES)

        rows.append(
            {
                "trip_id": f"DEMO-{i + 1:06d}",
                "taxi_id": f"TAXI-{rng.randint(1, 500):04d}",
                "trip_start_timestamp": start.strftime("%Y-%m-%d %H:%M:%S"),
                "trip_end_timestamp": end.strftime("%Y-%m-%d %H:%M:%S"),
                "trip_seconds": seconds,
                "trip_miles": miles,
                "fare": fare,
                "tips": tips,
                "tolls": round(rng.choice([0, 0, 0, 1.5, 2.0]), 2),
                "extras": round(rng.choice([0, 0, 0.5, 1.0]), 2),
                "payment_type": rng.choice(PAYMENT_TYPES),
                "company": rng.choice(COMPANIES),
                "pickup_community_area": pickup,
                "dropoff_community_area": dropoff,
            }
        )

    return pd.DataFrame(rows, columns=COLUMNS)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate sample taxi trip CSV.")
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_RAW_CSV,
        help="Output CSV path",
    )
    parser.add_argument(
        "--rows",
        type=int,
        default=2000,
        help="Number of synthetic trips",
    )
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    df = generate_trips(args.rows, seed=args.seed)
    df.to_csv(args.output, index=False)
    print(f"Wrote {len(df):,} rows to {args.output}")


if __name__ == "__main__":
    main()
