@echo off
setlocal
set "ROOT=%~dp0.."
cd /d "%ROOT%"
echo [CoC] Watch every 5 min. Close window to stop.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\watch-instructions.ps1" -Loop 5
pause