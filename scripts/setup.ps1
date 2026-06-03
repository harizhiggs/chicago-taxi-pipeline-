# Bootstrap the Chicago taxi pipeline on Windows.
# Prefer: scripts\setup.bat (works when PowerShell script execution is restricted)
# Or:     powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$Python = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$Pip = Join-Path $ProjectRoot ".venv\Scripts\pip.exe"

Write-Host "Creating virtual environment..."
python -m venv .venv

Write-Host "Installing dependencies..."
& $Pip install -r requirements.txt

Write-Host "Running pipeline (generate sample data + load warehouse)..."
& $Python src/run_pipeline.py --generate

Write-Host "Exporting Parquet for BI..."
& $Python src/export_for_bi.py

Write-Host ""
Write-Host "Setup complete. Verify with:"
Write-Host "  .\.venv\Scripts\python.exe scripts\verify.py"
