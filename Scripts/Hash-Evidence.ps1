# Hash-Evidence.ps1 - SHA-256 Forensic Chain of Custody Hashing
# Usage: .\Hash-Evidence.ps1 [-Path <file_or_directory>] [-Output <log_path>]
# Generates SHA-256 hashes for evidence files and logs them with timestamps
# Part of Bear Point Protocol forensic infrastructure

param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "",

    [Parameter(Mandatory=$false)]
    [string]$Output = "",

    [Parameter(Mandatory=$false)]
    [string]$VaultRoot = "F:\1_SvR_AI_Operations",

    [Parameter(Mandatory=$false)]
    [switch]$Recurse,

    [Parameter(Mandatory=$false)]
    [switch]$Verify
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# Default evidence path
if (-not $Path) {
    $Path = "$VaultRoot\03_EVIDENCE"
    $Recurse = $true
}

# Default output
if (-not $Output) {
    $Output = "$VaultRoot\06_DATA_PROCESSING\logs\hash_manifest_$timestamp.json"
}

# Ensure output directory exists
$outDir = Split-Path $Output -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host ""
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host "  HASH-EVIDENCE - SHA-256 Chain of Custody" -ForegroundColor White
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "  Source:  $Path" -ForegroundColor White
Write-Host "  Output:  $Output" -ForegroundColor White
Write-Host "  Recurse: $Recurse" -ForegroundColor White
Write-Host ""

# --- VERIFY MODE ---
if ($Verify) {
    if (-not (Test-Path $Path)) {
        Write-Host "  [ERROR] Manifest not found: $Path" -ForegroundColor Red
        exit 1
    }
    Write-Host "  [VERIFY] Checking hashes against manifest..." -ForegroundColor Yellow
    $manifest = Get-Content $Path -Raw | ConvertFrom-Json
    $passed = 0; $failed = 0; $missing = 0

    foreach ($entry in $manifest.files) {
        if (-not (Test-Path $entry.path)) {
            Write-Host "    [MISSING] $($entry.path)" -ForegroundColor Red
            $missing++
            continue
        }
        $currentHash = (Get-FileHash -Path $entry.path -Algorithm SHA256).Hash
        if ($currentHash -eq $entry.sha256) {
            Write-Host "    [PASS] $(Split-Path $entry.path -Leaf)" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "    [FAIL] $(Split-Path $entry.path -Leaf)" -ForegroundColor Red
            Write-Host "           Expected: $($entry.sha256)" -ForegroundColor DarkGray
            Write-Host "           Got:      $currentHash" -ForegroundColor DarkGray
            $failed++
        }
    }

    Write-Host ""
    Write-Host "  Results: $passed passed, $failed failed, $missing missing" -ForegroundColor $(if ($failed -gt 0 -or $missing -gt 0) { "Red" } else { "Green" })
    exit $(if ($failed -gt 0) { 1 } else { 0 })
}

# --- HASH MODE ---
if (-not (Test-Path $Path)) {
    Write-Host "  [ERROR] Path not found: $Path" -ForegroundColor Red
    exit 1
}

$isDir = (Get-Item $Path).PSIsContainer
if ($isDir) {
    $params = @{ Path = $Path; File = $true }
    if ($Recurse) { $params.Recurse = $true }
    $files = Get-ChildItem @params | Where-Object {
        $_.Extension -match '\.(pdf|docx|xlsx|png|jpg|jpeg|tiff|msg|eml|md|txt|csv|json)$'
    }
} else {
    $files = @(Get-Item $Path)
}

Write-Host "  Found $($files.Count) evidence files" -ForegroundColor Yellow
Write-Host ""

$results = @()
$count = 0

foreach ($file in $files) {
    $count++
    $pct = [math]::Round(($count / $files.Count) * 100)
    Write-Host "`r  [$pct%] Hashing: $($file.Name)                    " -NoNewline -ForegroundColor DarkGray

    $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256

    $results += [PSCustomObject]@{
        path        = $file.FullName
        filename    = $file.Name
        sha256      = $hash.Hash
        size_bytes  = $file.Length
        modified    = $file.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ss")
        hashed_at   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    }
}

Write-Host "`r  [100%] Complete                                      " -ForegroundColor Green
Write-Host ""

# Build manifest
$manifest = @{
    generated    = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    source       = $Path
    algorithm    = "SHA-256"
    file_count   = $results.Count
    total_bytes  = ($results | Measure-Object -Property size_bytes -Sum).Sum
    operator     = $env:USERNAME
    hostname     = $env:COMPUTERNAME
    files        = $results
}

$manifest | ConvertTo-Json -Depth 4 | Out-File $Output -Encoding UTF8

Write-Host "  --- SUMMARY ---" -ForegroundColor Cyan
Write-Host "  Files hashed:  $($results.Count)" -ForegroundColor White
Write-Host "  Total size:    $([math]::Round($manifest.total_bytes / 1MB, 2)) MB" -ForegroundColor White
Write-Host "  Manifest:      $Output" -ForegroundColor White
Write-Host ""
Write-Host "  To verify later:" -ForegroundColor DarkGray
Write-Host "  .\Hash-Evidence.ps1 -Verify -Path `"$Output`"" -ForegroundColor DarkGray
Write-Host ""
