# Vault Toolchain Reference — Bear Point Protocol

> **Purpose:** Permanent reference for all available tools across all cases.
> **Location:** {INSTALL_PATH}\00_PLATFORM\TOOLCHAIN.md
> **Last verified:** 2026-03-03

## Quick Reference Paths
```powershell
# Platform Python venv
$py = "{INSTALL_PATH}\00_PLATFORM\Scripts\.venv\Scripts\python.exe"

# Tesseract OCR
$tesseract = "C:\Program Files\Tesseract-OCR\tesseract.exe"

# ImageMagick
# magick is available in PATH

# Vault Dispatcher (per-case)
# $dispatcher = "{CASE_PATH}\00_COMMAND_CENTER\Vault-Dispatcher.ps1"

# Catch-Bullshit (platform-level, takes -VaultPath)
$catchBS = "{INSTALL_PATH}\00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1"

# Deploy new case
$deploy = "{INSTALL_PATH}\Deploy-Case.ps1"
```

## Installed Versions

| Tool | Version | Location | Purpose |
|------|---------|----------|---------|
| exiftool | (current) | AppData\Local\Programs\ExifTool\ExifTool.exe | PDF/image metadata |
| pdfinfo (poppler) | 25.07.0 | WinGet poppler package | PDF structure analysis |
| ImageMagick | (system) | PATH | Image conversion |
| Python (system) | 3.13.1 | PATH | System fallback |
| Node.js | 24.12.0 LTS | C:\Program Files\nodejs\ | JS tooling |
| Tesseract | 5.5.0 | C:\Program Files\Tesseract-OCR\ | OCR |
| OCRmyPDF | 17.2.0 | Platform venv (pip) | Batch OCR |

## Platform venv Packages

pdfplumber, python-docx, openpyxl, pandas, beautifulsoup4, markdownify,
pywin32, pillow, requests, lxml, numpy, cryptography, ocrmypdf, pikepdf,
pydantic, rich, img2pdf, pi-heif

## Decision Tree

```
.pdf (text)     → pdfplumber
.pdf (image)    → OCRmyPDF (wraps Tesseract)
.pdf (metadata) → exiftool
.pdf (structure) → pdfinfo
.docx           → python-docx
.xlsx           → openpyxl/pandas
.html           → beautifulsoup4 + markdownify
```

## Platform Links

- [[README]] — Platform overview and deploy instructions
- [[_PROTOCOL]] — Vault rules and principles
- [[BEARPOINT_FOUNDATION]] — Nonprofit architecture
- [[MMIW_RESEARCH_HUB]] — MMIW research resources

## Platform venv Setup (New Machine)

```powershell
python -m venv "{INSTALL_PATH}\00_PLATFORM\Scripts\.venv"
& "{INSTALL_PATH}\00_PLATFORM\Scripts\.venv\Scripts\pip.exe" install `
    pdfplumber python-docx openpyxl pandas beautifulsoup4 markdownify `
    pywin32 pillow requests lxml numpy cryptography ocrmypdf pikepdf `
    pydantic rich img2pdf pi-heif
```
