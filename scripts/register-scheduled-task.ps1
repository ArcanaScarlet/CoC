# Windows タスクスケジューラに「5分ごとに指示チェック」を登録する（管理者不要・ユーザー権限）
# 使い方: .\scripts\register-scheduled-task.ps1
# 削除:   Unregister-ScheduledTask -TaskName "CoC-Watch-Instructions" -Confirm:$false

$TaskName = "CoC-Watch-Instructions"
$RepoDir = Split-Path $PSScriptRoot -Parent
$Script = Join-Path $PSScriptRoot "watch-instructions.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$Script`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "CoC: GitHub INSTRUCTIONS.md を監視して Grok で実行" -Force

Write-Host "Registered: $TaskName (every 5 minutes)" -ForegroundColor Green
Write-Host "Test now: powershell -File `"$Script`""