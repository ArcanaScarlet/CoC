@echo off
chcp 65001 >nul
setlocal

echo [CoC] タスクスケジューラの登録を解除します...
echo.

powershell.exe -NoProfile -Command "Unregister-ScheduledTask -TaskName 'CoC-Watch-Instructions' -Confirm:$false -ErrorAction SilentlyContinue; if ($?) { Write-Host '解除完了。' -ForegroundColor Green } else { Write-Host 'タスクが見つかりません（既に解除済みの可能性）。' -ForegroundColor Yellow }"

echo.
pause