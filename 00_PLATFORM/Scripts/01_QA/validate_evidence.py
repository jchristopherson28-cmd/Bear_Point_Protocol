#!/usr/bin/env python3
"""
validate_evidence.py — Bear Point Protocol platform port
Validates evidence file integrity: ID formats, gaps, duplicates, frontmatter,
filename/ID alignment, orphan detection.

Usage:
    python validate_evidence.py --vault "{INSTALL_PATH}\\01_CASE_Smith_v_District"
    python validate_evidence.py --vault "{INSTALL_PATH}\\01_CASE_..." --full
    python validate_evidence.py --vault "{INSTALL_PATH}\\01_CASE_..." --quick
    python validate_evidence.py --vault "{INSTALL_PATH}\\01_CASE_..." --json

Arguments:
    --vault   Path to the case root (required)
    --full    Full validation including orphan detection and field checks (default)
    --quick   ID format and duplicate check only
    --json    Output JSON report to stdout (also always written to logs/)

Ported from original vault validator — hardcoded paths replaced with --vault param.
Compatible with Bear Point Protocol vault structure.
"""

import os
import re
import json
import argparse
from pathlib import Path
from datetime import datetime
from collections import defaultdict

try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False

# ============================================
# EVIDENCE DIRECTORY MAP
# Relative to case root / 03_EVIDENCE
# ============================================

EVIDENCE_TYPE_DIRS = {
    'EMAIL':      'Email_Evidence',
    'SCREENSHOT': 'Screenshot_Evidence',
    'DOC':        'Official_Documents',
    'PRA':        'PRA',
    'WITNESS':    'Witness_Statements',
    'PHOTO':      'Photo_Evidence',
}

# DOC files may be nested in subdirectories — scan recursively
RECURSIVE_SCAN_TYPES = {'DOC'}

# Fields required in every evidence file
REQUIRED_FIELDS = ['evidence_id', 'type']

# Fields recommended but not required
RECOMMENDED_FIELDS = ['date', 'source_file', 'classification']

# Max issues/warnings shown in console before truncating
MAX_CONSOLE_LINES = 30


# ============================================
# VALIDATOR
# ============================================

class EvidenceValidator:

    def __init__(self, vault_path: Path):
        self.vault_path   = vault_path
        self.evidence_dir = vault_path / '03_EVIDENCE'
        self.index_dir    = self.evidence_dir / 'Evidence_Index'
        self.log_dir      = vault_path / '06_DATA_PROCESSING' / 'logs'

        self.files    = defaultdict(list)   # etype -> [file_info]
        self.ids      = defaultdict(list)   # evidence_id -> [file_info]
        self.issues   = []                  # hard failures
        self.warnings = []                  # soft failures
        self.stats    = {}

    # ------------------------------------------
    # FRONTMATTER EXTRACTION
    # ------------------------------------------

    def extract_frontmatter(self, file_path: Path) -> dict:
        """Extract YAML frontmatter from markdown file."""
        try:
            content = file_path.read_text(encoding='utf-8-sig', errors='replace')
        except Exception as e:
            self.issues.append(f"Cannot read {file_path.name}: {e}")
            return {}

        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if not match:
            return {}

        if YAML_AVAILABLE:
            try:
                return yaml.safe_load(match.group(1)) or {}
            except Exception:
                pass

        # Fallback: naive key: value parse when PyYAML not installed
        result = {}
        for line in match.group(1).splitlines():
            if ':' in line:
                k, _, v = line.partition(':')
                result[k.strip()] = v.strip()
        return result

    # ------------------------------------------
    # FILE SCANNING
    # ------------------------------------------

    def scan_evidence_files(self):
        """Scan all evidence directories."""
        if not self.evidence_dir.exists():
            self.issues.append(f"03_EVIDENCE directory not found: {self.evidence_dir}")
            return

        for etype, subdir_name in EVIDENCE_TYPE_DIRS.items():
            directory = self.evidence_dir / subdir_name
            if not directory.exists():
                self.warnings.append(f"Directory not found (skipping): {subdir_name}")
                continue

            if etype in RECURSIVE_SCAN_TYPES:
                # Scan all .md files in subdirectories too
                for f in directory.rglob('*.md'):
                    self._process_file(f, etype)
            else:
                # Top-level files only — skip subdirectories like attachments/
                for f in directory.glob('*.md'):
                    if f.parent == directory:
                        self._process_file(f, etype)

    def _process_file(self, file_path: Path, expected_type: str):
        """Process a single evidence file."""
        fm = self.extract_frontmatter(file_path)

        # Skip index/navigation/registry files
        if fm.get('exclude_from_validation'):
            return
        if fm.get('type') in ('index', 'registry', 'startup', 'protocol', 'template'):
            return
        # Skip files whose name starts with known non-evidence patterns
        if file_path.name.startswith(('Evidence_Index', 'EMAIL_ID_', 'DOC_ID_', 'SCREENSHOT_ID_', 'PRA_ID_')):
            return

        evidence_id = fm.get('evidence_id', '').strip()

        file_info = {
            'path':            file_path,
            'filename':        file_path.name,
            'evidence_id':     evidence_id,
            'has_frontmatter': bool(fm),
            'frontmatter':     fm,
        }

        self.files[expected_type].append(file_info)
        if evidence_id:
            self.ids[evidence_id].append(file_info)

    # ------------------------------------------
    # CHECKS
    # ------------------------------------------

    def validate_id_format(self):
        """All evidence IDs must match TYPE-NNNNN."""
        for etype, files in self.files.items():
            pattern = re.compile(rf'^{etype}-\d{{5}}$')
            for f in files:
                eid = f['evidence_id']
                if not eid:
                    self.issues.append(f"[{etype}] Missing evidence_id: {f['filename']}")
                elif not pattern.match(eid):
                    self.issues.append(
                        f"[{etype}] Invalid ID format '{eid}' in {f['filename']} "
                        f"(expected {etype}-NNNNN)"
                    )

    def find_duplicates(self):
        """Multiple files sharing an evidence_id."""
        for eid, files in self.ids.items():
            if len(files) > 1:
                names = ', '.join(f['filename'] for f in files)
                self.issues.append(f"Duplicate ID {eid}: {names}")

    def find_gaps(self):
        """Missing numbers in sequential ID ranges."""
        for etype in EVIDENCE_TYPE_DIRS:
            pattern = re.compile(rf'^{etype}-(\d{{5}})$')
            numbers = []
            for eid in self.ids:
                m = pattern.match(eid)
                if m:
                    numbers.append(int(m.group(1)))

            if not numbers:
                self.stats[f'{etype}_count'] = 0
                continue

            numbers.sort()
            min_id, max_id = numbers[0], numbers[-1]
            full_range = set(range(min_id, max_id + 1))
            gaps = sorted(full_range - set(numbers))

            self.stats[f'{etype}_min']   = min_id
            self.stats[f'{etype}_max']   = max_id
            self.stats[f'{etype}_count'] = len(numbers)
            self.stats[f'{etype}_gaps']  = len(gaps)

            if gaps:
                gap_ids = [f'{etype}-{g:05d}' for g in gaps[:10]]
                suffix = f' (+ {len(gaps)-10} more)' if len(gaps) > 10 else ''
                self.warnings.append(
                    f"ID gaps in {etype} ({len(gaps)} total): "
                    f"{', '.join(gap_ids)}{suffix}"
                )

    def check_filename_id_match(self):
        """Filename must begin with its evidence_id."""
        for etype, files in self.files.items():
            for f in files:
                eid = f['evidence_id']
                if eid and not f['filename'].startswith(eid):
                    self.warnings.append(
                        f"Filename/ID mismatch: {f['filename']} has id={eid}"
                    )

    def check_required_fields(self):
        """Required and recommended frontmatter field presence."""
        for etype, files in self.files.items():
            for f in files:
                fm = f['frontmatter']
                if not f['has_frontmatter']:
                    self.issues.append(f"[{etype}] No YAML frontmatter: {f['filename']}")
                    continue
                for field in REQUIRED_FIELDS:
                    if field not in fm:
                        self.issues.append(
                            f"[{etype}] Missing required field '{field}': {f['filename']}"
                        )
                for field in RECOMMENDED_FIELDS:
                    if field not in fm:
                        self.warnings.append(
                            f"[{etype}] Missing recommended field '{field}': {f['filename']}"
                        )

    def find_orphans(self):
        """Evidence IDs not referenced in any index file."""
        if not self.index_dir.exists():
            self.warnings.append(f"Evidence_Index directory not found — orphan check skipped")
            return

        linked_ids = set()
        for index_file in self.index_dir.glob('*.md'):
            try:
                content = index_file.read_text(encoding='utf-8', errors='replace')
                # Wikilinks and plain ID references
                links = re.findall(r'\[\[([^\]|#]+)', content)
                refs  = re.findall(r'\b(?:EMAIL|DOC|SCREENSHOT|PRA|WITNESS|PHOTO)-\d{5}\b', content)
                linked_ids.update(links)
                linked_ids.update(refs)
            except Exception:
                pass

        for eid in self.ids:
            if eid not in linked_ids:
                # Secondary check: ID appears anywhere in any linked string
                if not any(eid in link for link in linked_ids):
                    self.warnings.append(f"Possibly unlinked from index: {eid}")

    # ------------------------------------------
    # RUN
    # ------------------------------------------

    def run(self, full: bool = True):
        """Execute all checks."""
        _step("Scanning evidence files")
        self.scan_evidence_files()

        _step("Validating ID formats")
        self.validate_id_format()

        _step("Checking for duplicates")
        self.find_duplicates()

        _step("Finding ID gaps")
        self.find_gaps()

        if full:
            _step("Checking filename/ID alignment")
            self.check_filename_id_match()

            _step("Checking frontmatter fields")
            self.check_required_fields()

            _step("Finding orphan files")
            self.find_orphans()

        # File count stats
        for etype in EVIDENCE_TYPE_DIRS:
            self.stats[f'{etype}_files'] = len(self.files[etype])

    # ------------------------------------------
    # REPORTING
    # ------------------------------------------

    def to_dict(self) -> dict:
        return {
            'timestamp':     datetime.now().isoformat(),
            'vault':         str(self.vault_path),
            'statistics':    self.stats,
            'issue_count':   len(self.issues),
            'warning_count': len(self.warnings),
            'issues':        self.issues,
            'warnings':      self.warnings,
        }

    def print_report(self):
        width = 60
        print('\n' + '='*width)
        print('  EVIDENCE VALIDATION REPORT — BEAR POINT PROTOCOL')
        print(f'  Vault: {self.vault_path}')
        print(f'  Run:   {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
        print('='*width)

        print('\n--- Statistics ---')
        for k, v in sorted(self.stats.items()):
            print(f'  {k}: {v}')

        _print_section('Issues', self.issues, is_error=True)
        _print_section('Warnings', self.warnings, is_error=False)

        print('\n' + '='*width)
        if not self.issues:
            print('  RESULT: PASS' + (f' ({len(self.warnings)} warnings)' if self.warnings else ''))
        else:
            print(f'  RESULT: FAIL — {len(self.issues)} issues, {len(self.warnings)} warnings')
        print('='*width + '\n')

    def save_report(self) -> Path:
        self.log_dir.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        out = self.log_dir / f'validation_report_{ts}.json'
        out.write_text(json.dumps(self.to_dict(), indent=2), encoding='utf-8')
        return out


# ============================================
# HELPERS
# ============================================

def _step(msg: str):
    print(f'  > {msg}...')

def _print_section(title: str, items: list, is_error: bool):
    prefix = 'X' if is_error else '!'
    print(f'\n--- {title} ({len(items)}) ---')
    if not items:
        print(f'  OK None')
        return
    shown = items[:MAX_CONSOLE_LINES]
    for item in shown:
        print(f'  {prefix} {item}')
    if len(items) > MAX_CONSOLE_LINES:
        print(f'  ... and {len(items) - MAX_CONSOLE_LINES} more (see JSON report)')


# ============================================
# ENTRY POINT
# ============================================

def main():
    parser = argparse.ArgumentParser(
        description='Bear Point Protocol — evidence file integrity validator'
    )
    parser.add_argument(
        '--vault', required=True,
        help='Path to case root (e.g. {INSTALL_PATH}\\01_CASE_Smith_v_District)'
    )
    parser.add_argument('--full',  action='store_true', help='Full validation (default)')
    parser.add_argument('--quick', action='store_true', help='ID format and duplicates only')
    parser.add_argument('--json',  action='store_true', help='Print JSON report to stdout')
    args = parser.parse_args()

    vault_path = Path(args.vault)
    if not vault_path.exists():
        print(f'[FATAL] Vault path not found: {vault_path}')
        raise SystemExit(1)

    full_mode = not args.quick  # default to full unless --quick

    print(f'\nBear Point Protocol — Evidence Validator')
    print(f'Vault: {vault_path}')
    print(f'Mode:  {"full" if full_mode else "quick"}\n')

    validator = EvidenceValidator(vault_path)
    validator.run(full=full_mode)

    report_path = validator.save_report()

    if args.json:
        print(json.dumps(validator.to_dict(), indent=2))
    else:
        validator.print_report()
        print(f'Report saved: {report_path}')

    raise SystemExit(1 if validator.issues else 0)


if __name__ == '__main__':
    main()
