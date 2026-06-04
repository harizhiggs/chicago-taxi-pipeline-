@echo off
REM Install Jupyter deps and register .venv as a selectable notebook kernel.
REM Run from project root: scripts\register_notebook_kernel.bat

cd /d "%~dp0.."
set PYTHON=%CD%\.venv\Scripts\python.exe

if not exist "%PYTHON%" (
    echo .venv not found. Run scripts\setup.bat first.
    exit /b 1
)

echo Installing notebook dependencies...
"%PYTHON%" -m pip install -r requirements-notebook.txt
if errorlevel 1 exit /b 1

echo Registering Jupyter kernel "Chicago Taxi (.venv)"...
"%PYTHON%" -m ipykernel install --user --name=chicago-taxi-pipeline --display-name="Chicago Taxi (.venv)"
if errorlevel 1 exit /b 1

if not exist ".vscode\settings.json" (
    echo Creating .vscode\settings.json from example...
    if not exist ".vscode" mkdir .vscode
    copy /Y ".vscode\settings.json.example" ".vscode\settings.json" >nul
)

echo.
echo Done. In the notebook kernel picker, choose:
echo   Chicago Taxi (.venv)
echo Or: Python Environments -^> .venv
echo Then reload the window if the kernel list looks stale.
