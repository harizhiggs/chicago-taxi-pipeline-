# Metabase Local Setup

Metabase provides a browser-based BI layer for this project. Local DuckDB connectivity in Metabase OSS is limited, so this demo uses **exported Parquet files** from the pipeline.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- Pipeline has been run: `python src/run_pipeline.py --generate`
- BI exports generated: `python src/export_for_bi.py`

## 1. Start Metabase

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

Open http://localhost:3000 and complete the initial admin setup.

## 2. Connect to processed data (recommended for local demo)

1. In Metabase, add a new database.
2. Choose **Upload a CSV** or connect a database that can read files on disk, depending on your Metabase version.
3. Alternatively, upload the Parquet/CSV exports from `data/processed/`:
   - `daily_metrics.parquet`
   - `hourly_demand.parquet`
   - `zone_performance.parquet`

If your Metabase build supports folder-based imports, point it at the project's `data/processed/` directory (use an absolute path on your machine).

## 3. Suggested dashboards

| Question | Table | Chart type |
|----------|-------|------------|
| How do daily trips trend? | `daily_metrics` | Line chart (`trip_date`, `trip_count`) |
| When is demand highest? | `hourly_demand` | Bar chart (`hour_of_day`, `trip_count`) |
| Which zones drive volume? | `zone_performance` | Bar chart (`pickup_community_area`, `trip_count`) |

## 4. Portfolio screenshots

Save PNG exports to `docs/screenshots/`:

- `daily_trips_dashboard.png`
- `hourly_demand_dashboard.png`
- `zone_performance_dashboard.png`

## 5. Hosted path (later)

When you migrate to MotherDuck, use **Metabase Cloud** with the MotherDuck connector instead of local file uploads. See [`cloud-migration-motherduck-dagster.md`](cloud-migration-motherduck-dagster.md).

## Troubleshooting

- **Container already exists**: `docker rm -f metabase` then re-run the `docker run` command.
- **Port in use**: Change `-p 3001:3000` and open http://localhost:3001.
- **Empty charts**: Re-run `python src/export_for_bi.py` after the pipeline.
