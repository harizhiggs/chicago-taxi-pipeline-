@echo off
REM Bootstrap the Chicago taxi pipeline on Windows (pure CMD, no PowerShell policy).
REM Run from project root: scripts\setup.bat

cd /d "%~dp0.."
set PYTHON=%CD%\.venv\Scripts\python.exe

echo Creating virtual environment...
python -m venv .venv
if errorlevel 1 (
    echo Failed to create .venv. Is Python 3.10+ on PATH?
    exit /b 1
)

echo Upgrading pip...
"%PYTHON%" -m pip install --upgrade pip
if errorlevel 1 exit /b 1

echo Installing dependencies from requirements.txt...
"%PYTHON%" -m pip install -r requirements.txt
if errorlevel 1 exit /b 1

echo Ensuring duckdb is installed...
"%PYTHON%" -m pip install "duckdb>=1.0.0,<2.0.0"
if errorlevel 1 exit /b 1

echo Verifying duckdb import...
"%PYTHON%" -c "import duckdb; print('OK  duckdb', duckdb.__version__)"
if errorlevel 1 (
    echo duckdb failed to import. Check Python version and network, then retry.
    exit /b 1
)

echo Running pipeline (generate sample data + load warehouse)...
"%PYTHON%" src\run_pipeline.py --generate
if errorlevel 1 exit /b 1

echo Exporting Parquet for BI...
"%PYTHON%" src\export_for_bi.py
if errorlevel 1 exit /b 1

echo.
echo Setup complete. Verify with:
echo   .venv\Scripts\python.exe scripts\verify.py
