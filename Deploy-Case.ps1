# Deploy-Case.ps1 v2
# Purpose: Deploy a new case from _MASTER_TEMPLATE into Bear Point Protocol
# Usage: .\Deploy-Case.ps1 -CaseName "Smith_v_District" -Complainant "Jane Smith" ...
# Result: Creates {INSTALL_PATH}\01_CASE_Smith_v_District\ with all templates populated
#
# MANUAL ALTERNATIVE:
#   Copy _MASTER_TEMPLATE folder, rename it, and fill in [bracketed fields] manually.
#   This script automates the fill-in when you provide values up front.
#
# CHANGELOG v2:
#   - Added: -Jurisdiction, -SchoolDistrict, -TribalNation, -InsurancePool, -AgencyCases params
#   - Added: _Archive\ directory creation
#   - Added: 02_TIMELINE\ directory creation
#   - Added: Verification checks for Day-1 templates, SHIELD_WALL.md, 02_TIMELINE
#   - Added: Agency cases block population in _STATUS.md
#   - Improved: Unfilled field detection scans all .md files, not just _STATUS.md

param(
    [Parameter(Mandatory=$true)]
    [string]$CaseName,

    [Parameter(Mandatory=$false)]
    [int]$CaseNumber = 0,

    [Parameter(Mandatory=$false)]
    [string]$Complainant = "",

    [Parameter(Mandatory=$false)]
    [string]$Victim = "",

    [Parameter(Mandatory=$false)]
    [string]$VictimAge = "",

    [Parameter(Mandatory=$false)]
    [string]$TribalNation = "",

    [Parameter(Mandatory=$false)]
    [string]$Defendant = "",

    # New v2 params
    [Parameter(Mandatory=$false)]
    [string]$Jurisdiction = "",          # State abbreviation or full name — e.g., "WA", "MT"

    [Parameter(Mandatory=$false)]
    [string]$SchoolDistrict = "",        # Full district legal name

    [Parameter(Mandatory=$false)]
    [string]$InsurancePool = "",         # Insurance pool / carrier name

    [Parameter(Mandatory=$false)]
    [string]$AgencyCases = "",           # Pre-formatted string: "OCR 12345678 | DOJ 123456-ABC"

    [Parameter(Mandatory=$false)]
    [string]$IncidentDate = "",

    [Parameter(Mandatory=$false)]
    [string]$PlatformRoot = "{INSTALL_PATH}"
)

$ErrorActionPreference = "Stop"

# ============================================
# RESOLVE CASE NUMBER
# ============================================

if ($CaseNumber -eq 0) {
    $existing = Get-ChildItem -Path $PlatformRoot -Directory -Filter "*_CASE_*" |
        Where-Object { $_.Name -match '^\d{2}_CASE_' } |
        ForEach-Object { [int]($_.Name.Substring(0,2)) } |
        Sort-Object -Descending |
        Select-Object -First 1

    $CaseNumber = if ($existing) { $existing + 1 } else { 1 }
}

$CasePrefix     = "{0:D2}" -f $CaseNumber
$CaseFolderName = "${CasePrefix}_CASE_${CaseName}"
$CasePath       = Join-Path $PlatformRoot $CaseFolderName
$TemplatePath   = Join-Path $PlatformRoot "_MASTER_TEMPLATE"
$DeployDate     = Get-Date -Format "yyyy-MM-dd"

# ============================================
# VALIDATION
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  BEAR POINT PROTOCOL — CASE DEPLOYMENT v2" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

if (-not (Test-Path $TemplatePath)) {
    Write-Host "[FATAL] _MASTER_TEMPLATE not found at: $TemplatePath" -ForegroundColor Red
    exit 1
}

if (Test-Path $CasePath) {
    Write-Host "[FATAL] Case folder already exists: $CasePath" -ForegroundColor Red
    Write-Host "  Delete or rename existing folder before deploying." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Case Name:      $($CaseName -replace '_', ' ')" -ForegroundColor White
Write-Host "  Case Number:    $CasePrefix" -ForegroundColor White
Write-Host "  Case Folder:    $CaseFolderName" -ForegroundColor White
Write-Host "  Case Path:      $CasePath" -ForegroundColor White
Write-Host "  Deploy Date:    $DeployDate" -ForegroundColor White
if ($Complainant)   { Write-Host "  Complainant:    $Complainant" -ForegroundColor White }
if ($Victim)        { Write-Host "  Victim:         $Victim" -ForegroundColor White }
if ($Defendant)     { Write-Host "  Defendant:      $Defendant" -ForegroundColor White }
if ($TribalNation)  { Write-Host "  Tribal Nation:  $TribalNation" -ForegroundColor White }
if ($Jurisdiction)  { Write-Host "  Jurisdiction:   $Jurisdiction" -ForegroundColor White }
if ($SchoolDistrict){ Write-Host "  School District:$SchoolDistrict" -ForegroundColor White }
if ($InsurancePool) { Write-Host "  Insurance Pool: $InsurancePool" -ForegroundColor White }
if ($AgencyCases)   { Write-Host "  Agency Cases:   $AgencyCases" -ForegroundColor White }
Write-Host ""

# ============================================
# COPY TEMPLATE
# ============================================

Write-Host "[1/5] Copying template..." -ForegroundColor Yellow

robocopy $TemplatePath $CasePath /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null

if (-not (Test-Path $CasePath)) {
    Write-Host "[FATAL] Copy failed — case folder not created" -ForegroundColor Red
    exit 1
}

$fileCount = (Get-ChildItem -Path $CasePath -Recurse -File).Count
$dirCount  = (Get-ChildItem -Path $CasePath -Recurse -Directory).Count
Write-Host "  [OK] Copied: $fileCount files, $dirCount directories" -ForegroundColor Green

# ============================================
# CREATE MISSING DIRECTORIES
# ============================================

Write-Host "[2/5] Creating required directories..." -ForegroundColor Yellow

$dirsToCreate = @(
    "$CasePath\_Archive",
    "$CasePath\02_TIMELINE",
    "$CasePath\02_TIMELINE\Chronology",
    "$CasePath\02_TIMELINE\Key_Events",
    "$CasePath\03_EVIDENCE\PDF_Exports",
    "$CasePath\03_EVIDENCE\PRA\Analysis",
    "$CasePath\03_EVIDENCE\Witness_Statements",
    "$CasePath\03_EVIDENCE\Photo_Evidence"
)

foreach ($dir in $dirsToCreate) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  [CREATED] $(Split-Path $dir -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  [EXISTS]  $(Split-Path $dir -Leaf)" -ForegroundColor DarkGray
    }
}

# Create timeline stub
$timelineStub = @"
---
type: timeline
case: [Your case name]
created: $DeployDate
updated: $DeployDate
purpose: Chronological reconstruction of events — foundation for federal submissions
---

# CASE TIMELINE

> [!tip] HOW TO USE
> Add events chronologically. Each row should be independently verifiable from evidence IDs.
> The timeline becomes the narrative spine of all federal submissions.

## Master Chronology

| Date | Time | Event | Persons | Evidence ID | Significance |
|------|------|-------|---------|-------------|--------------|
| — | — | — | — | — | — |

## Key Event Summaries

> For events requiring detailed narrative, create individual files in \`Key_Events\\\`.
> Name them: \`{YYYY-MM-DD}_{Descriptor}.md\`

---

*Timeline: Bear Point Protocol — \`02_TIMELINE\CASE_TIMELINE.md\`*
"@

$timelineFile = "$CasePath\02_TIMELINE\CASE_TIMELINE.md"
if (-not (Test-Path $timelineFile)) {
    [System.IO.File]::WriteAllText($timelineFile, $timelineStub)
    Write-Host "  [CREATED] CASE_TIMELINE.md" -ForegroundColor Green
}

# ============================================
# VARIABLE REPLACEMENT
# ============================================

Write-Host "[3/5] Populating templates..." -ForegroundColor Yellow

$replacements = @{}

# Always replace — deployment metadata
$replacements["[Today's date]"]            = $DeployDate
$replacements["[Your case folder path]"]   = $CasePath
$replacements["[Your case name]"]          = $CaseName -replace '_', ' '
$replacements["[your case folder]"]        = $CaseFolderName

# Replace if provided — complainant/victim info
if ($Complainant)    { $replacements["[Your name]"]                            = $Complainant }
if ($Victim)         { $replacements["[Child's name or initials]"]             = $Victim }
if ($VictimAge)      { $replacements["[Child's age]"]                          = $VictimAge }
if ($TribalNation)   { $replacements["[Tribe name]"]                           = $TribalNation }
if ($Defendant)      { $replacements["[School district or institution name]"]  = $Defendant }
if ($IncidentDate)   { $replacements["[Date of first incident]"]               = $IncidentDate }

# New v2 replacements
if ($Jurisdiction)   { $replacements["[Jurisdiction/state]"]                   = $Jurisdiction }
if ($SchoolDistrict) { $replacements["[School district legal name]"]           = $SchoolDistrict }
if ($InsurancePool)  { $replacements["[Insurance pool name]"]                  = $InsurancePool }
if ($AgencyCases)    { $replacements["[Agency case numbers]"]                  = $AgencyCases }

$mdFiles  = Get-ChildItem -Path $CasePath -Filter "*.md"  -Recurse -File
$ps1Files = Get-ChildItem -Path $CasePath -Filter "*.ps1" -Recurse -File
$allFiles = @($mdFiles) + @($ps1Files)

$replaced = 0
foreach ($file in $allFiles) {
    $content  = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content

    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $replaced++
    }
}

Write-Host "  [OK] Updated $replaced files with case variables" -ForegroundColor Green

# ============================================
# UNFILLED VARIABLES CHECK
# ============================================

Write-Host "[4/5] Checking for unfilled fields..." -ForegroundColor Yellow

# Scan all .md files for remaining bracketed placeholders
$allMdFiles = Get-ChildItem -Path $CasePath -Filter "*.md" -Recurse -File |
    Where-Object { $_.FullName -notlike "*\_Archive\*" }

$unfilledByFile = @{}
foreach ($file in $allMdFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $matches = [regex]::Matches($content, '\[[^\]\n]{3,60}\]') |
        Where-Object {
            $_.Value -notmatch '^\[!' -and       # Obsidian callouts
            $_.Value -notmatch '^\[x\]' -and     # Checkboxes
            $_.Value -notmatch '^\[ \]' -and     # Empty checkboxes
            $_.Value -notmatch '^\[\^' -and      # Footnotes
            $_.Value -notmatch '\|' -and         # Table cells
            $_.Value.Length -gt 3
        } |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique

    if ($matches.Count -gt 0) {
        $shortPath = $file.FullName.Replace($CasePath, "")
        $unfilledByFile[$shortPath] = $matches
    }
}

if ($unfilledByFile.Count -gt 0) {
    $totalUnfilled = ($unfilledByFile.Values | ForEach-Object { $_ } | Measure-Object).Count
    Write-Host "  [INFO] $totalUnfilled unfilled fields across $($unfilledByFile.Count) files:" -ForegroundColor DarkYellow
    # Only show first 5 files to avoid noise
    $shown = 0
    foreach ($path in ($unfilledByFile.Keys | Sort-Object)) {
        Write-Host "    $path" -ForegroundColor DarkYellow
        $unfilledByFile[$path] | Select-Object -First 5 | ForEach-Object {
            Write-Host "      $_" -ForegroundColor DarkGray
        }
        $shown++
        if ($shown -ge 5) {
            $remaining = $unfilledByFile.Count - 5
            if ($remaining -gt 0) { Write-Host "    ... and $remaining more files" -ForegroundColor DarkGray }
            break
        }
    }
    Write-Host "    Open files in Obsidian and fill in remaining fields." -ForegroundColor DarkGray
} else {
    Write-Host "  [OK] All fields populated" -ForegroundColor Green
}

# ============================================
# VERIFICATION
# ============================================

Write-Host "[5/5] Verifying deployment..." -ForegroundColor Yellow

$checks = @(
    # Core structure
    @{ Name = "_STATUS.md";              Path = "$CasePath\00_COMMAND_CENTER\_STATUS.md" }
    @{ Name = "SESSION_STARTUP.md";      Path = "$CasePath\00_COMMAND_CENTER\SESSION_STARTUP.md" }
    @{ Name = "DEADLINE_TRACKER.md";     Path = "$CasePath\00_COMMAND_CENTER\DEADLINE_TRACKER.md" }
    @{ Name = "INBOX_TRACKER.md";        Path = "$CasePath\00_COMMS\INBOX_TRACKER.md" }
    @{ Name = "CORRESPONDENCE_AUDIT.md"; Path = "$CasePath\00_COMMS\CORRESPONDENCE_AUDIT.md" }
    @{ Name = "INTAKE_WORKFLOW";         Path = "$CasePath\00_INTAKE\INTAKE_WORKFLOW_PROTOCOL.md" }
    @{ Name = "CASE_TIMELINE.md";        Path = "$CasePath\02_TIMELINE\CASE_TIMELINE.md" }
    @{ Name = "EMAIL_ID_REGISTRY";       Path = "$CasePath\03_EVIDENCE\Evidence_Index\EMAIL_ID_REGISTRY.md" }
    @{ Name = "ACTOR-DASHBOARD";         Path = "$CasePath\04_ACTORS\ACTOR-DASHBOARD.md" }
    @{ Name = "PRESSURE_VECTORS";        Path = "$CasePath\05_STRATEGY\PRESSURE_VECTOR_TRACKER.md" }
    @{ Name = "SHIELD_WALL";             Path = "$CasePath\05_STRATEGY\SHIELD_WALL.md" }
    # Legal form templates
    @{ Name = "OCR_Complaint template";  Path = "$CasePath\00_COMMS\_Templates\OCR_Complaint.md" }
    @{ Name = "FOIA_Request template";   Path = "$CasePath\00_COMMS\_Templates\FOIA_Request.md" }
    @{ Name = "PRA_Request template";    Path = "$CasePath\00_COMMS\_Templates\PRA_Request.md" }
    @{ Name = "Tort_Notice template";    Path = "$CasePath\00_COMMS\_Templates\Tort_Notice.md" }
    @{ Name = "Bar_Grievance template";  Path = "$CasePath\00_COMMS\_Templates\Bar_Grievance.md" }
    @{ Name = "SAO_Fraud template";      Path = "$CasePath\00_COMMS\_Templates\State_Auditor_Fraud.md" }
    # Day-1 Shield Wall templates
    @{ Name = "Day1 Records Preserve";   Path = "$CasePath\00_COMMS\_Templates\Day1_Records_Preservation.md" }
    @{ Name = "Day1 Comms Notice";       Path = "$CasePath\00_COMMS\_Templates\Day1_Communications_Notice.md" }
    @{ Name = "Day1 FERPA Request";      Path = "$CasePath\00_COMMS\_Templates\Day1_FERPA_Request.md" }
    @{ Name = "Day1 Policy Inquiry";     Path = "$CasePath\00_COMMS\_Templates\Day1_Policy_Inquiry.md" }
    # Directories
    @{ Name = "_Archive\ directory";     Path = "$CasePath\_Archive" }
    @{ Name = "02_TIMELINE\ directory";  Path = "$CasePath\02_TIMELINE" }
)

$passed = 0
$failed = 0
foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "  [PASS] $($check.Name)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  [FAIL] $($check.Name)" -ForegroundColor Red
        Write-Host "         Missing: $($check.Path)" -ForegroundColor DarkRed
        $failed++
    }
}

# ============================================
# SUMMARY
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
if ($failed -eq 0) {
    Write-Host "  DEPLOYMENT COMPLETE — $passed/$($passed+$failed) checks passed" -ForegroundColor Green
    Write-Host "  Case:  $CaseFolderName" -ForegroundColor White
    Write-Host "  Path:  $CasePath" -ForegroundColor White
    Write-Host "  Files: $fileCount | Dirs: $($dirCount + $dirsToCreate.Count) | Updated: $replaced" -ForegroundColor White
} else {
    Write-Host "  DEPLOYMENT INCOMPLETE — $failed checks failed" -ForegroundColor Red
    Write-Host "  Passed: $passed | Failed: $failed" -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Open Obsidian — select {INSTALL_PATH} as vault" -ForegroundColor White
Write-Host "     Navigate: $CaseFolderName > 00_COMMAND_CENTER > _STATUS.md" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  2. Fill in remaining [bracketed fields]" -ForegroundColor White
Write-Host "     Complainant info, agency case numbers, tribal contacts" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  3. Send Day-1 Shield Wall letters" -ForegroundColor White
Write-Host "     Templates in: $CaseFolderName\00_COMMS\_Templates\Day1_*.md" -ForegroundColor DarkGray
Write-Host "     Order: Records Preservation > FERPA Request > Policy Inquiry > Comms Notice" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  4. Create Claude Project for this case" -ForegroundColor White
Write-Host "     Upload: SESSION_STARTUP.md + _PROTOCOL.md as project knowledge" -ForegroundColor DarkGray
Write-Host "     See: _PROTOCOL.md > Claude Project Setup" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  5. Begin evidence intake" -ForegroundColor White
Write-Host "     See: GETTING_STARTED.md in platform root" -ForegroundColor DarkGray
Write-Host ""
