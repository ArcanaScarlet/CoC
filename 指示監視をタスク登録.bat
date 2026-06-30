@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo [CoC] Windows タスクスケジューラに登録します（5分ごと・バックグラウンド）
echo PC ログイン中は自動で指示をチェックします。
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\register-scheduled-task.ps1"
set ERR=%ERRORLEVEL%

echo.
if %ERR% neq 0 (
    echo 登録に失敗しました。コード: %ERR%
) else (
    echo 登録完了。タスク名: CoC-Watch-Instructions
    echo 解除: Unregister-ScheduledTask -TaskName "CoC-Watch-Instructions" -Confirm:$false
)
pause
exit /b %ERR%