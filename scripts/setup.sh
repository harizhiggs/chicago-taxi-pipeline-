#!/usr/bin/env bash
# Bootstrap the Chicago taxi pipeline on macOS/Linux.
# Run from project root: ./scripts/setup.sh

set -euo pipefail

cd "$(dirname "$0")/.."
PYTHON=".venv/bin/python"

echo "Creating virtual environment..."
python3 -m venv .venv

echo "Upgrading pip..."
"$PYTHON" -m pip install --upgrade pip

echo "Installing dependencies from requirements.txt..."
"$PYTHON" -m pip install -r requirements.txt

echo "Ensuring duckdb is installed..."
"$PYTHON" -m pip install "duckdb>=1.0.0,<2.0.0"

echo "Verifying duckdb import..."
"$PYTHON" -c "import duckdb; print('OK  duckdb', duckdb.__version__)"

echo "Running pipeline (generate sample data + load warehouse)..."
"$PYTHON" src/run_pipeline.py --generate

echo "Exporting Parquet for BI..."
"$PYTHON" src/export_for_bi.py

echo ""
echo "Setup complete. Verify with: .venv/bin/python scripts/verify.py"
