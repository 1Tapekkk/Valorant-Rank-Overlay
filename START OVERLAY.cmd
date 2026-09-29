@echo off
title VALO Rank Studio
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0overlay\start.ps1"
if errorlevel 1 pause
