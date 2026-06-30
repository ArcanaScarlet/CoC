@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo [CoC] 指示監視を開始します（5分ごと）
echo 終了するにはこのウィンドウを閉じるか Ctrl+C を押してください。
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\watch-instructions.ps1" -Loop 5
set ERR=%ERRORLEVEL%

echo.
if %ERR% neq 0 (
    echo 監視がエラーで終了しました。コード: %ERR%
    pause
)
exit /b %ERR%