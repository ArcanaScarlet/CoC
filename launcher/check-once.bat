@echo off
setlocal
set "ROOT=%~dp0.."
cd /d "%ROOT%"
echo [CoC] Check instructions once
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\watch-instructions.ps1"
if errorlevel 1 (
  echo FAILED
  pause
  exit /b 1
)
echo Done
pause
exit /b 0