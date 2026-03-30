---
type: platform
updated: 2026-03-04
purpose: Onboarding guide for new Bear Point Protocol advocates
---

# Getting Started with the Bear Point Protocol

> **Audience:** Advocates, parents, tribal liaisons, and legal professionals using this platform for the first time.
> **Time to deploy:** ~30 minutes from download to first evidence intake.

---

## What This Is

The Bear Point Protocol is a civil rights advocacy infrastructure built for cases involving institutional discrimination — particularly education discrimination against Native students. It provides:

- **Evidence vault** — systematic collection, cataloging, and cross-referencing of all case evidence
- **Compound pressure tracking** — simultaneous multi-agency, multi-jurisdiction advocacy across federal, state, tribal, and private-sector respondents
- **Communications infrastructure** — correspondence tracking, delinquency auditing, penalty clock monitoring
- **AI integration** — Claude (Anthropic) acts as a legal research assistant, evidence processor, and drafting tool when connected via MCP

The system was built from a live case and stress-tested against a second. It is designed to be deployed by a single advocate with no legal team, no budget, and no institutional support.

---

## Prerequisites

### Required
- Windows 10/11 PC with at least 10GB free storage
- [Obsidian](https://obsidian.md) (free) — the vault interface
- Internet access for agency filings and correspondence

### Required for AI Integration
- [Claude Pro or Team subscription](https://claude.ai) — AI assistant
- Claude Desktop app or claude.ai with MCP filesystem access enabled
- Chrome or Edge browser with Claude extension (for browser automation)

### Recommended
- Scanner or phone camera for document digitization
- PDF reader (Adobe, Foxit, or similar)
- Gmail account dedicated to the case (for MCP email integration)

---

## Step 1: Deploy Your Case

### 1.1 Download the Platform

Download or clone the Bear Point Protocol to a local drive:

```
{INSTALL_PATH}\          ← or any drive letter with space
```

### 1.2 Run the Deployment Script

Open PowerShell and navigate to the platform root:

```powershell
cd {INSTALL_PATH}
.\Deploy-Case.ps1 `
    -CaseName "Smith_v_Springfield_SD" `
    -Complainant "Jane Smith" `
    -Victim "A.S., Minor" `
    -Defendant "Springfield School District" `
    -IncidentDate "2026-01-15"
```

This creates a complete case vault at `{INSTALL_PATH}\01_CASE_Smith_v_Springfield_SD\` with all templates populated.

### 1.3 Open in Obsidian

1. Open Obsidian
2. **Open folder as vault** → select `{INSTALL_PATH}`
3. Trust the vault when prompted
4. Install **Dataview** plugin: Settings → Community plugins → Browse → search "Dataview" → Install → Enable
5. Navigate to your case folder → `00_COMMAND_CENTER\_STATUS.md`

You should see the case dashboard with your variables populated.

---

## Step 2: Connect Claude (AI Integration)

> **Skip this section if operating without AI assistance.** The vault works as a standalone Obsidian system.

### 2.1 Create a Claude Project

1. Go to [claude.ai](https://claude.ai) → Projects → New Project
2. Name it: `[Case Name] — Bear Point Protocol`
3. Upload these files to **Project Knowledge**:
   - `[CASE_ROOT]\00_COMMAND_CENTER\SESSION_STARTUP.md`
   - `{INSTALL_PATH}\_PROTOCOL.md`
4. Add the `evidence-architecture` skill if available (see `00_PLATFORM\Skills\`)

### 2.2 Enable MCP Filesystem Access

MCP (Model Context Protocol) gives Claude direct read/write access to your vault on disk.

1. In Claude Desktop settings, add filesystem MCP server:
   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": [
           "-y",
           "@anthropic-ai/mcp-filesystem",
           "{INSTALL_PATH}"
         ]
       }
     }
   }
   ```
2. Restart Claude Desktop
3. Verify: ask Claude to `Filesystem:list_directory` on your vault root

### 2.3 Enable Gmail MCP (Optional)

For email evidence intake directly through Claude:

1. Claude Desktop settings → add Gmail MCP server
2. Authorize with the Gmail account dedicated to the case
3. Claude can then search, read, and draft emails — but **never sends** without your manual action

### 2.4 Verify Connection

Start a new conversation in the Claude Project. Claude should:
- Read `SESSION_STARTUP.md` automatically
- Read `_STATUS.md` for current case state
- Respond with awareness of your case, evidence IDs, and deadlines

If Claude asks "what would you like help with?" without case context, the Project Knowledge files aren't loading. Re-upload them.

---

## Step 3: Fill in Your Case Dashboard

Open `00_COMMAND_CENTER\_STATUS.md` and complete:

1. **IMMEDIATE SITUATION** — plain-language summary of what happened
2. **ACTIVE FILINGS** — every agency complaint with case numbers
3. **DEADLINE TRACKER** — SOL dates, filing deadlines, response windows
4. **TRIBAL COALITION** — tribes involved, contacts, treaty references
5. **INDIVIDUAL RESPONDENTS** — named individuals with roles and key evidence

This is your war room. Everything flows from here.

---

## Step 4: Begin Evidence Intake

### Manual Intake (No AI)

1. Place raw files in `00_INTAKE\_Raw\`
2. Open the appropriate registry:
   - `03_EVIDENCE\Evidence_Index\EMAIL_ID_REGISTRY.md` (for emails)
   - `03_EVIDENCE\Evidence_Index\DOC_ID_REGISTRY.md` (for documents)
   - `03_EVIDENCE\Evidence_Index\SCREENSHOT_ID_REGISTRY.md` (for screenshots)
3. Find the current max ID
4. Create a new `.md` file in the appropriate `03_EVIDENCE\` subdirectory
5. Name it: `{TYPE}-{NNNNN}_{Short_Descriptor}.md` (e.g., `EMAIL-00001_Initial_Complaint_to_Principal.md`)
6. Add YAML frontmatter (see `00_INTAKE\INTAKE_WORKFLOW_PROTOCOL.md` for template)
7. Update the registry with the new entry
8. Move the raw file to `00_INTAKE\_Processed\`

### AI-Assisted Intake (With Claude)

Tell Claude:
> "I have a new email to intake. Subject: [subject]. From: [sender]. Date: [date]."

Claude will:
1. Check the registry for the next available ID
2. Generate the `.md` file with YAML frontmatter
3. Present it for your approval
4. Write it to the vault (with your confirmation)
5. Update the registry

**Rule:** All vault writes require your approval. Claude will always show you the content before writing.

---

## Step 5: File Your First Agency Complaint

Templates are in `00_COMMS\_Templates\`:

| Template | Use When |
|----------|----------|
| `Agency_Complaint.md` | Filing with OCR, DOJ, state education agency, human rights commission |
| `FOIA_Request.md` | Requesting federal records (OCR case files, DOJ communications) |
| `PRA_Request.md` | Requesting state/local public records (WA: RCW 42.56) |
| `Tort_Notice.md` | 60-day notice of intent to sue a government entity |
| `Criminal_Referral.md` | Referring criminal conduct to law enforcement or prosecutor |
| `Tribal_Outreach.md` | Engaging tribal government or tribal attorney |
| `OCR_Complaint.md` | Specific template for DOE Office for Civil Rights |
| `State_Education_Complaint.md` | State education agency (OSPI, OPI, etc.) |
| `Bar_Grievance.md` | Attorney misconduct complaint to state bar |
| `State_Auditor_Fraud.md` | Public funds fraud complaint to state auditor |

1. Copy the template to `00_COMMS\_Drafts\`
2. Fill in case-specific details
3. Have Claude review for completeness (if AI-connected)
4. Send via the appropriate channel (email, mail, portal)
5. Log the outbound communication in `00_COMMS\OUTBOX_TRACKER.md`
6. Assign an evidence ID to your sent communication
7. Set a response deadline in `00_COMMS\CORRESPONDENCE_AUDIT.md`

---

## Step 6: Track Pressure Vectors

Open `05_STRATEGY\PRESSURE_VECTOR_TRACKER.md`. For each complaint or action you file, create a vector entry:

```markdown
### 1.1 DOE OCR Title VI Investigation
| Field | Value |
|-------|-------|
| **Respondent** | Springfield School District |
| **Filed** | 2026-01-20 |
| **Status** | ✅ ACTIVE — acknowledgment received |
| **Statute** | Title VI, Civil Rights Act of 1964 (42 U.S.C. § 2000d) |
| **Next Action** | Await investigator assignment |
```

The compound pressure model works by maintaining multiple independent vectors simultaneously. No single agency controls all of them. The respondent cannot negotiate away all pressure points at once.

---

## Daily Workflow

1. **Check `_STATUS.md`** — what's active, what's due
2. **Check `CORRESPONDENCE_AUDIT.md`** — any delinquent threads?
3. **Process new evidence** — emails, screenshots, documents → intake pipeline
4. **Update trackers** — new developments, status changes, deadline movements
5. **Draft correspondence** — responses, follow-ups, new filings
6. **End-of-session:** update `_STATUS.md` with any changes

---

## Key Principles

1. **Document everything.** The claimant does not need to endure. The claimant needs only to document.
2. **Preserve exact language.** Sanitizing weakens the evidentiary record and serves institutional interests.
3. **Maintain information asymmetry.** Respondents don't know the full scope of your documentation.
4. **Apply compound pressure.** Multiple independent vectors across federal, state, tribal, and private-sector respondents simultaneously.
5. **Build systems, not just cases.** This infrastructure is designed to be replicated and shared.

---

## Getting Help

- **Vault rules:** `_PROTOCOL.md` (platform root)
- **Tool inventory:** `00_PLATFORM\TOOLCHAIN.md`
- **MMIW resources:** `00_PLATFORM\MMIW_Research\MMIW_RESEARCH_HUB.md`
- **Bearpoint Foundation:** `00_PLATFORM\Bearpoint\BEARPOINT_FOUNDATION.md`
- **QA validation:** Run `00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1 -VaultPath "[CASE_ROOT]"`

---

## Platform Links

- [[README]] — Platform overview and deploy instructions
- [[_PROTOCOL]] — Vault rules and core principles
- [[TOOLCHAIN]] — Available tools and setup
- [[BEARPOINT_FOUNDATION]] — Nonprofit architecture
- [[MMIW_RESEARCH_HUB]] — MMIW research resources
