---
type: status
updated: "[Today's date]"
scope: case-wide
pinned: true
tags:
  - dashboard
  - status
  - active
---

# CASE STATUS DASHBOARD
**Last Updated:** [Today's date]

> [!tip] HOW TO USE THIS FILE
> This is your war room. Fill in the sections below with your case information.
> If you used the Deploy-Case.ps1 script, some of this will be pre-filled.
> If you copied the folder manually, just replace the bracketed text with your info.
> Update this file whenever something significant happens in your case.

---

## BACKUP PROTOCOL

| Field | Value |
|-------|-------|
| **Primary backup location** | `{BACKUP_PATH}\` |
| **Naming format** | `YYYY-MM-DD_backup` (routine) or `YYYY-MM-DD_description` (milestone) |
| **When** | Before batch operations, tier restructures, or any multi-file YAML edits |
| **Latest backup** | — |

> To back up your case folder, open PowerShell and run:
> `robocopy "[Your case folder path]" "{BACKUP_PATH}\YYYY-MM-DD_backup" /E /Z /MT:8`
> Replace the path and date with your actual values.

---

## IMMEDIATE SITUATION

> [!danger] CASE SUMMARY
> **Complainant:** [Your name]
> **Child:** [Child's name or initials] ([Child's age], [Tribe name])
> **Respondent:** [School district or institution name]
> **Incident date:** [Date of first incident]
> **Summary:** [Brief description of what happened]

---

## CASE SNAPSHOT

| Field | Value |
|-------|-------|
| **Case** | [Your case name] |
| **Primary Victim** | [Child's name or initials] |
| **Incident Date** | [Date of first incident] |
| **Documented Violations** | — |
| **Evidence Items** | 0 indexed |

---

## ACTIVE FILINGS

> Add a row each time you file a complaint with an agency.

| Agency | Case # | Filed | Status | Next Action |
|--------|--------|-------|--------|-------------|
| — | — | — | — | — |

---

## DEADLINE TRACKER

> For detailed deadline tracking, see [[DEADLINE_TRACKER]].

| Deadline | Event | Status |
|----------|-------|--------|
| — | — | — |

---

## CRITICAL EVENTS

> Document significant events in reverse chronological order (newest first).

| Date | Event | Evidence ID |
|------|-------|-------------|
| — | — | — |

---

## TRIBAL COALITION

> If the child is an enrolled member of a federally recognized tribe, track tribal engagement here.

| Tribe | Treaty | Contact | Status |
|-------|--------|---------|--------|
| — | — | — | — |

---

## INDIVIDUAL RESPONDENTS

> Named individuals involved in the discrimination or cover-up.

| Name | Role | Status | Key Evidence |
|------|------|--------|--------------|
| — | — | — | — |

---

## EVIDENCE STATUS

| Category | Count | Status |
|----------|-------|--------|
| Email .md files | 0 | — |
| Official Documents .md files | 0 | — |
| Screenshot .md files | 0 | — |
| PRA .md files | 0 | — |
| EMAIL PDFs (pdf_export) | 0 | — |

---

## PROCESSING QUEUE

### NEXT SESSION — PRIORITY QUEUE
- [ ] —

### High Priority
- [ ] —

### Medium Priority
- [ ] —

---

## COMPOUND PRESSURE STATUS

> Each row is one active complaint or legal vector. See [[PRESSURE_VECTOR_TRACKER]] for details.

| Vector | Respondent | Status |
|--------|--------|--------|
| — | — | — |

---

## QUICK NAVIGATION

| Resource | Location |
|----------|----------|
| Mission Control | [[_STATUS]] |
| Evidence Registry | [[EMAIL_ID_REGISTRY]] / [[DOC_ID_REGISTRY]] / [[SCREENSHOT_ID_REGISTRY]] / [[PRA_ID_REGISTRY]] |
| Deadline Tracker | [[DEADLINE_TRACKER]] |
| Actor Dashboard | [[ACTOR-DASHBOARD]] |
| Inbox Tracker | [[INBOX_TRACKER]] |
| Outbox Tracker | [[OUTBOX_TRACKER]] |
| Correspondence Audit | [[CORRESPONDENCE_AUDIT]] |

---

## VAULT HEALTH

| Metric | Status |
|--------|--------|
| Dashboard | — |
| Evidence Registry | — |
| Deadline Tracker | — |
| Catch-Bullshit | — |
| Vault confidence | — |
