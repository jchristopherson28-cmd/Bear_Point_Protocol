# Bear Point Protocol

> Replicable civil rights advocacy infrastructure.
> Built for tribal communities first, then all underserved populations.

## Structure

| Folder | Purpose |
|--------|---------|
| `00_PLATFORM\` | Shared infrastructure — scripts, legal reference, MMIW, Bearpoint docs |
| `_MASTER_TEMPLATE\` | Gold copy — deploy new cases from this. NEVER edit directly. |
| `01-99_CASE_{name}\` | Deployed case instances |
| `Deploy-Case.ps1` | One command to create a new case |

## Deploy a New Case

```powershell
.\Deploy-Case.ps1 -CaseName "Smith_v_District" -Complainant "Jane Smith" -Victim "A.S." -Defendant "Springfield School District"
```

## Platform Resources

| Resource | Path | Link |
|----------|------|------|
| QA Scripts | `00_PLATFORM\Scripts\01_QA\` | — |
| Legal Reference | `00_PLATFORM\Legal_Reference\` | — |
| MMIW Research | `00_PLATFORM\MMIW_Research\` | [[MMIW_RESEARCH_HUB]] |
| Bearpoint Foundation | `00_PLATFORM\Bearpoint\` | [[BEARPOINT_FOUNDATION]] |
| Toolchain | `00_PLATFORM\TOOLCHAIN.md` | [[TOOLCHAIN]] |
| Vault Rules | `_PROTOCOL.md` | [[_PROTOCOL]] |
