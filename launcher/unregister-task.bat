@echo off
echo [CoC] Remove scheduled task
powershell.exe -NoProfile -Command "Unregister-ScheduledTask -TaskName 'CoC-Watch-Instructions' -Confirm:$false -ErrorAction SilentlyContinue"
echo Done
pause