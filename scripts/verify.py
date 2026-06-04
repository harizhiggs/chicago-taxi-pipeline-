"""Smoke test: confirm pipeline artifacts exist and contain data."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import duckdb
except ModuleNotFoundError:
    print("Missing dependency: duckdb")
    print("Run setup first, then verify with the project venv:")
    print("  scripts\\setup.bat              # Windows (recommended)")
    print("  ./scripts/setup.sh              # macOS/Linux")
    print("Then: .venv\\Scripts\\python.exe scripts\\verify.py")
    raise SystemExit(1)

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "src"))
from paths import PROCESSED_DIR, WAREHOUSE  # noqa: E402

TABLES = [
    "chicago_taxi.trips",
    "chicago_taxi.trips_clean",
    "chicago_taxi.daily_metrics",
    "chicago_taxi.hourly_demand",
    "chicago_taxi.zone_performance",
]

PARQUET_FILES = [
    "daily_metrics.parquet",
    "hourly_demand.parquet",
    "zone_performance.parquet",
    "trips_clean.parquet",
]


def main() -> int:
    errors: list[str] = []

    if not WAREHOUSE.exists():
        errors.append(f"Warehouse not found: {WAREHOUSE}")
    else:
        conn = duckdb.connect(str(WAREHOUSE), read_only=True)
        try:
            for table in TABLES:
                try:
                    count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                    if count == 0:
                        errors.append(f"{table} is empty")
                    else:
                        print(f"OK  {table}: {count:,} rows")
                except duckdb.CatalogException:
                    errors.append(f"Table missing: {table}")
        finally:
            conn.close()

    for name in PARQUET_FILES:
        path = PROCESSED_DIR / name
        if not path.exists():
            errors.append(f"Parquet not found: {path}")
        else:
            print(f"OK  {path.name}")

    if errors:
        print("\nVerification failed:")
        for err in errors:
            print(f"  - {err}")
        print("\nRun setup first: .\\scripts\\setup.ps1 (Windows) or ./scripts/setup.sh")
        return 1

    print("\nAll checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
