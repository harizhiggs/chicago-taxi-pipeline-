@echo off
REM Quick Docker readiness check before starting Metabase.
REM Run from project root: scripts\check-docker.bat

where docker >nul 2>&1
if errorlevel 1 (
    echo docker: command not found.
    echo.
    echo Fix:
    echo   1. Install Docker Desktop ^(per-user install is fine^).
    echo   2. Open a NEW terminal after install.
    echo   3. Start Docker Desktop from the Start menu and wait until it is running.
    echo   4. Optional: add to PATH for this session:
    echo      set PATH=%%PATH%%;%%LOCALAPPDATA%%\Programs\DockerDesktop\resources\bin
    exit /b 1
)

echo Checking Docker CLI...
docker --version
if errorlevel 1 exit /b 1

echo.
echo Checking Docker engine ^(docker info^)...
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker daemon is not ready.
    echo Start Docker Desktop and wait until the engine is running, then retry.
    exit /b 1
)

echo.
echo Docker is ready. Next: scripts\start-metabase.bat
exit /b 0
