---
type: protocol
updated: "[Today's date]"
tags:
  - intake
  - workflow
  - protocol
---

# INTAKE WORKFLOW PROTOCOL

> **Purpose:** Standard operating procedure for processing new evidence into the vault.
> **Rule:** Every piece of evidence gets an ID, YAML frontmatter, and index entry. No exceptions.

---

## INTAKE PIPELINE

### Step 1: Receive
- Email → Gmail MCP `search_messages` → download to `00_INTAKE/_Raw/`
- Document → Save to `00_INTAKE/_Raw/`
- Screenshot → Save .png to `00_INTAKE/_Raw/`
- PRA response → Save to `00_INTAKE/_Raw/`

### Step 2: Assign ID
- Check registry for current max ID
- Assign next sequential ID
- Update registry immediately

### Step 3: Create Evidence .md
- Create file: `{TYPE}-{NNNNN}_{Descriptor}.md`
- Max 50-char descriptor, underscores for spaces
- Place in correct `03_EVIDENCE/{type}/` subdirectory

### Step 4: YAML Frontmatter

**EMAIL template:**
```yaml
---
type: EMAIL
evidence_id: EMAIL-{NNNNN}
date: YYYY-MM-DD
from: ""
to: ""
cc: ""
subject: ""
thread_id: ""
gmail_message_id: ""
pdf_export: "PDF_Exports/EMAIL-{NNNNN}_{descriptor}.pdf"
tags:
  - email
---
```

**DOC template:**
```yaml
---
type: DOC
evidence_id: DOC-{NNNNN}
date: YYYY-MM-DD
title: ""
source: ""
pdf_export: ""
tags:
  - document
---
```

**SCREENSHOT template:**
```yaml
---
type: SCREENSHOT
evidence_id: SCREENSHOT-{NNNNN}
date: YYYY-MM-DD
description: ""
actor: ""
source_url: ""
png_file: ""
tags:
  - screenshot
---
```

**PRA template:**
```yaml
---
type: PRA
evidence_id: PRA-{NNNNN}
date: YYYY-MM-DD
request_or_response: ""
agency: ""
pra_number: ""
tags:
  - pra
---
```

### Step 5: Export PDF
- Print email to PDF → save to `03_EVIDENCE/PDF_Exports/`
- Name: `EMAIL-{NNNNN}_{descriptor}.pdf`
- Update `pdf_export` field in YAML

### Step 6: Index
- Add entry to `Evidence_Index_By_Date_FULL.md`
- Add entry to `Evidence_Index_By_Person.md` (if email)
- Update `EVIDENCE_CROSS_REFERENCE.md` topic sections as needed

### Step 7: Move Raw
- Move processed file from `00_INTAKE/_Raw/` to `00_INTAKE/_Processed/`

### Step 8: Update Trackers
- Update `_STATUS.md` evidence counts
- Update `INBOX_TRACKER.md` (if inbound email)
- Update `CORRESPONDENCE_AUDIT.md` (if thread creates response obligation)
- Log in `OUTBOX_TRACKER.md` (if outbound)

---

## BATCH INTAKE

For bulk email processing:
1. Gmail MCP → pull all matching emails
2. Assign ID range (e.g., EMAIL-00001 through EMAIL-00025)
3. Create all .md files
4. Batch PDF export
5. Batch index update
6. Run `Catch-Bullshit.ps1` to verify

---

## EVIDENCE NAMING CONVENTION

| Type | Pattern | Example |
|------|---------|---------|
| EMAIL | `EMAIL-{NNNNN}_{Descriptor}.md` | `EMAIL-00001_Initial_Complaint_Filing.md` |
| DOC | `DOC-{NNNNN}_{Descriptor}.md` | `DOC-00001_Tort_Claim_Notice.md` |
| SCREENSHOT | `SCREENSHOT-{NNNNN}_{Descriptor}.md` | `SCREENSHOT-00001_Portal_Lockout.md` |
| PRA | `PRA-{NNNNN}_{Descriptor}.md` | `PRA-00001_Records_Request_Personnel.md` |

**Rules:**
- Max 50-character descriptor
- Underscores for spaces
- No special characters except hyphens in ID prefix
- Sequential only — never skip, never reuse

---

## VALIDATION

After any intake session:
```powershell
& "F:\Bear_Point_Protocol\00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1" -VaultPath "[Your case folder path]"
```

---

*Last updated: [Today's date]*
