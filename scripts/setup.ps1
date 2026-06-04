# Bootstrap the Chicago taxi pipeline on Windows.
# Prefer: scripts\setup.bat (pure CMD, no execution policy issues)
# Or:     powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$Python = Join-Path $ProjectRoot ".venv\Scripts\python.exe"

function Test-DuckDb {
    & $Python -c "import duckdb; print('OK  duckdb', duckdb.__version__)"
    if ($LASTEXITCODE -ne 0) {
        throw "duckdb failed to import after install."
    }
}

Write-Host "Creating virtual environment..."
python -m venv .venv

Write-Host "Upgrading pip..."
& $Python -m pip install --upgrade pip

Write-Host "Installing dependencies from requirements.txt..."
& $Python -m pip install -r requirements.txt

Write-Host "Ensuring duckdb is installed..."
& $Python -m pip install "duckdb>=1.0.0,<2.0.0"

Write-Host "Verifying duckdb import..."
Test-DuckDb

Write-Host "Running pipeline (generate sample data + load warehouse)..."
& $Python src/run_pipeline.py --generate

Write-Host "Exporting Parquet for BI..."
& $Python src/export_for_bi.py

Write-Host ""
Write-Host "Setup complete. Verify with:"
Write-Host "  .\.venv\Scripts\python.exe scripts\verify.py"
