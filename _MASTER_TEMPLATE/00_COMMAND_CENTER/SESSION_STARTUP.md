---
type: startup
updated: "[Today's date]"
purpose: Session initialization — read vault files before responding
---

# Session Startup Protocol

> **This file loaded automatically via Project knowledge.**
> **Read vault files below before responding to user.**

---

## Mandatory Vault Reads (Use Filesystem:read_text_file)

| Priority | File | Purpose |
|----------|------|---------|
| 1 | `[Your case folder path]\00_COMMAND_CENTER\_STATUS.md` | Current state, active tasks |
| 2 | `[Your case folder path]\00_COMMAND_CENTER\DEADLINE_TRACKER.md` | SOL dates, filing deadlines |
| 3 | `F:\Bear_Point_Protocol\00_PLATFORM\TOOLCHAIN.md` | Installed tools, venv path |

> **Note:** Replace `[Your case folder path]` with the actual path to your case.
> Example: `F:\Bear_Point_Protocol\01_CASE_Smith_v_Springfield\`

**Read these BEFORE responding to first user message.**

---

## Tool Priority

| Priority | Tool | Access | Use For |
|----------|------|--------|---------|
| 1 | `Filesystem:` | F:\ vault (user's PC) | All vault operations |
| 2 | `Gmail:` | Gmail MCP | Email intake, drafts, search |
| 3 | `PDF Tools:` | User's PC | Forms, extraction |
| 4 | `bash_tool` | Claude container only | NO F:\ access |

**Filesystem tools operate on user's PC. Bash operates on Claude's container.**

---

## Banned Output Patterns

NEVER generate:
- `*... and X more*`
- `(truncated)`
- `[additional entries omitted]`
- Any placeholder deferring work

If output limit approached → split files. Never truncate.

---

## Vault Write Protocol

1. All writes require user approval
2. Show content first
3. Wait for explicit confirmation
4. Then execute write

---

## Evidence ID Assignment

| Type | Registry | Location |
|------|----------|----------|
| EMAIL | [[EMAIL_ID_REGISTRY]] | 03_EVIDENCE/Email_Evidence/ |
| DOC | [[DOC_ID_REGISTRY]] | 03_EVIDENCE/Official_Documents/ |
| SCREENSHOT | [[SCREENSHOT_ID_REGISTRY]] | 03_EVIDENCE/Screenshot_Evidence/ |
| PRA | [[PRA_ID_REGISTRY]] | 03_EVIDENCE/PRA/ |

**CHECK REGISTRY FOR CURRENT MAX BEFORE ASSIGNING NEW IDs.**

---

## Evidence Search Paths

| Search Type | Index File |
|-------------|------------|
| By Date | `Evidence_Index_By_Date_FULL.md` |
| By Person | `Evidence_Index_By_Person.md` |
| By Topic | `EVIDENCE_CROSS_REFERENCE.md` |
| Screenshots | `Evidence_Index_Screenshots.md` |
| Actor Profiles | `04_ACTORS/` |

---

## Communications Front-End

| Tracker | Purpose |
|---------|---------|
| [[INBOX_TRACKER]] | Inbound correspondence + intake pipeline |
| [[OUTBOX_TRACKER]] | Outbound correspondence + draft staging |
| [[CORRESPONDENCE_AUDIT]] | Delinquent threads + penalty clocks |
| `00_COMMS/_Templates/` | Email composition templates |
| `00_COMMS/_Drafts/` | Working drafts before send |

---

## Backup Command (Before Batch Operations)

```powershell
robocopy "[Your case folder path]" "D:\Vault back ups\$(Get-Date -Format 'yyyy-MM-dd_HHmm')" /E /Z /MT:8
```

---

## Validation Script

```powershell
& "F:\Bear_Point_Protocol\00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1" -VaultPath "[Your case folder path]"
```

---

## Key Paths

| Resource | Path |
|----------|------|
| Platform root | `F:\Bear_Point_Protocol\` |
| Case root | `[Your case folder path]` |
| Shared scripts | `F:\Bear_Point_Protocol\00_PLATFORM\Scripts\` |
| Python venv | `F:\Bear_Point_Protocol\00_PLATFORM\Scripts\.venv\` |
| Legal reference | `F:\Bear_Point_Protocol\00_PLATFORM\Legal_Reference\` |

---

## Allies — Do Not Implicate

> Add names of people who are helping your case. Claude will avoid including them as respondents.

| Name | Role | Status |
|------|------|--------|
| — | — | ALLY |

---

## Session Hygiene

- Update `_STATUS.md` at session end if significant changes made
- Evidence ID ranges update frequently — verify before assigning new IDs
- Run Catch-Bullshit after any batch operation
- Log session work in `08_CLAUDE_SESSIONS/`
