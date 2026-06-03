@echo off
REM Bootstrap the Chicago taxi pipeline on Windows (no PowerShell execution policy required).
REM Run from project root: scripts\setup.bat

cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if errorlevel 1 exit /b 1
