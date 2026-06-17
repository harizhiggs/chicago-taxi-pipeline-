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

## Two-machine workflow (pipeline PC + Metabase PC)

Use this when **Docker is not available** on your main development PC (PATH issues, daemon not starting, or policy blocks) but you have a **second machine** where Docker Desktop works. Run the **full pipeline on the Metabase PC** so Parquet files are generated locally—no need to copy `data/processed/` from the other machine.

### A. Prerequisites on the Metabase PC

- Python 3.10+, Git, [Docker Desktop](https://www.docker.com/products/docker-desktop/) (per-user install is fine on a personal PC)
- Clone the repo to a path **without spaces**, e.g. `C:\dev\chicago-taxi-pipeline`
- After installing Docker: open a **new** terminal, start **Docker Desktop**, and confirm the engine is ready:

```powershell
docker --version
docker info
```

On Windows, optional: `scripts\check-docker.bat` from the repo root.

### B. Reproduce data on that PC

From the repo root:

**Windows:**

```cmd
git pull
scripts\setup.bat
.venv\Scripts\python.exe scripts\verify.py
```

**macOS / Linux:**

```bash
git pull
./scripts/setup.sh
.venv/bin/python scripts/verify.py
```

Expected: `All checks passed.` and four Parquet files under `data/processed/` (the demo uses three analytics tables below).

### C. Start Metabase

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

**Windows:** `scripts\start-metabase.bat` runs the same command after a Docker check.

Open http://localhost:3000 and create a local admin account (not shared; for demo only).

### D. Load data (Metabase UI)

1. In Metabase, use **Upload** (or CSV/Parquet import your build supports).
2. Upload from the **absolute path** to this repo’s `data/processed/` folder:
   - `daily_metrics.parquet`
   - `hourly_demand.parquet`
   - `zone_performance.parquet`

Example (adjust drive and path): `C:\dev\chicago-taxi-pipeline\data\processed\`

If charts are empty, re-run export on that PC:

```cmd
.venv\Scripts\python.exe src\export_for_bi.py
```

### E. Example dashboards

Same questions as [section 3](#3-suggested-dashboards):

| Question | Table | Chart type | Fields |
|----------|-------|------------|--------|
| Daily trip trend | `daily_metrics` | Line | `trip_date`, `trip_count` |
| Peak hours | `hourly_demand` | Bar | `hour_of_day`, `trip_count` |
| Top zones | `zone_performance` | Bar | `pickup_community_area`, `trip_count` |

### F. Portfolio artifacts

Save PNG exports to `docs/screenshots/`:

- `daily_trips_dashboard.png`
- `hourly_demand_dashboard.png`
- `zone_performance_dashboard.png`

PNG files are gitignored by default; commit them only if you change that policy for a public portfolio.

### G. Primary PC without Docker

Pipeline, notebook, and stakeholder memo are enough for the **core** technical demo. Metabase is optional and not blocked—complete steps A–F on the secondary clone when you need live BI dashboards or screenshot artifacts.

## Troubleshooting

- **Container already exists**: `docker rm -f metabase` then re-run the `docker run` command.
- **Port in use**: Change `-p 3001:3000` and open http://localhost:3001.
- **Empty charts**: Re-run `python src/export_for_bi.py` after the pipeline.
