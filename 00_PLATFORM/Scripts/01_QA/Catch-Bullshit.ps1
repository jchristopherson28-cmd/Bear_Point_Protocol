# VAULT BULLSHIT CATCHER — Bear Point Protocol (Generic)
# Adapted from Bear Point Protocol — works with any case vault path
# Usage: .\Catch-Bullshit.ps1 -VaultPath "F:\Bear_Point_Protocol\01_CASE_Smith_v_District"

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,
    [switch]$Verbose
)

$ErrorCount = 0
$WarningCount = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  VAULT BULLSHIT CATCHER" -ForegroundColor Cyan
Write-Host "  Case: $VaultPath" -ForegroundColor Gray
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

function Get-FileContent {
    param([string]$Path)
    try { return [System.IO.File]::ReadAllText($Path) } catch { return $null }
}

$ExcludeDirs = @('_Archive', '.git', 'node_modules', '.venv', '.obsidian')

# ============================================
# CHECK 1: Banned placeholder patterns
# ============================================
Write-Host "[CHECK 1] Scanning for truncation placeholders..." -ForegroundColor Yellow

$BannedPatterns = @(
    '\.\.\. and \d+ more',
    '\(truncated\)',
    '\[additional entries omitted\]',
    '\[remaining items not shown\]',
    '\[TRUNCATED\]',
    '\[more entries\]'
)

$ExcludeFiles = @(
    'Catch-Bullshit.ps1',
    'SESSION_STARTUP.md',
    'VAULT_PROTOCOLS.md',
    '_PROTOCOL.md'
)

$PlaceholderHits = @()
Get-ChildItem -Path $VaultPath -Filter "*.md" -Recurse -File | Where-Object {
    $ExcludeFiles -notcontains $_.Name
} | ForEach-Object {
    $skip = $false
    foreach ($dir in $ExcludeDirs) {
        if ($_.FullName -like "*\$dir\*") { $skip = $true; break }
    }
    if (-not $skip) {
        $content = Get-FileContent $_.FullName
        if ($content) {
            foreach ($pattern in $BannedPatterns) {
                if ($content -match $pattern) {
                    $PlaceholderHits += [PSCustomObject]@{
                        File = $_.FullName.Replace($VaultPath, "")
                        Pattern = $Matches[0]
                    }
                }
            }
        }
    }
}

if ($PlaceholderHits.Count -gt 0) {
    Write-Host "  [FAIL] Found $($PlaceholderHits.Count) truncation placeholders:" -ForegroundColor Red
    $PlaceholderHits | ForEach-Object {
        Write-Host "    $($_.File)" -ForegroundColor Red
        Write-Host "      Pattern: $($_.Pattern)" -ForegroundColor DarkRed
    }
    $ErrorCount += $PlaceholderHits.Count
} else {
    Write-Host "  [PASS] No truncation placeholders found" -ForegroundColor Green
}

# ============================================
# CHECK 2: Dead wikilinks
# ============================================
Write-Host "`n[CHECK 2] Scanning for dead wikilinks..." -ForegroundColor Yellow

$AllMdFiles = Get-ChildItem -Path $VaultPath -Filter "*.md" -Recurse -File |
    Select-Object -ExpandProperty BaseName

$DeadLinks = @()
Get-ChildItem -Path $VaultPath -Filter "*.md" -Recurse -File | ForEach-Object {
    $skip = $false
    foreach ($dir in $ExcludeDirs) {
        if ($_.FullName -like "*\$dir\*") { $skip = $true; break }
    }
    if (-not $skip) {
        $sourceFile = $_.FullName.Replace($VaultPath, "")
        $content = Get-FileContent $_.FullName
        if ($content) {
            $links = [regex]::Matches($content, '\[\[([^\]|#]+)(?:[|#][^\]]+)?\]\]')
            foreach ($link in $links) {
                $target = $link.Groups[1].Value.Trim()
                if ($target -and
                    $target -notmatch '^https?://' -and
                    $target -notmatch '^\.\.' -and
                    $target -notmatch '^\./' -and
                    $target.Length -gt 1 -and
                    $target -notmatch '^file\.' -and
                    $target -notmatch '^\w+\(') {
                    if ($AllMdFiles -notcontains $target) {
                        $DeadLinks += [PSCustomObject]@{
                            Source = $sourceFile
                            Target = $target
                        }
                    }
                }
            }
        }
    }
}

$UniqueDeadLinks = $DeadLinks | Sort-Object Target -Unique

if ($UniqueDeadLinks.Count -gt 0) {
    Write-Host "  [WARN] Found $($UniqueDeadLinks.Count) unique dead wikilinks" -ForegroundColor Yellow
    if ($Verbose) {
        $UniqueDeadLinks | ForEach-Object {
            Write-Host "    [[$($_.Target)]]" -ForegroundColor Yellow
            Write-Host "      in: $($_.Source)" -ForegroundColor DarkYellow
        }
    } else {
        Write-Host "    (Run with -Verbose to see full list)" -ForegroundColor DarkGray
        $UniqueDeadLinks | Select-Object -First 15 | ForEach-Object {
            Write-Host "    [[$($_.Target)]]" -ForegroundColor Yellow
        }
        if ($UniqueDeadLinks.Count -gt 15) {
            Write-Host "    ... and $($UniqueDeadLinks.Count - 15) more" -ForegroundColor DarkYellow
        }
    }
    $WarningCount += $UniqueDeadLinks.Count
} else {
    Write-Host "  [PASS] All wikilinks resolve" -ForegroundColor Green
}

# ============================================
# CHECK 3: Index vs source count validation
# ============================================
Write-Host "`n[CHECK 3] Validating evidence counts..." -ForegroundColor Yellow

$evidenceTypes = @(
    @{ Name = "EMAIL"; IndexPattern = 'EMAIL-(\d{5})'; SourcePath = "$VaultPath\03_EVIDENCE\Email_Evidence"; FileFilter = "EMAIL-*.md" },
    @{ Name = "DOC"; IndexPattern = 'DOC-(\d{5})'; SourcePath = "$VaultPath\03_EVIDENCE\Official_Documents"; FileFilter = "DOC-*.md" },
    @{ Name = "SCREENSHOT"; IndexPattern = 'SCREENSHOT-(\d{5})'; SourcePath = "$VaultPath\03_EVIDENCE\Screenshot_Evidence"; FileFilter = "SCREENSHOT-*.md" },
    @{ Name = "PRA"; IndexPattern = 'PRA-(\d{5})'; SourcePath = "$VaultPath\03_EVIDENCE\PRA"; FileFilter = "PRA-*.md" }
)

$indexPath = "$VaultPath\03_EVIDENCE\Evidence_Index\Evidence_Index_By_Date_FULL.md"

foreach ($type in $evidenceTypes) {
    if ((Test-Path $indexPath) -and (Test-Path $type.SourcePath)) {
        $indexContent = Get-FileContent $indexPath
        $matches = [regex]::Matches($indexContent, $type.IndexPattern)
        $uniqueIds = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
        $indexEntries = $uniqueIds.Count
        $sourceFiles = (Get-ChildItem -Path $type.SourcePath -Filter $type.FileFilter -File -Recurse).Count

        if ($sourceFiles -eq $indexEntries) {
            Write-Host "  [PASS] $($type.Name): $sourceFiles files, $indexEntries index entries" -ForegroundColor Green
        } elseif ([Math]::Abs($sourceFiles - $indexEntries) -le 5) {
            Write-Host "  [WARN] $($type.Name): $sourceFiles files, $indexEntries index entries (diff: $([Math]::Abs($sourceFiles - $indexEntries)))" -ForegroundColor Yellow
            $WarningCount++
        } else {
            Write-Host "  [FAIL] $($type.Name): $sourceFiles files, $indexEntries index entries (diff: $([Math]::Abs($sourceFiles - $indexEntries)))" -ForegroundColor Red
            $ErrorCount++
        }
    }
}

# ============================================
# CHECK 4: Recent files missing YAML
# ============================================
Write-Host "`n[CHECK 4] Checking YAML frontmatter on recent files..." -ForegroundColor Yellow

$NoYaml = @()
$RecentFiles = Get-ChildItem -Path "$VaultPath\03_EVIDENCE" -Filter "*.md" -Recurse -File |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

foreach ($file in $RecentFiles) {
    $skip = $false
    foreach ($dir in $ExcludeDirs) {
        if ($file.FullName -like "*\$dir\*") { $skip = $true; break }
    }
    if (-not $skip) {
        $firstLines = Get-Content $file.FullName -First 1 -ErrorAction SilentlyContinue
        if ($firstLines -ne "---") {
            $NoYaml += $file.FullName.Replace($VaultPath, "")
        }
    }
}

if ($NoYaml.Count -gt 0) {
    Write-Host "  [WARN] $($NoYaml.Count) recent evidence files missing YAML:" -ForegroundColor Yellow
    $NoYaml | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkYellow }
    $WarningCount += $NoYaml.Count
} else {
    Write-Host "  [PASS] Recent evidence files have YAML frontmatter" -ForegroundColor Green
}

# ============================================
# SUMMARY
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "  RESULT: ALL CLEAR" -ForegroundColor Green
} elseif ($ErrorCount -eq 0) {
    Write-Host "  RESULT: $WarningCount warnings (review recommended)" -ForegroundColor Yellow
} else {
    Write-Host "  RESULT: $ErrorCount errors, $WarningCount warnings" -ForegroundColor Red
    Write-Host "  Action: Fix errors before proceeding" -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Cyan

exit $ErrorCount
