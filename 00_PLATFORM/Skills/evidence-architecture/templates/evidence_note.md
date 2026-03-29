---
type: "{evidence_type}"
evidence_id: "{TYPE}-{NNNNN}"
classification: "ROUTINE"
source_file: "{original_filename}"
source_hash: "{sha256_first_16_chars}"
date: "{YYYY-MM-DDTHH:MM:SS+00:00}"
subject: "{full_subject_line}"
from_name: "{sender_name}"
from_email: "{sender@email.com}"
to: "{recipient}"
case_references:
  - "{agency} {case_number}"
tags:
  - "{evidence_type}"
  - "{case_keyword}"
extracted: "{ISO_timestamp}"
---

# {Subject Line}

## Evidence Details

| Field | Value |
|-------|-------|
| **From** | {sender_name} <{sender_email}> |
| **To** | {recipient} |
| **Date** | {date} |
| **Subject** | {subject} |
| **Classification** | {ROUTINE/CRITICAL/FEDERAL_EXHIBIT} |

## Content

```
{Body content here}
```

## Analysis Notes

- 

## Evidence Metadata

- **Evidence ID**: `{TYPE}-{NNNNN}`
- **Source File**: {original_filename}
- **Source Hash**: `{sha256_hash}`
- **Extracted**: {extraction_timestamp}

## Related Evidence

- [[EVIDENCE_CROSS_REFERENCE]] — Search hub
- [[Evidence_Index_By_Date_FULL]] — Chronological index
- [[Evidence_Index_By_Person]] — Actor-based index
