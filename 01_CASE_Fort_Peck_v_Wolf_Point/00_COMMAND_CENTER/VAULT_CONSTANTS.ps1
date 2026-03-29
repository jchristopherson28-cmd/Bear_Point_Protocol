# VAULT CONSTANTS — Bear Point Protocol
# Purpose: Anchor dates, SOL deadlines, runtime functions for case operations
# Usage: Dot-source this file: . "$PSScriptRoot\VAULT_CONSTANTS.ps1"
# Deployed from: _MASTER_TEMPLATE — populate with case-specific dates

param(
    [string]$CasePath = ""
)

# ============================================
# ANCHOR DATES — Fill in when case opens
# ============================================

$INCIDENT_DATE          = $null  # e.g., [datetime]"2025-09-23"
$COMPLAINT_DATE         = $null  # Formal complaint filed
$LAST_DAY_SCHOOL        = $null  # If applicable — child removed/excluded
$OCR_FILED              = $null  
$DOJ_FILED              = $null
$WSHRC_FILED            = $null
$OSPI_FILED             = $null
$TORT_SERVED_DISTRICT   = $null  # RCW 4.96.020 service date
$TORT_SERVED_STATE      = $null  # RCW 4.92.100 service date
$WSBA_FILED             = $null
$OPP_FILED              = $null
$CRIMINAL_FILED         = $null
$PRA_ANCHOR_DATE        = $null  # Date of first bad-faith PRA act (penalty clock start)

# ============================================
# SOL CALCULATIONS (auto-computed from anchors)
# ============================================

function Get-SOLDeadline {
    param(
        [datetime]$AnchorDate,
        [int]$Years = 0,
        [int]$Days = 0
    )
    if ($Years -gt 0) { return $AnchorDate.AddYears($Years) }
    if ($Days -gt 0) { return $AnchorDate.AddDays($Days) }
    return $null
}

# Federal SOLs
$SOL_TITLE_VI_180  = if ($INCIDENT_DATE) { Get-SOLDeadline $INCIDENT_DATE -Days 180 } else { $null }
$SOL_SECTION_1983  = if ($INCIDENT_DATE) { Get-SOLDeadline $INCIDENT_DATE -Years 3 } else { $null }
$SOL_RICO          = if ($INCIDENT_DATE) { Get-SOLDeadline $INCIDENT_DATE -Years 4 } else { $null }

# State SOLs
$SOL_WLAD_180      = if ($INCIDENT_DATE) { Get-SOLDeadline $INCIDENT_DATE -Days 180 } else { $null }
$SOL_WLAD_3YR      = if ($INCIDENT_DATE) { Get-SOLDeadline $INCIDENT_DATE -Years 3 } else { $null }

# Tort clocks
$TORT_DISTRICT_EXPIRY = if ($TORT_SERVED_DISTRICT) { $TORT_SERVED_DISTRICT.AddDays(60) } else { $null }
$TORT_STATE_EXPIRY    = if ($TORT_SERVED_STATE) { $TORT_SERVED_STATE.AddDays(60) } else { $null }

# ============================================
# RUNTIME FUNCTIONS
# ============================================

function Get-AbsenceDays {
    if ($LAST_DAY_SCHOOL) {
        return ((Get-Date) - $LAST_DAY_SCHOOL).Days
    }
    return "N/A — no exclusion date set"
}

function Get-DaysUntilSOL {
    param([string]$Claim)
    $deadline = switch ($Claim) {
        "TitleVI"    { $SOL_TITLE_VI_180 }
        "Section1983" { $SOL_SECTION_1983 }
        "RICO"       { $SOL_RICO }
        "WLAD180"    { $SOL_WLAD_180 }
        "WLAD3yr"    { $SOL_WLAD_3YR }
        default      { $null }
    }
    if ($deadline) {
        $remaining = ($deadline - (Get-Date)).Days
        return "$Claim : $remaining days remaining (deadline: $($deadline.ToString('yyyy-MM-dd')))"
    }
    return "$Claim : No anchor date set"
}

function Get-DaysUntilTortExpiry {
    param([string]$Type = "District")
    $expiry = switch ($Type) {
        "District" { $TORT_DISTRICT_EXPIRY }
        "State"    { $TORT_STATE_EXPIRY }
        default    { $null }
    }
    if ($expiry) {
        $remaining = ($expiry - (Get-Date)).Days
        return "$Type tort: $remaining days remaining (expires: $($expiry.ToString('yyyy-MM-dd')))"
    }
    return "$Type tort: No service date set"
}

function Get-PRAExposure {
    if ($PRA_ANCHOR_DATE) {
        $days = ((Get-Date) - $PRA_ANCHOR_DATE).Days
        $daily = 100  # $100/day base under Yousoufian
        $files = 1    # Override with actual file count
        $total = $days * $daily * $files
        return "PRA: $days days accruing × $files files × `$$daily/day = `$$($total.ToString('N0'))"
    }
    return "PRA: No anchor date set"
}

function Get-AllCountdowns {
    Write-Host "`n=== CASE COUNTDOWNS ===" -ForegroundColor Cyan
    if ($LAST_DAY_SCHOOL) {
        Write-Host "  Absence: $(Get-AbsenceDays) calendar days" -ForegroundColor Yellow
    }
    Write-Host ""
    @("TitleVI","Section1983","RICO","WLAD180","WLAD3yr") | ForEach-Object {
        Write-Host "  $(Get-DaysUntilSOL $_)" -ForegroundColor White
    }
    Write-Host ""
    @("District","State") | ForEach-Object {
        Write-Host "  $(Get-DaysUntilTortExpiry $_)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  $(Get-PRAExposure)" -ForegroundColor White
    Write-Host "========================`n" -ForegroundColor Cyan
}
