---
name: evidence-architecture
description: "Governs evidence intake, cataloging, storage, and federal submission for civil rights litigation deployed via Bear Point Protocol. Triggers: document intake, evidence ID assignment, vault structure, federal submission, master docket, evidence validation, screenshot cataloging, PRA tracking, actor profiling."
---

# Evidence Architecture Skill — Bear Point Protocol

## Platform Root

`{INSTALL_PATH}`

## Case Root Pattern

`{INSTALL_PATH}\{NN}_CASE_{CaseName}\`

## MCP Trigger Rules

- **Before any vault operation:** Read the case's `00_COMMAND_CENTER\_STATUS.md` for current state.
- **Before assigning any evidence ID:** Read the appropriate registry file to get current max.
- **Before drafting legal documents:** Read `00_PLATFORM\Legal_Reference\` for applicable statutes.
- **Before running any script:** Read the live version from `00_PLATFORM\Scripts\`.
- **All vault writes require user approval.** Show content first, wait for explicit confirmation.

## Evidence ID System

Format: `{TYPE}-{NNNNN}_{Short_Descriptor}.md`

Types: EMAIL, DOC, SCREENSHOT, PRA, WITNESS, PHOTO

**Registries (always check before assigning):**
- `03_EVIDENCE\Evidence_Index\EMAIL_ID_REGISTRY.md` — EMAIL tracking
- `03_EVIDENCE\Evidence_Index\DOC_ID_REGISTRY.md` — DOC tracking
- `03_EVIDENCE\Evidence_Index\SCREENSHOT_ID_REGISTRY.md` — Screenshot tracking
- `03_EVIDENCE\Evidence_Index\PRA_ID_REGISTRY.md` — PRA tracking

Descriptor rules: max 50 chars, underscores for spaces, no special chars except hyphens in ID prefix.

## YAML Frontmatter Template

```yaml
---
type: "{evidence_type}"
evidence_id: "{TYPE}-{NNNNN}"
source_file: "{original_filename}"
source_hash: "{sha256_first_16_chars}"
date: "{YYYY-MM-DDTHH:MM:SS+00:00}"
subject: "{full_subject_line}"
from_name: "{sender_name}"
from_email: "{sender@email.com}"
to: "{recipient}"
classification: "{ROUTINE|CRITICAL|FEDERAL_EXHIBIT}"
case_references:
  - "{agency} {case_number}"
tags:
  - "{evidence_type}"
  - "{case_keyword}"
extracted: "{ISO_timestamp}"
---
```

## Classification

| Level | Criteria |
|-------|----------|
| ROUTINE | Standard evidence — correspondence, records, routine communications |
| CRITICAL | Key timeline events, admissions, policy violations, retaliatory conduct |
| FEDERAL_EXHIBIT | Directly supports federal claims — spoliation proof, deliberate indifference, pattern evidence |

## Intake Workflow

1. File arrives in `00_INTAKE\_Raw\`
2. Extract content (OCR if scanned, parse if digital, transcribe if audio)
3. Check appropriate registry for next available ID
4. Assign ID — sequential, never skip, never reuse
5. Create `.md` file in appropriate `03_EVIDENCE\` subdirectory
6. Add YAML frontmatter using template above
7. Update registry with new entry
8. Update applicable indexes (by date, by person, cross-reference)
9. Move raw source to `00_INTAKE\_Processed\`
10. If CRITICAL or FEDERAL_EXHIBIT: flag in `_STATUS.md` processing queue

## Evidence Storage Paths

```
{CASE_ROOT}\03_EVIDENCE\
├── Email_Evidence\          # EMAIL-NNNNN_*.md
├── Screenshot_Evidence\     # SCREENSHOT-NNNNN_*.md
│   └── attachments\         # Source PNG/JPG files
├── Official_Documents\      # DOC-NNNNN_*.md
├── PRA\                     # PRA-NNNNN_*.md
│   ├── Requests\            # Outbound PRA requests
│   ├── Responses\           # Inbound PRA responses
│   └── Analysis\            # PRA forensic analysis
├── PDF_Exports\             # Centralized PDF originals
└── Evidence_Index\          # Master indexes and registries
    ├── EMAIL_ID_REGISTRY.md
    ├── DOC_ID_REGISTRY.md
    ├── SCREENSHOT_ID_REGISTRY.md
    ├── PRA_ID_REGISTRY.md
    ├── EVIDENCE_CROSS_REFERENCE.md
    ├── Evidence_Index_By_Date_FULL.md
    ├── Evidence_Index_By_Person.md
    └── Evidence_Index_Screenshots.md
```

## Actor Profiling

Actors stored in `04_ACTORS\` with hierarchical subcategories:

```
04_ACTORS\
├── 00_Reference\            # Institutional profiles (district, agency)
├── 02_Primary_Respondents\  # Named defendants, primary subjects
├── 04_Secondary_Respondents\# Supporting cast, secondary liability
├── 06_Board_Officials\      # Elected officials, board members
├── 08_Legal_Counsel\        # Attorneys on both sides
├── 10_Insurance\            # Insurance chain actors
├── 12_Allies\               # Supportive parties
├── 14_Tribal\               # Tribal government contacts
├── 16_State_Officials\      # State agency personnel
├── 18_Media\                # Press contacts
├── 20_Federal\              # Federal agency personnel
└── ACTOR-DASHBOARD.md       # Dataview hub
```

Actor YAML template:
```yaml
---
type: actor
name: "{FULL_NAME}"
aliases:
  - "{LAST_NAME}"
role: ""
affiliation: ""
tier: "{primary_respondent|secondary_respondent|ally|neutral|unknown}"
status: "{active|inactive|unknown}"
tags:
  - actor
---
```

## Communications Infrastructure

```
{CASE_ROOT}\00_COMMS\
├── INBOX_TRACKER.md          # Inbound correspondence pipeline
├── OUTBOX_TRACKER.md         # Outbound correspondence staging
├── CORRESPONDENCE_AUDIT.md   # Delinquent threads + penalty clocks
├── _Drafts\                  # Working drafts before send
└── _Templates\               # Composition templates
    ├── Agency_Complaint.md
    ├── Bar_Grievance.md
    ├── Criminal_Referral.md
    ├── FOIA_Request.md
    ├── OCR_Complaint.md
    ├── PRA_Request.md
    ├── State_Auditor_Fraud.md
    ├── State_Education_Complaint.md
    ├── Tort_Notice.md
    └── Tribal_Outreach.md
```

Every sent communication gets:
1. An evidence ID (EMAIL-NNNNN or DOC-NNNNN)
2. An OUTBOX_TRACKER entry
3. A CORRESPONDENCE_AUDIT entry with response deadline
4. A penalty clock trigger if statutory response time applies

## Federal Submission Structure

When preparing evidence for federal agency submission:

```
{submission_name}\
├── 00_COVER\          # Cover letter, index, table of contents
├── 01_INDEX\          # Evidence manifest
├── 02_EMAILS\         # Email evidence (chronological)
├── 03_DOCUMENTS\      # Official documents
├── 04_SCREENSHOTS\    # Screenshot evidence
├── 05_PRA_RESPONSES\  # PRA-related evidence
├── 06_FORENSIC\       # Forensic analysis (metadata, spoliation)
└── 07_SUPPORTING\     # Legal authorities, declarations
```

## Pressure Vector System

Tracked in `05_STRATEGY\PRESSURE_VECTOR_TRACKER.md`. Categories:

| Category | Description |
|----------|-------------|
| Federal | OCR, DOJ, DOE monitoring, FOIA |
| State | State education agency, human rights commission |
| Tribal | Government-to-government, treaty-based |
| Criminal | Law enforcement referrals, prosecutor complaints |
| Insurance | Carrier notice, alter ego, broker liability |
| PRA/FOIA | Public records with penalty clocks |
| Tort | Formal tort claim notices |
| Professional | Bar grievances, licensing complaints |
| Media | Press engagement, public interest |
| Community | Advocacy organizations, tribal coalitions |
| Administrative | Internal reform, board governance |

Each vector entry tracks: Respondent, Filed date, Case #, Status, Statute, Next Action.

## Banned Patterns

Claude must NEVER generate:
- `... and X more`
- `(truncated)`
- `[additional entries omitted]`
- `[remaining items not shown]`
- Any placeholder deferring work

If output limit approached → split into multiple files. Never truncate.

## Archive Discipline

- ONE archive location per case: `{CASE_ROOT}\_Archive\`
- NEVER create `_Archive`, `_archived`, or archive subdirectories inside working folders
- All archived content goes to the single `_Archive\` directory

## QA Validation

After any batch operation:
```powershell
& "{INSTALL_PATH}\00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1" -VaultPath "{CASE_ROOT}"
```

Checks: truncation placeholders, dead wikilinks, index/source count mismatches, YAML frontmatter presence.

## Legal Standards Quick Reference

| Statute | Citation | Key Standard |
|---------|----------|-------------|
| Title VI | 42 U.S.C. § 2000d | Deliberate indifference — *Davis v. Monroe Cnty. Bd. of Educ.*, 526 U.S. 629 (1999) |
| § 504 | 29 U.S.C. § 794 | Failure to accommodate = discrimination |
| § 1983 | 42 U.S.C. § 1983 | Municipal liability — *Monell v. Dep't of Soc. Servs.*, 436 U.S. 658 (1978) |
| IDEA | 20 U.S.C. § 1412(a)(1) | FAPE — *Endrew F. v. Douglas Cnty. Sch. Dist.*, 580 U.S. 386 (2017) |
| FERPA | 20 U.S.C. § 1232g | Education records privacy and access rights |
| ICWA | 25 U.S.C. § 1912 | Active efforts standard for Indian children |
| Treaty rights | Varies by treaty | Federal trust responsibility toward enrolled members |

Full jurisdiction-specific references: `00_PLATFORM\Legal_Reference\`
