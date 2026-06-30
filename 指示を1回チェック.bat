@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo [CoC] GitHub の指示を 1 回チェックします...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\watch-instructions.ps1"
set ERR=%ERRORLEVEL%

echo.
if %ERR% neq 0 (
    echo エラーが発生しました。コード: %ERR%
) else (
    echo チェック完了。
)
pause
exit /b %ERR%