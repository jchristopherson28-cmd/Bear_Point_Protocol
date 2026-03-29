# Generate-PRA-Log.ps1 - PRA Penalty Calculator under RCW 42.56
# Usage: .\Generate-PRA-Log.ps1 [-Output <path>] [-Format <md|json|csv>]
# Calculates per-record daily penalties with no aggregate cap (Yousoufian)
# Part of Bear Point Protocol forensic infrastructure

param(
    [Parameter(Mandatory=$false)]
    [string]$VaultRoot = "F:\1_SvR_AI_Operations",

    [Parameter(Mandatory=$false)]
    [string]$Output = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("md","json","csv")]
    [string]$Format = "md"
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# Load vault constants
$constantsPath = "$VaultRoot\00_COMMAND_CENTER\VAULT_CONSTANTS.ps1"
if (Test-Path $constantsPath) { . $constantsPath }

# Default output
if (-not $Output) {
    $Output = "$VaultRoot\06_DATA_PROCESSING\logs\PRA_penalty_log_$timestamp.$Format"
}

$outDir = Split-Path $Output -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host ""
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host "  PRA PENALTY LOG - RCW 42.56" -ForegroundColor White
Write-Host "  Yousoufian v. Sims - No Aggregate Cap" -ForegroundColor DarkYellow
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host ""

# ============================================
# PRA REQUEST TRACKING
# ============================================

# Each PRA request with known violations
$praRequests = @(
    @{
        ID              = "PRA-001"
        DateFiled       = [datetime]"2025-10-08"
        Description     = "Initial records request - student records, communications"
        RecordsRequested = 50
        RecordsProduced = 68
        SpoliatedCount  = 67
        SpoliationRate  = 98.5
        ViolationType   = "Print-to-scan conversion, metadata stripping"
        NonCompliantDate = [datetime]"2025-10-13"
        Notes           = "5 business day deadline. Fujitsu ScanSnap used. 9 byte-identical duplicates as padding."
    },
    @{
        ID              = "PRA-002"
        DateFiled       = [datetime]"2025-11-15"
        Description     = "Follow-up request - board minutes, policy documents"
        RecordsRequested = 30
        RecordsProduced = 0
        SpoliatedCount  = 0
        SpoliationRate  = 0
        ViolationType   = "Complete non-response"
        NonCompliantDate = [datetime]"2025-11-20"
        Notes           = "No response within statutory period."
    }
)

# ============================================
# PENALTY CALCULATION
# ============================================

# RCW 42.56.550(4): $100/day per record for non-compliance
# Yousoufian v. Sims, 168 Wn.2d 444 (2010): No aggregate cap on penalties
$dailyPenaltyRate = 100
$today = Get-Date

$totalPenalty = 0
$penaltyDetails = @()

foreach ($req in $praRequests) {
    $daysNonCompliant = [math]::Floor(($today - $req.NonCompliantDate).TotalDays)
    if ($daysNonCompliant -lt 0) { $daysNonCompliant = 0 }

    # Spoliated records: penalty accrues per record per day
    $spoliatedPenalty = $req.SpoliatedCount * $dailyPenaltyRate * $daysNonCompliant

    # Non-produced records: penalty accrues per record per day
    $nonProducedCount = [math]::Max(0, $req.RecordsRequested - $req.RecordsProduced)
    $nonProducedPenalty = $nonProducedCount * $dailyPenaltyRate * $daysNonCompliant

    $requestTotal = $spoliatedPenalty + $nonProducedPenalty

    $penaltyDetails += [PSCustomObject]@{
        RequestID         = $req.ID
        DateFiled         = $req.DateFiled.ToString("yyyy-MM-dd")
        NonCompliantSince = $req.NonCompliantDate.ToString("yyyy-MM-dd")
        DaysNonCompliant  = $daysNonCompliant
        SpoliatedRecords  = $req.SpoliatedCount
        SpoliatedPenalty  = $spoliatedPenalty
        NonProducedCount  = $nonProducedCount
        NonProducedPenalty = $nonProducedPenalty
        TotalPenalty      = $requestTotal
        ViolationType     = $req.ViolationType
    }

    $totalPenalty += $requestTotal
}

# ============================================
# DISPLAY
# ============================================

Write-Host "  --- PRA VIOLATIONS ---" -ForegroundColor Yellow
Write-Host ""

foreach ($d in $penaltyDetails) {
    Write-Host "  $($d.RequestID) | Filed: $($d.DateFiled) | Non-compliant: $($d.DaysNonCompliant) days" -ForegroundColor White
    Write-Host "    Spoliated: $($d.SpoliatedRecords) records = " -NoNewline -ForegroundColor DarkGray
    Write-Host ('${0:N0}' -f $d.SpoliatedPenalty) -ForegroundColor Red
    Write-Host "    Non-produced: $($d.NonProducedCount) records = " -NoNewline -ForegroundColor DarkGray
    Write-Host ('${0:N0}' -f $d.NonProducedPenalty) -ForegroundColor Red
    Write-Host "    Violation: $($d.ViolationType)" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "  TOTAL ACCRUED PRA PENALTIES: " -NoNewline -ForegroundColor White
Write-Host ('${0:N0}' -f $totalPenalty) -ForegroundColor Red
Write-Host "  As of: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor DarkGray
Write-Host "  Rate: `$100/record/day (RCW 42.56.550(4))" -ForegroundColor DarkGray
Write-Host "  Cap: NONE (Yousoufian v. Sims, 168 Wn.2d 444)" -ForegroundColor DarkGray
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# OUTPUT
# ============================================

switch ($Format) {
    "json" {
        $report = @{
            generated     = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
            legal_basis   = "RCW 42.56.550(4)"
            precedent     = "Yousoufian v. Sims, 168 Wn.2d 444 (2010)"
            daily_rate    = $dailyPenaltyRate
            total_penalty = $totalPenalty
            requests      = $penaltyDetails
        }
        $report | ConvertTo-Json -Depth 4 | Out-File $Output -Encoding UTF8
    }
    "csv" {
        $penaltyDetails | Export-Csv $Output -NoTypeInformation -Encoding UTF8
    }
    "md" {
        $md = @"
# PRA Penalty Accrual Log

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Legal Basis:** RCW 42.56.550(4) - `$100/record/day
**Precedent:** *Yousoufian v. Sims*, 168 Wn.2d 444 (2010) - No aggregate cap
**Total Accrued:** `$$('{0:N0}' -f $totalPenalty)

## Violations by Request

| Request | Filed | Non-Compliant Days | Spoliated | Non-Produced | Penalty |
|---------|-------|--------------------|-----------|--------------|---------|
"@
        foreach ($d in $penaltyDetails) {
            $md += "`n| $($d.RequestID) | $($d.DateFiled) | $($d.DaysNonCompliant) | $($d.SpoliatedRecords) | $($d.NonProducedCount) | `$$('{0:N0}' -f $d.TotalPenalty) |"
        }

        $md += @"

## Legal Framework

- **RCW 42.56.550(4):** Court shall award daily penalties for each record not produced
- **Yousoufian v. Sims:** Washington Supreme Court held no aggregate cap on PRA penalties
- **Spoliation:** Print-to-scan conversion of born-digital documents constitutes willful non-compliance
- **Buckingham Confession:** Written admission of scanning process by DeeDee Buckingham (J.D.)

## Penalty Growth Rate

Penalties compound daily at `$100 per non-compliant record. Current daily accrual:
- Spoliated records: $($penaltyDetails | ForEach-Object { $_.SpoliatedRecords } | Measure-Object -Sum | Select-Object -ExpandProperty Sum) records x `$100 = **`$$('{0:N0}' -f (($penaltyDetails | ForEach-Object { $_.SpoliatedRecords } | Measure-Object -Sum).Sum * 100))/day**
- Non-produced records: $($penaltyDetails | ForEach-Object { $_.NonProducedCount } | Measure-Object -Sum | Select-Object -ExpandProperty Sum) records x `$100 = **`$$('{0:N0}' -f (($penaltyDetails | ForEach-Object { $_.NonProducedCount } | Measure-Object -Sum).Sum * 100))/day**

---
*Bear Point Protocol - PRA Forensic Module*
"@

        [System.IO.File]::WriteAllText($Output, $md, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "  Report saved: $Output" -ForegroundColor Green
Write-Host ""
