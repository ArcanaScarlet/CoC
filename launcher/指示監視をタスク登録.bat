@echo off
chcp 65001 >nul
setlocal
set "ROOT=%~dp0.."
cd /d "%ROOT%"

echo [CoC] Windows タスクスケジューラに登録します（5分ごと・バックグラウンド）
echo PC ログイン中は自動で指示をチェックします。
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\register-scheduled-task.ps1"
set ERR=%ERRORLEVEL%

echo.
if %ERR% neq 0 (
    echo 登録に失敗しました。コード: %ERR%
) else (
    echo 登録完了。タスク名: CoC-Watch-Instructions
    echo 解除: launcher\指示監視をタスク解除.bat を実行
)
pause
exit /b %ERR%