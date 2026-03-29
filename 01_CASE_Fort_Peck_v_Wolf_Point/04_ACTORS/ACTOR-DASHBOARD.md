---
type: dashboard
updated: 2026-03-03
purpose: Central hub for actor tracking with Dataview queries
tags:
  - actors
  - dashboard
  - dataview
---

# ACTOR DASHBOARD
**Case:** Fort Peck v. Wolf Point

---

## Summary

| Category | Count |
|----------|-------|
| Primary Respondents | 1 |
| Secondary Respondents | 0 |
| Board/Officials | 0 |
| Legal Counsel | 2 |
| Insurance | 0 |
| Allies | 2 |
| Tribal | 0 (represented via Allies) |
| State Officials | 0 |
| Media | 0 |
| Federal | 0 |
| Reference | 1 |
| **TOTAL** | **6** |

---

## All Actors by Category

### 02_Primary_Respondents
```dataview
TABLE role, status
FROM "01_CASE_Fort_Peck_v_Wolf_Point/04_ACTORS/02_Primary_Respondents"
WHERE type = "actor"
SORT name ASC
```

### 08_Legal_Counsel
```dataview
TABLE role, affiliation, status
FROM "01_CASE_Fort_Peck_v_Wolf_Point/04_ACTORS/08_Legal_Counsel"
WHERE type = "actor"
SORT name ASC
```

### 12_Allies
```dataview
TABLE role, affiliation, status
FROM "01_CASE_Fort_Peck_v_Wolf_Point/04_ACTORS/12_Allies"
WHERE type = "actor"
SORT name ASC
```

### 00_Reference
```dataview
TABLE role, affiliation
FROM "01_CASE_Fort_Peck_v_Wolf_Point/04_ACTORS/00_Reference"
WHERE type = "reference"
SORT name ASC
```

---

## Actors Not Yet Profiled

| Name | Role | Priority |
|------|------|----------|
| [UNKNOWN] | HS Principal (2017 — berated Jayden Joe) | HIGH — identify from records |
| Ruth Fourstar | Student witness (profiled by ProPublica) | MEDIUM |
| Louella Contreras | Grandmother; separate OCR complaint | MEDIUM |
| Jayden Joe | Deceased student (Mar 2017) | LOW — memorial record only |
| Elsie Arntzen | MT Superintendent of Public Instruction | MEDIUM — Yellow Kidney defendant |
| Annie Waldman | ProPublica reporter | LOW — media contact |
| Erica L. Green | NYT reporter | LOW — media contact |

---

## Quick Reference — Current Roster

| Name | File | Category | Tier |
|------|------|----------|------|
| Rob Osborne | [[Rob_Osborne]] | Primary Respondent | primary_respondent |
| Roxanne Gourneau | [[Roxanne_Gourneau]] | Ally | ally |
| Ron Jackson | [[Ron_Jackson]] | Ally | ally |
| Melina Healey | [[Melina_Healey]] | Legal Counsel | ally |
| Jeana Lervick | [[Jeana_Lervick]] | Legal Counsel | secondary_respondent |
| Wolf Point SD | [[Wolf_Point_School_District]] | Reference | — |
