param(
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [Parameter(Mandatory = $true)]
    [Alias("Summary")]
    [string]$WorkSummary,
    [Parameter(Mandatory = $true)]
    [Alias("Message")]
    [string]$UserMessage
)

$CoCDir = Split-Path $PSScriptRoot -Parent
$LogFile = Join-Path $CoCDir "作業ログ.md"
$GarbledLogFile = Join-Path $CoCDir "菴懈･ｭ繝ｭ繧ｰ.md"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$Utf8Bom = New-Object System.Text.UTF8Encoding $true

if (Test-Path $GarbledLogFile) {
    Remove-Item $GarbledLogFile -Force
    Write-Host "[post-work] Removed garbled duplicate work log." -ForegroundColor Yellow
}

if (-not (Test-Path $LogFile)) {
    $header = @"
# 作業ログ

Google Drive 経由の指示に基づき、PC 上の Grok が実行した作業の記録です。
出先から GitHub で進捗を確認できます。

---

"@
    [System.IO.File]::WriteAllText($LogFile, $header, $Utf8Bom)
}

$entry = @"

## $Id — $timestamp

**作業内容:** $WorkSummary

**伝言:** $UserMessage

---
"@

[System.IO.File]::AppendAllText($LogFile, $entry, $Utf8Bom)

Set-Location $CoCDir
git add -A

$commitMsg = "[$Id] $WorkSummary"
git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Host "[post-work] Commit failed or nothing to commit." -ForegroundColor Yellow
    exit $LASTEXITCODE
}

git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "[post-work] Push failed." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[post-work] Committed and pushed: $commitMsg" -ForegroundColor Green