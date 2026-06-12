# FreshBooks BP Display (M3 + M4)

Verify-page mapping helpers for BranchlessPay `VerifyPage.tsx`.

| Path | Purpose |
|------|---------|
| `src/freshbooksVerifyMapping.ts` | Field labels, currency/status formatters, PDF + instructions |
| `src/VerifyPageIntegration.example.tsx` | React wiring example until BP provides `VerifyPage.tsx` |
| `tests/freshbooksVerifyMapping.test.mjs` | Automated mapping tests |

## Run tests

```powershell
cd display
npm test
```

Requires Node.js 20+ (uses `node --test` with TypeScript import).

## Docs

- [../docs/M3_FIELD_MAPPING.md](../docs/M3_FIELD_MAPPING.md)
- [../docs/M4_EVIDENCE_GUIDE.md](../docs/M4_EVIDENCE_GUIDE.md)
- [../MILESTONE_M3_M4.md](../MILESTONE_M3_M4.md)

## Blocker

Production **`VerifyPage.tsx`** must be supplied by BranchlessPay. Drop the mapping calls from `VerifyPageIntegration.example.tsx` into that file when it arrives.

Contact: suhono@branchlesspay.com
