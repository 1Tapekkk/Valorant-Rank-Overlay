@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0overlay\stop.ps1"
if errorlevel 1 pause
