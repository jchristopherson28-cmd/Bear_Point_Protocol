---
type: dashboard
updated: "[Today's date]"
tags:
  - actors
  - dashboard
  - dataview
---

# ACTOR DASHBOARD

> [!info] WHAT IS THIS?
> This page lists every person involved in your case — school officials, board members,
> attorneys, tribal contacts, allies, and anyone else. Each person gets their own file
> in the `04_ACTORS/` subfolders.
>
> **If you have the Dataview plugin:** The tables below auto-populate from actor files.
> You need to update the folder path in each query — replace `[your case folder]`
> with your actual folder name (example: `01_CASE_Smith_v_Springfield_SD`).
>
> **If you don't have Dataview:** Just add rows to the manual tables below each section.

---

## Primary Respondents

> The main people responsible — superintendent, principal, HR director, etc.

| Name | Role | Affiliation | Status |
|------|------|-------------|--------|
| — | — | — | — |

```dataview
TABLE role, tier, status, affiliation
FROM "[your case folder]/04_ACTORS/02_Primary_Respondents"
SORT file.name ASC
```

---

## Secondary Respondents

> Supporting cast — staff who participated, documented bad actors with less direct liability.

| Name | Role | Affiliation | Status |
|------|------|-------------|--------|
| — | — | — | — |

```dataview
TABLE role, tier, status, affiliation
FROM "[your case folder]/04_ACTORS/04_Secondary_Respondents"
SORT file.name ASC
```

---

## Board / Officials

| Name | Role | Status |
|------|------|--------|
| — | — | — |

```dataview
TABLE role, tier, status
FROM "[your case folder]/04_ACTORS/06_Board_Officials"
SORT file.name ASC
```

---

## Legal Counsel

| Name | Role | Firm | Status |
|------|------|------|--------|
| — | — | — | — |

```dataview
TABLE role, tier, status, affiliation
FROM "[your case folder]/04_ACTORS/08_Legal_Counsel"
SORT file.name ASC
```

---

## Insurance

| Name | Role | Company | Status |
|------|------|---------|--------|
| — | — | — | — |

```dataview
TABLE role, tier, status, affiliation
FROM "[your case folder]/04_ACTORS/10_Insurance"
SORT file.name ASC
```

---

## Allies

> People helping you. Claude will never list them as respondents.

| Name | Role | Status |
|------|------|--------|
| — | — | ALLY |

```dataview
TABLE role, tier, status
FROM "[your case folder]/04_ACTORS/12_Allies"
SORT file.name ASC
```

---

## Tribal Contacts

| Name | Role | Tribe | Status |
|------|------|-------|--------|
| — | — | — | — |

```dataview
TABLE role, tribe, tier, status
FROM "[your case folder]/04_ACTORS/14_Tribal"
SORT file.name ASC
```

---

## State Officials

| Name | Role | Agency | Status |
|------|------|--------|--------|
| — | — | — | — |

```dataview
TABLE role, agency, tier, status
FROM "[your case folder]/04_ACTORS/16_State_Officials"
SORT file.name ASC
```

---

## Media

| Name | Role | Outlet | Status |
|------|------|--------|--------|
| — | — | — | — |

```dataview
TABLE role, outlet, tier, status
FROM "[your case folder]/04_ACTORS/18_Media"
SORT file.name ASC
```

---

## Federal Officials

| Name | Role | Agency | Status |
|------|------|--------|--------|
| — | — | — | — |

```dataview
TABLE role, agency, tier, status
FROM "[your case folder]/04_ACTORS/20_Federal"
SORT file.name ASC
```

---

## How to Add a New Person

1. Create a new `.md` file in the right subfolder (example: `04_ACTORS/02_Primary_Respondents/John_Smith.md`)
2. Paste this at the top of the file and fill it in:

```yaml
---
type: actor
name: "Person's Full Name"
aliases:
  - "Last Name"
role: "Their job title or role"
affiliation: "Their employer or organization"
tier: "primary_respondent"
status: "active"
tags:
  - actor
---
```

3. Below the `---`, write what you know about them and what they did.

**Tier options:** `primary_respondent`, `secondary_respondent`, `ally`, `neutral`, `unknown`
**Status options:** `active`, `inactive`, `unknown`

---

*Last updated: [Today's date]*
