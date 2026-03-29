---
type: protocol
updated: {DEPLOY_DATE}
---

# BEAR POINT PROTOCOL — VAULT RULES

> **This vault is part of the Bear Point Protocol platform.**
> **Each case folder is deployed from `_MASTER_TEMPLATE\` and operates independently.**

---

## Core Principles

1. **Implicit truth / no sanitization** — Exact language preserved. Sanitizing weakens the evidentiary record and serves institutional interests.
2. **Information asymmetry** — Defendants don't know the full scope of documentation. Strategic ambiguity maintained.
3. **Compound pressure** — Multiple independent vectors applied simultaneously across federal, state, tribal, and private-sector respondents.
4. **Document everything** — The claimant does not need to endure. The claimant needs only to document.
5. **Replicable infrastructure** — Build systems, not just cases. Open-source distribution to tribal communities first.

---

## Vault Structure

| Level | Purpose |
|-------|---------|
| `F:\Bear_Point_Protocol\` | Platform root |
| `00_PLATFORM\` | Shared infrastructure (scripts, legal reference, MMIW, Bearpoint docs) |
| `_MASTER_TEMPLATE\` | Gold copy — NEVER edit directly. Deploy-Case.ps1 copies this. |
| `01_CASE_{name}\` through `99_CASE_{name}\` | Deployed case instances |

---

## Evidence Rules

1. Sequential ID assignment only — never reuse, never skip without documenting
2. Every evidence item gets: ID, YAML frontmatter, index entry
3. All vault writes require user approval
4. Run Catch-Bullshit.ps1 after any batch operation
5. Backup before destructive operations
6. NEVER create `_Archive` subdirectories inside working folders — one `_Archive\` per case root

---

## Naming Convention

| Type | Pattern | Max Descriptor |
|------|---------|---------------|
| EMAIL | `EMAIL-{NNNNN}_{Descriptor}.md` | 50 chars |
| DOC | `DOC-{NNNNN}_{Descriptor}.md` | 50 chars |
| SCREENSHOT | `SCREENSHOT-{NNNNN}_{Descriptor}.md` | 50 chars |
| PRA | `PRA-{NNNNN}_{Descriptor}.md` | 50 chars |

Underscores for spaces. No special characters except hyphens in ID prefix.

---

## Communications Protocol

- All email intake flows through `00_COMMS\` → `03_EVIDENCE\`
- Outbound drafts composed in `00_COMMS\_Drafts\`
- Every sent email gets an evidence ID and index entry
- Correspondence audit tracks delinquent threads and penalty clocks
- Gmail MCP for search/read/draft — user sends manually

---

## Archive Discipline

- ONE archive location per case: `{CASE_ROOT}\_Archive\`
- NEVER create `_Archive`, `_archived`, or archive subdirectories inside working folders
- All archived content goes to the single `_Archive\` directory

---

## Script Location

- Shared scripts: `F:\Bear_Point_Protocol\00_PLATFORM\Scripts\`
- Case-specific scripts: `{CASE_ROOT}\06_DATA_PROCESSING\scripts\` (if needed)
- All scripts reference `$VaultPath` parameter, not hardcoded paths

---

## Platform Links

- [[README]] — Platform overview and deploy instructions
- [[TOOLCHAIN]] — Available tools and setup
- [[BEARPOINT_FOUNDATION]] — Nonprofit architecture
- [[MMIW_RESEARCH_HUB]] — MMIW research resources
- [[GETTING_STARTED]] — Onboarding guide for new advocates

---

## Claude Project Setup (Per Case)

Each deployed case gets its own Claude Project for context isolation.

### Creating the Project

1. [claude.ai](https://claude.ai) → Projects → **New Project**
2. Name: `{Case Name} — Bear Point Protocol`
3. Description: `Civil rights advocacy vault — {Complainant} v. {Defendant}`

### Project Knowledge Files (Upload These)

| File | Purpose | Required |
|------|---------|----------|
| `{CASE_ROOT}\00_COMMAND_CENTER\SESSION_STARTUP.md` | Session initialization — mandatory vault reads, ID ranges, tool priority | YES |
| `F:\Bear_Point_Protocol\_PROTOCOL.md` | Platform rules, principles, archive discipline | YES |
| `F:\Bear_Point_Protocol\00_PLATFORM\Scripts\01_QA\Catch-Bullshit.ps1` | QA reference — Claude reads but doesn't run directly | RECOMMENDED |

### Custom Instructions (Paste into Project)

```
Accurate and factual only. No hedging, no filler. Flag unknowns explicitly.
Check MCP filesystem access first. Write directly to vault when MCP allows.
All vault writes require user approval — show content first, wait for confirmation.
Before assigning evidence IDs, check the appropriate registry for current max.
PowerShell for Windows commands. Markdown for documents. Obsidian-compatible formatting.
Bluebook citation format for legal documents.
Never truncate output — split files if approaching limit.
```

### Skill Attachment

If using evidence-architecture skill:
1. Settings → Claude Skills → Add Skill
2. Point to `F:\Bear_Point_Protocol\00_PLATFORM\Skills\evidence-architecture\SKILL.md`
3. Skill triggers automatically on evidence intake, ID assignment, federal submission, actor profiling

---

## MCP Filesystem Configuration

MCP (Model Context Protocol) gives Claude direct read/write access to the vault filesystem.

### Claude Desktop Configuration

Add to Claude Desktop settings (`%APPDATA%\Claude\claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-filesystem",
        "F:\\Bear_Point_Protocol"
      ]
    }
  }
}
```

### Access Scope

MCP filesystem grants read/write to `F:\Bear_Point_Protocol` and all subdirectories. This includes:
- All case vaults (`01_CASE_*\` through `99_CASE_*\`)
- Platform infrastructure (`00_PLATFORM\`)
- Master template (`_MASTER_TEMPLATE\`) — **NEVER write here; read-only by convention**

### Tool Priority

| Priority | Tool | Scope | Use For |
|----------|------|-------|--------|
| 1 | `Filesystem:` tools | User's PC (vault) | All vault read/write operations |
| 2 | `Gmail:` tools | Cloud (Gmail API) | Email search, read, draft |
| 3 | `PDF Tools:` | User's PC | PDF analysis, extraction, form fill |
| 4 | `bash_tool` | Claude's container | Code execution, file processing — NO vault access |

**Critical:** `bash_tool` operates on Claude's remote container, NOT the user's filesystem. Never use `bash_tool` to write vault files. Always use `Filesystem:` tools for vault operations.

### Verification

After configuration, test with:
```
"List the contents of F:\Bear_Point_Protocol"
```
Claude should respond using `Filesystem:list_directory` and show platform structure.

---

## Gmail MCP Integration

Gmail MCP enables Claude to search, read, and draft emails for evidence intake and correspondence management.

### Setup

1. Claude Desktop → Settings → MCP Servers → Add Gmail
2. Authorize with the case-dedicated Gmail account
3. Gmail MCP provides: `gmail_search_messages`, `gmail_read_message`, `gmail_read_thread`, `gmail_create_draft`, `gmail_get_profile`, `gmail_list_drafts`

### Evidence Intake from Email

Workflow when processing inbound evidence from Gmail:

1. **Search:** `gmail_search_messages` with sender, date range, or subject keywords
2. **Read:** `gmail_read_message` or `gmail_read_thread` for full content
3. **Extract:** Pull sender, recipient, date, subject, body text
4. **Check registry:** `Filesystem:read_text_file` on appropriate `_ID_REGISTRY.md`
5. **Assign ID:** Next sequential EMAIL-NNNNN
6. **Create evidence file:** `Filesystem:write_file` to `03_EVIDENCE\Email_Evidence\`
7. **Update registry:** `Filesystem:edit_file` on registry
8. **Update indexes:** Date index, person index, cross-reference as applicable
9. **Log in INBOX_TRACKER:** `Filesystem:edit_file` on `00_COMMS\INBOX_TRACKER.md`

### Outbound Correspondence

1. Draft in `00_COMMS\_Drafts\` using appropriate template
2. Claude creates Gmail draft via `gmail_create_draft`
3. **User reviews and sends manually** — Claude never sends email directly
4. After send: assign evidence ID, log in OUTBOX_TRACKER, set response deadline in CORRESPONDENCE_AUDIT

### Security Rules

- Claude never sends email — drafts only, user sends manually
- Claude never deletes email
- Claude never modifies email after intake
- Gmail MCP credentials are per-session; no persistent token storage in vault

---

## PDF Tools Workflow

PDF Tools extension handles document analysis, extraction, form filling, and forensic examination.

### Common Operations

| Task | Tool | Use Case |
|------|------|----------|
| Extract text from PDF | PDF Tools: extract | Converting district records to searchable evidence |
| Fill federal forms | PDF Tools: fill | OCR complaint forms, FOIA requests |
| Compare PDFs | PDF Tools: compare | Detecting spoliation (print-to-scan degradation) |
| Analyze metadata | `exiftool` (via Filesystem) | Creation dates, modification history, author fields |
| OCR scanned PDFs | `ocrmypdf` (via platform venv) | Making image-only PDFs searchable |

### Spoliation Detection Workflow

When suspecting document tampering:

1. **Obtain native PDF** (original digital document)
2. **Obtain suspect PDF** (potentially degraded production)
3. Compare metadata: creation date, producer, page count
4. Check for: print-to-scan conversion, image-only pages, stripped bookmarks
5. Document findings in `03_EVIDENCE\PRA\Analysis\`
6. If confirmed: classify as FEDERAL_EXHIBIT, flag for criminal referral

---

## Tribal Consultation Protocol

> **This section provides procedural guidance. Cultural protocols are transmitted through relationship, not documentation. Always defer to tribal leadership on cultural matters.**

### Principles

1. **Sovereignty first.** Tribal governments are sovereign nations with independent authority. They are not stakeholders — they are governments.
2. **Government-to-government.** Communications with tribal government go through proper channels — tribal attorney, ICWA department, or designated liaison.
3. **Defer to tribal priorities.** If a tribe's strategy for their enrolled member differs from the advocate's strategy, the tribe's strategy prevails for treaty-based claims.
4. **Protect ceremonial and cultural information.** Never document ceremonial practices, spiritual beliefs, or cultural knowledge in the evidence vault. These are not evidence — they are protected.
5. **Enrolled membership is the child's.** Enrollment status belongs to the child and the tribe, not the non-Native parent. Documentation references enrollment for jurisdictional purposes only.

### Engagement Workflow

1. **Initial outreach:** Use `00_COMMS\_Templates\Tribal_Outreach.md` template
2. **Route through tribal attorney** (ICWA department or tribal counsel)
3. **Provide case summary** — facts only, no legal strategy
4. **Ask:** "How does the tribe wish to be involved?"
5. **Document tribal response** in CORRESPONDENCE_AUDIT
6. **Never pressure tribal engagement** — tribes engage on their own timeline
7. **If tribe designates counsel:** coordinate through designated attorney only

### ICWA Applicability

If the child is an enrolled member or eligible for enrollment:
- ICWA applies to any proceeding involving custody, foster care, termination of parental rights, or pre-adoptive placement
- Active efforts standard (25 U.S.C. § 1912): higher than "reasonable efforts"
- Tribe has right to intervene in state proceedings
- Notify tribe of all proceedings affecting the child

### Treaty Rights

Treaty obligations create federal trust responsibility independent of statutory claims. When a state entity harms an enrolled member of a treaty tribe:
- The federal government has a trust obligation to the tribe and its members
- The tribe has sovereign authority to pursue treaty-based remedies
- Treaty claims are not subject to state-court jurisdiction absent Congressional authorization
- Government-to-government dispute resolution may apply

---

## Settlement and Negotiation Firewall

### Rules

1. **Never discuss settlement figures in unsecured communications.** Email is not secure. Phone or in-person only.
2. **Never acknowledge a dollar amount** in writing unless it's a formal demand or formal offer.
3. **Never waive claims casually.** Phrases like "we'd be willing to drop the PRA claim if..." constitute potential waiver. Every claim is independently valuable.
4. **Every communication is evidence.** Assume every email, letter, and recorded call will be read by a judge. Write accordingly.
5. **Compound pressure is not a bargaining position.** It is the case. Never offer to "reduce pressure" in exchange for anything. Vectors are maintained until resolved on their own terms.
6. **Tribal claims are not the advocate's to negotiate.** If a tribe has independent treaty-based claims, only tribal counsel can negotiate those claims.
7. **Settlement funds commitment.** If settlement funds are pledged toward indigenous healing programs or other purposes, this commitment is documented and honored.

### Pre-Negotiation Checklist

Before any settlement discussion:
- [ ] All evidence cataloged and indexed
- [ ] All active vectors documented with current status
- [ ] SOL analysis current for all claims
- [ ] Tribal counsel consulted on tribal-dimension claims
- [ ] Penalty clock calculations current (PRA, tort deadlines)
- [ ] Full damages model documented (not just "what we'd accept")

---

## Data Security

### Vault Security

- Vault stored on local drive — not cloud-synced by default
- If using cloud backup: encrypt the vault directory before upload
- BitLocker recommended for the drive containing the vault
- Never store vault on shared network drives without encryption

### Sensitive Information

- Social Security numbers, medical record numbers, and financial account numbers: **NEVER** stored in `.md` files
- Student records (FERPA-protected): store only what's necessary for the evidentiary record; mark with `classification: FERPA_SENSITIVE` in YAML
- Attorney-client privileged communications: store in `02_CASE_FILES\` with `privileged: true` YAML tag — never in `03_EVIDENCE\`
- Tribal enrollment numbers: reference for jurisdictional purposes only; do not reproduce enrollment documents

### Access Control

- Single-advocate model: one person controls the vault
- Multi-advocate access: use separate Claude Projects per advocate; shared vault via encrypted shared drive
- Never grant vault access to respondents, their counsel, or their agents
- If vault is subpoenaed: consult attorney immediately; privileged materials require log review
