$ErrorActionPreference = "Stop"
# Register CoC instruction watcher (every 5 minutes)
# Usage: .\scripts\register-scheduled-task.ps1

$TaskName = "CoC-Watch-Instructions"
$RepoDir = Split-Path $PSScriptRoot -Parent
$Script = Join-Path $PSScriptRoot "watch-instructions.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$Script`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "CoC: watch INSTRUCTIONS.md and run Grok" -Force

Write-Host "Registered: $TaskName (every 5 minutes)" -ForegroundColor Green
Write-Host "Test: powershell -File $Script"