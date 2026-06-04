# Chicago Taxi Demand & Performance Analytics

End-to-end local analytics pipeline: ingest taxi trip data, model it in DuckDB, analyze in Python/SQL, and export artifacts for dashboards and stakeholder memos. Built as a portfolio demo with a clear path to **MotherDuck + Dagster** when hosted.

## Quick start

**Prerequisites:** Python 3.10+, pip

**Tip (Windows):** Clone into a path **without spaces** (e.g. `C:\dev\chicago-taxi-pipeline`) to avoid venv issues. See [Troubleshooting](docs/troubleshooting.md).

### One-command setup

**Windows (recommended — works when PowerShell blocks `.ps1` scripts):**

```cmd
scripts\setup.bat
.\.venv\Scripts\python.exe scripts\verify.py
```

**Windows (PowerShell, if scripts are allowed):**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
.\.venv\Scripts\python.exe scripts\verify.py
```

**macOS / Linux:**

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
python scripts/verify.py
```

### Manual setup

```bash
# From project root (use venv Python directly on Windows if Activate.ps1 is blocked)
python -m venv .venv
.venv\Scripts\python.exe -m pip install --upgrade pip    # Windows
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe -m pip install "duckdb>=1.0.0,<2.0.0"
.venv\Scripts\python.exe src\run_pipeline.py --generate
.venv\Scripts\python.exe src\export_for_bi.py
.venv\Scripts\python.exe scripts\verify.py
```

Expected result from `verify.py`: five warehouse tables with rows and four Parquet files in `data/processed/`.

### Jupyter notebook

After the pipeline runs, register the venv as a notebook kernel:

**Windows:**

```cmd
scripts\register_notebook_kernel.bat
```

**macOS / Linux:**

```bash
chmod +x scripts/register_notebook_kernel.sh
./scripts/register_notebook_kernel.sh
```

Open `notebooks/exploration.ipynb` in Cursor or VS Code, then in the **kernel picker** (top-right) choose **Chicago Taxi (.venv)**.

If it does not appear: `Ctrl+Shift+P` → **Notebook: Select Notebook Kernel** → **Chicago Taxi (.venv)** or **Python Environments** → `.venv`. Reload the window if the list is stale.

See [Troubleshooting — Jupyter](docs/troubleshooting.md#jupyter-notebook) if the kernel still will not connect.

## What the pipeline does

```text
data/raw/taxi_trips_2024_01.csv
        ↓  sql/00_load_raw.sql
chicago_taxi.trips
        ↓  sql/01_schema.sql
chicago_taxi.trips_clean
        ↓  sql/02_analytics.sql
daily_metrics · hourly_demand · zone_performance
        ↓  src/export_for_bi.py
data/processed/*.parquet  →  Metabase / BI
```

## Project structure

```text
data/
  raw/              # Raw CSV (gitignored; generate or download)
  processed/        # Parquet exports for BI
sql/                # Version-controlled transformations
src/                # Python orchestration
scripts/            # Setup and verification
notebooks/          # Exploration and charts
docs/               # Memo, Metabase guide, cloud migration
```

## Using real Chicago data

1. Download a one-month slice from the [City of Chicago Taxi Trips dataset](https://data.cityofchicago.org/Transportation/Taxi-Trips/wrvz-psew).
2. Save as `data/raw/taxi_trips_2024_01.csv` (or pass a custom path).
3. Run without `--generate`:

```bash
python src/run_pipeline.py --input data/raw/taxi_trips_2024_01.csv
```

Column names should align with the public schema; adjust `sql/01_schema.sql` if your export differs.

## CLI reference

| Command | Description |
|---------|-------------|
| `python src/run_pipeline.py --generate` | Create sample CSV and load warehouse |
| `python src/run_pipeline.py --input PATH` | Load your own CSV |
| `python src/export_for_bi.py` | Export analytics tables to Parquet |
| `python src/generate_sample_data.py --rows 5000` | Regenerate sample data only |
| `python scripts/verify.py` | Smoke test warehouse and Parquet exports |

Warehouse file: `data/warehouse.duckdb` (created locally, not committed).

## Documentation

- [Troubleshooting](docs/troubleshooting.md)
- [Stakeholder memo template](docs/chicago-taxi-demand-memo.md)
- [Metabase local setup](docs/metabase-local-setup.md)
- [Cloud migration (MotherDuck + Dagster)](docs/cloud-migration-motherduck-dagster.md)

## Optional: Metabase

See [docs/metabase-local-setup.md](docs/metabase-local-setup.md). Requires Docker.

## Hosting path

This repo runs fully offline. When you are ready for cloud:

1. Move the warehouse to **MotherDuck** (same SQL, new connection string).
2. Orchestrate refreshes with **Dagster** (see migration doc).
3. Connect **Metabase Cloud** to MotherDuck.

Details: [docs/cloud-migration-motherduck-dagster.md](docs/cloud-migration-motherduck-dagster.md)

## License

MIT — see [LICENSE](LICENSE).
