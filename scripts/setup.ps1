# Bootstrap the Chicago taxi pipeline on Windows.
# Run from project root: .\scripts\setup.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "Creating virtual environment..."
python -m venv .venv

Write-Host "Activating virtual environment..."
& .\.venv\Scripts\Activate.ps1

Write-Host "Installing dependencies..."
pip install -r requirements.txt

Write-Host "Running pipeline (generate sample data + load warehouse)..."
python src/run_pipeline.py --generate

Write-Host "Exporting Parquet for BI..."
python src/export_for_bi.py

Write-Host ""
Write-Host "Setup complete. Verify with: python scripts/verify.py"
