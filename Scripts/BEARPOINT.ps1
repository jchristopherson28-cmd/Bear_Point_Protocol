# BEARPOINT.ps1 - Interactive Menu UI for Bear Point Protocol
# Usage: .\BEARPOINT.ps1
# Provides quick access to all protocol operations

param(
    [string]$VaultRoot = "F:\1_SvR_AI_Operations",
    [string]$PlatformRoot = "C:\Bear_Point_Protocol"
)

$ErrorActionPreference = "Continue"

# Load vault constants
$constantsPath = "$VaultRoot\00_COMMAND_CENTER\VAULT_CONSTANTS.ps1"
if (Test-Path $constantsPath) { . $constantsPath }

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor DarkCyan
    Write-Host "       BEAR POINT PROTOCOL" -ForegroundColor White
    Write-Host "       BearPoin" -NoNewline -ForegroundColor White
    Write-Host "T" -ForegroundColor DarkYellow
    Write-Host "       FOUNDATION" -ForegroundColor DarkYellow
    Write-Host "  ========================================" -ForegroundColor DarkCyan
    Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
}

function Show-Countdowns {
    if (Get-Command Get-AllCountdowns -ErrorAction SilentlyContinue) {
        Write-Host "  --- DEADLINE COUNTDOWNS ---" -ForegroundColor Yellow
        $countdowns = Get-AllCountdowns
        foreach ($c in $countdowns) {
            $color = switch ($c.Status) {
                "EXPIRED"  { "Red" }
                "CRITICAL" { "Magenta" }
                "WARNING"  { "Yellow" }
                default    { "Green" }
            }
            $tag = if ($c.Status -eq "EXPIRED") { " [EXPIRED]" } else { "" }
            Write-Host ("    {0,-25} {1}  ({2} days){3}" -f $c.Claim, $c.Deadline, $c.DaysLeft, $tag) -ForegroundColor $color
        }
        Write-Host ""
    }
}

function Show-Menu {
    Write-Host "  --- OPERATIONS ---" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    [1]  Vault Status & Countdowns" -ForegroundColor White
    Write-Host "    [2]  Hash Evidence File (SHA-256)" -ForegroundColor White
    Write-Host "    [3]  Generate PRA Penalty Log" -ForegroundColor White
    Write-Host "    [4]  Run Vault Integrity Check" -ForegroundColor White
    Write-Host "    [5]  Deploy New Case" -ForegroundColor White
    Write-Host "    [6]  Backup Vault (F: -> D:)" -ForegroundColor White
    Write-Host "    [7]  Open Vault in Explorer" -ForegroundColor White
    Write-Host "    [8]  Open Obsidian Vault" -ForegroundColor White
    Write-Host ""
    Write-Host "    [Q]  Quit" -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-HashEvidence {
    $scriptPath = "$PlatformRoot\Scripts\Hash-Evidence.ps1"
    if (-not (Test-Path $scriptPath)) {
        $scriptPath = "$VaultRoot\06_DATA_PROCESSING\scripts\08_Utility\Hash-Evidence.ps1"
    }
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Host "  [ERROR] Hash-Evidence.ps1 not found" -ForegroundColor Red
        Write-Host "  Expected: $scriptPath" -ForegroundColor DarkGray
    }
}

function Invoke-PRALog {
    $scriptPath = "$PlatformRoot\Scripts\Generate-PRA-Log.ps1"
    if (-not (Test-Path $scriptPath)) {
        $scriptPath = "$VaultRoot\06_DATA_PROCESSING\scripts\06_PRA_Forensic\Generate-PRA-Log.ps1"
    }
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Host "  [ERROR] Generate-PRA-Log.ps1 not found" -ForegroundColor Red
        Write-Host "  Expected: $scriptPath" -ForegroundColor DarkGray
    }
}

function Invoke-IntegrityCheck {
    $scriptPath = "$VaultRoot\06_DATA_PROCESSING\scripts\01_QA\Catch-Bullshit.ps1"
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Host "  [ERROR] Catch-Bullshit.ps1 not found" -ForegroundColor Red
    }
}

function Invoke-DeployCase {
    $scriptPath = "$PlatformRoot\Deploy-Case.ps1"
    if (Test-Path $scriptPath) {
        $caseName = Read-Host "  Case name (e.g. Smith_v_District)"
        if ($caseName) {
            & $scriptPath -CaseName $caseName
        }
    } else {
        Write-Host "  [ERROR] Deploy-Case.ps1 not found at $scriptPath" -ForegroundColor Red
    }
}

function Invoke-Backup {
    $date = Get-Date -Format "yyyy-MM-dd_HHmm"
    $dest = "D:\Vault back ups\$date"
    $log = "D:\Vault back ups\robocopy_backup_$date.log"
    Write-Host "  Backing up F:\ to $dest ..." -ForegroundColor Yellow

    $dirs = @(
        @{S="F:\1_SvR_AI_Operations"; D="$dest\1_SvR_AI_Operations"}
        @{S="F:\Chairman_Outreach_Package"; D="$dest\Chairman_Outreach_Package"}
        @{S="F:\downloads"; D="$dest\downloads"}
        @{S="F:\LM Studios"; D="$dest\LM Studios"}
        @{S="F:\Obsidian"; D="$dest\Obsidian"}
        @{S="F:\SWARM_Protocol_Archive"; D="$dest\SWARM_Protocol_Archive"}
    )

    foreach ($d in $dirs) {
        if (Test-Path $d.S) {
            Write-Host "    $($d.S)..." -ForegroundColor DarkGray
            robocopy $d.S $d.D /MIR /R:1 /W:1 /NP /LOG+:$log /XD "`$RECYCLE.BIN" "System Volume Information"
        }
    }
    Write-Host "  [DONE] Backup complete: $dest" -ForegroundColor Green
    Write-Host "  Log: $log" -ForegroundColor DarkGray
}

# --- MAIN LOOP ---

while ($true) {
    Show-Banner
    Show-Countdowns
    Show-Menu

    $choice = Read-Host "  Select"

    switch ($choice.ToUpper()) {
        "1" {
            Show-Banner
            Show-Countdowns
            if ($VERIFIED_COUNTS) {
                Write-Host "  --- VERIFIED COUNTS ---" -ForegroundColor Yellow
                foreach ($key in ($VERIFIED_COUNTS.Keys | Sort-Object)) {
                    Write-Host ("    {0,-25} {1}" -f $key, $VERIFIED_COUNTS[$key]) -ForegroundColor White
                }
                Write-Host ""
            }
            Write-Host "  Vault: $VaultRoot" -ForegroundColor DarkGray
            Write-Host "  Platform: $PlatformRoot" -ForegroundColor DarkGray
            $fc = (Get-ChildItem -Path $VaultRoot -Recurse -File -ErrorAction SilentlyContinue).Count
            Write-Host "  Vault files: $fc" -ForegroundColor DarkGray
            Write-Host ""
            Read-Host "  Press Enter to continue"
        }
        "2" { Invoke-HashEvidence; Read-Host "  Press Enter to continue" }
        "3" { Invoke-PRALog; Read-Host "  Press Enter to continue" }
        "4" { Invoke-IntegrityCheck; Read-Host "  Press Enter to continue" }
        "5" { Invoke-DeployCase; Read-Host "  Press Enter to continue" }
        "6" { Invoke-Backup; Read-Host "  Press Enter to continue" }
        "7" { Start-Process explorer.exe -ArgumentList $VaultRoot }
        "8" {
            $obsidian = Get-ChildItem -Path "$env:LOCALAPPDATA\Obsidian" -Filter "Obsidian.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($obsidian) { Start-Process $obsidian.FullName } else { Write-Host "  [ERROR] Obsidian not found" -ForegroundColor Red; Read-Host "  Press Enter" }
        }
        "Q" { Write-Host ""; break }
        default { Write-Host "  Invalid selection" -ForegroundColor Red; Start-Sleep 1 }
    }
}
