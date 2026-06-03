# Cloud Migration: MotherDuck + Dagster

This document maps each **local action** in this repo to a **hosted equivalent** when you move off your laptop. No secrets belong in git — use `.env` (from `.env.example`).

## Local → hosted mapping

| Local today | Hosted target |
|-------------|----------------|
| `data/warehouse.duckdb` | MotherDuck database (`md:my_db`) |
| `data/raw/taxi_trips_2024_01.csv` | Object storage (S3/GCS) + Dagster ingest asset |
| `sql/*.sql` | Same SQL executed via `duckdb.connect("md:...")` in Dagster assets |
| `python src/run_pipeline.py` | Dagster job / asset graph + schedule |
| Manual BI export | Dagster asset writes Parquet to bucket, or query MotherDuck directly |
| Metabase + local files | Metabase Cloud + MotherDuck connector |
| GitHub repo (code only) | Same repo; orchestration runs on Dagster Cloud |

## Phase rollout

### Phase 0 — Local demo (current)

- DuckDB file on disk
- CLI pipeline refresh
- Optional Metabase via `data/processed/` exports

### Phase 1 — MotherDuck warehouse

1. Create a [MotherDuck](https://motherduck.com/) account.
2. Copy `.env.example` to `.env` and set `MOTHERDUCK_TOKEN`.
3. Upload or `COPY` raw CSV into MotherDuck (same schema as local).
4. Run the SQL in `sql/` against MotherDuck (minimal changes; paths become cloud URIs).

Example connection swap in Python:

```python
import os
import duckdb

token = os.environ["MOTHERDUCK_TOKEN"]
conn = duckdb.connect(f"md:chicago_taxi?motherduck_token={token}")
```

### Phase 2 — Dagster orchestration

1. Add a `dagster/` package (separate from this demo to keep local runs simple).
2. Model each SQL file as an asset dependency chain.
3. Deploy to [Dagster Cloud](https://dagster.io/cloud) for schedules and observability.

**Do not** use GitHub Actions as your production scheduler for heavy ETL — use Actions for CI/tests only; Dagster Cloud owns production runs.

### Phase 3 — BI on hosted data

- Connect Metabase Cloud to MotherDuck.
- Retire local Parquet uploads for dashboards.

## Dagster asset sketch (pseudocode)

```python
from dagster import asset
import duckdb
import os

@asset
def raw_trips(context) -> None:
    token = os.environ["MOTHERDUCK_TOKEN"]
    conn = duckdb.connect(f"md:chicago_taxi?motherduck_token={token}")
    conn.execute(open("sql/00_load_raw.sql").read().replace(
        "__RAW_CSV_PATH__", "s3://your-bucket/taxi_trips_2024_01.csv"
    ))

@asset(deps=[raw_trips])
def trips_clean() -> None:
    # execute 01_schema.sql ...

@asset(deps=[trips_clean])
def analytics_tables() -> None:
    # execute 02_analytics.sql ...
```

## Environment variables

| Variable | Purpose |
|----------|---------|
| `MOTHERDUCK_TOKEN` | Authenticate to MotherDuck |
| `DAGSTER_CLOUD_API_TOKEN` | Deploy to Dagster Cloud |
| `DAGSTER_CLOUD_ORGANIZATION` | Org slug |
| `DAGSTER_CLOUD_DEPLOYMENT` | Deployment name |

## Raw file storage options

| Option | When to use |
|--------|-------------|
| S3 / GCS bucket | Production; versioned monthly drops |
| MotherDuck `COPY` | Simple migrations from local CSV |
| Dagster IO manager | Managed paths per run |

## CI vs production

| Concern | Tool |
|---------|------|
| Lint / smoke test on PR | GitHub Actions |
| Nightly or hourly refresh | Dagster schedule on Dagster Cloud |
| Ad-hoc backfill | Dagster job rerun |

## Checklist before going live

- [ ] MotherDuck database created and token in secret store
- [ ] Raw data in object storage with stable URI
- [ ] SQL models tested against MotherDuck
- [ ] Dagster assets mirror `sql/` order
- [ ] Metabase connected to MotherDuck (not local files)
- [ ] `.env` and tokens excluded from git (verify `.gitignore`)
