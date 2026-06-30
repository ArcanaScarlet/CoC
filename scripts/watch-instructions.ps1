# GitHub の差分を監視し、INSTRUCTIONS.md に pending 指示があれば Grok headless で実行する
# 使い方:
#   .\scripts\watch-instructions.ps1          # 1回だけチェック
#   .\scripts\watch-instructions.ps1 -Loop 5  # 5分ごとにチェック

param(
    [int]$Loop = 0,
    [string]$Branch = "main",
    [string]$InstructionFile = "INSTRUCTIONS.md"
)

$RepoDir = Split-Path $PSScriptRoot -Parent
$StateFile = Join-Path $RepoDir ".instruction-state.json"
$Grok = "C:\Users\suga4\.grok\bin\grok.exe"
$Git = "C:\Program Files\Git\cmd\git.exe"

function Get-InstructionMeta {
    param([string]$Content)
    $status = "pending"
    $id = $null
    if ($Content -match '(?m)^status:\s*(\S+)') { $status = $Matches[1].Trim() }
    if ($Content -match '(?m)^id:\s*(\S+)') { $id = $Matches[1].Trim() }
    return @{ status = $status; id = $id }
}

function Load-State {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile -Raw | ConvertFrom-Json
    }
    return [pscustomobject]@{ last_id = ""; last_sha = "" }
}

function Save-State($state) {
    $state | ConvertTo-Json | Set-Content $StateFile -Encoding UTF8
}

function Invoke-Git {
    param([string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $Git @GitArgs 2>&1 | Out-Null
    } finally {
        $ErrorActionPreference = $prev
    }
}

function Get-GitOutputTrimmed {
    param([string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $out = & $Git @GitArgs 2>$null
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($null -eq $out) { return "" }
    if ($out -is [array]) { return ($out -join "`n").Trim() }
    return $out.ToString().Trim()
}

function Check-Once {
    Set-Location $RepoDir
    Invoke-Git -GitArgs @("fetch", "origin", $Branch)

    $remoteSha = Get-GitOutputTrimmed -GitArgs @("rev-parse", "origin/$Branch")
    $localSha = Get-GitOutputTrimmed -GitArgs @("rev-parse", $Branch)

    if ($remoteSha -ne $localSha) {
        Invoke-Git -GitArgs @("pull", "origin", $Branch)
        Write-Host "[watch] Pulled updates from origin/$Branch" -ForegroundColor Cyan
    }

    $filePath = Join-Path $RepoDir $InstructionFile
    if (-not (Test-Path $filePath)) {
        Write-Host "[watch] No $InstructionFile yet." -ForegroundColor Yellow
        return
    }

    $content = Get-Content $filePath -Raw -Encoding UTF8
    $meta = Get-InstructionMeta $content
    $fileSha = Get-GitOutputTrimmed -GitArgs @("rev-parse", "HEAD:$InstructionFile")
    $state = Load-State

    if ($meta.status -ne "pending") {
        Write-Host "[watch] status=$($meta.status) — nothing to do." -ForegroundColor DarkGray
        Save-State ([pscustomobject]@{ last_id = $meta.id; last_sha = $fileSha })
        return
    }

    if ($meta.id -and $meta.id -eq $state.last_id) {
        Write-Host "[watch] Already processed id=$($meta.id)" -ForegroundColor DarkGray
        return
    }

    if (-not (Test-Path $Grok)) {
        Write-Host "[watch] grok.exe not found at $Grok" -ForegroundColor Red
        return
    }

    Write-Host "[watch] Running instruction id=$($meta.id) ..." -ForegroundColor Green

    $prompt = @"
D:\AI\sd.webui\CoC リポジトリの $InstructionFile に pending 指示があります。
内容を読み、指示を実行してください。
完了したら $InstructionFile の status を done に更新し、commit & push してください。
指示ID: $($meta.id)
"@

    & $Grok -p $prompt --cwd $RepoDir --yolo --output-format plain

    Save-State ([pscustomobject]@{ last_id = $meta.id; last_sha = $fileSha })
    Write-Host "[watch] Done." -ForegroundColor Green
}

if ($Loop -gt 0) {
    Write-Host "[watch] Loop every $Loop minute(s). Ctrl+C to stop."
    while ($true) {
        Check-Once
        Start-Sleep -Seconds ($Loop * 60)
    }
} else {
    Check-Once
}