"""Project path resolution (Windows-safe, works from any cwd)."""

from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"
SQL_DIR = PROJECT_ROOT / "sql"
NOTEBOOKS_DIR = PROJECT_ROOT / "notebooks"
DOCS_DIR = PROJECT_ROOT / "docs"

WAREHOUSE = DATA_DIR / "warehouse.duckdb"
DEFAULT_RAW_CSV = RAW_DIR / "taxi_trips_2024_01.csv"
