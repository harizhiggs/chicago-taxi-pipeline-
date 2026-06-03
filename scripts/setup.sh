#!/usr/bin/env bash
# Bootstrap the Chicago taxi pipeline on macOS/Linux.
# Run from project root: ./scripts/setup.sh

set -euo pipefail

cd "$(dirname "$0")/.."

echo "Creating virtual environment..."
python3 -m venv .venv

echo "Activating virtual environment..."
# shellcheck disable=SC1091
source .venv/bin/activate

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Running pipeline (generate sample data + load warehouse)..."
python src/run_pipeline.py --generate

echo "Exporting Parquet for BI..."
python src/export_for_bi.py

echo ""
echo "Setup complete. Verify with: python scripts/verify.py"
