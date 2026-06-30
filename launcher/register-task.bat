@echo off
setlocal
set "ROOT=%~dp0.."
cd /d "%ROOT%"
echo [CoC] Register scheduled task every 5 min
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\register-scheduled-task.ps1"
if errorlevel 1 (
  echo FAILED
  pause
  exit /b 1
)
echo OK: CoC-Watch-Instructions
echo Remove with: unregister-task.bat
pause
exit /b 0