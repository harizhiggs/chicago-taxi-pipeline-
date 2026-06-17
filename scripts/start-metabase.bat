@echo off
REM Start Metabase in Docker for the local BI demo.
REM Run from project root: scripts\start-metabase.bat

cd /d "%~dp0.."

call "%~dp0check-docker.bat"
if errorlevel 1 exit /b 1

echo.
echo Starting Metabase container...
docker run -d -p 3000:3000 --name metabase metabase/metabase
if errorlevel 1 (
    echo.
    echo If the container name is already in use:
    echo   docker rm -f metabase
    echo Then run this script again.
    exit /b 1
)

echo.
echo Metabase is starting.
echo   Browser: http://localhost:3000
echo   Upload Parquet from: %CD%\data\processed\
echo     - daily_metrics.parquet
echo     - hourly_demand.parquet
echo     - zone_performance.parquet
echo.
echo See docs\metabase-local-setup.md for chart ideas and screenshots.
exit /b 0
