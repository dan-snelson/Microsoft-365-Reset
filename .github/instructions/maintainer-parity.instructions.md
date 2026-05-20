---
name: Maintainer Parity
description: Rules for MOFA comparison, package-era parity reporting, and optional-reference handling in scripts/mofa-consult.zsh.
applyTo: "scripts/mofa-consult.zsh"
---

# Maintainer Parity

**Core Principle**: Maintain explicit, MOFA-first parity reporting while degrading cleanly when the optional package-era reference is absent.

## Primary Constraints (Highest Priority)

- Start with `scripts/mofa-consult.zsh` and current MOFA behavior.
- Treat MOFA as the primary parity baseline at all times.
- Do not allow package-era behavior to override current MOFA behavior unless explicitly reported in the output.
- If both MOFA and the optional package-era reference are unavailable, output a clear error message and skip the comparison entirely.

## Secondary Considerations

- Use `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` only as an optional secondary comparison source.
- Preserve warning-and-skip behavior when the optional package-era reference is missing locally.
- Missing optional reference data must not abort maintainer reporting.
- When the optional reference is present, compare it without changing runtime workflow semantics.

## Report Wording Rules

- State MOFA coverage explicitly.
- State retained package-era logic explicitly when it still informs the repo.
- Call out parity gaps or deliberate divergence in direct language.
- Ensure the report is concise and explicitly states what could and could not be compared.
- Prefer wording that distinguishes current behavior, retained legacy behavior, and unavailable comparison data.

## Validation Requirements

- After edits to `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- If parity work also edits `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- Validate maintainer reporting with the optional package-era reference present.
- Validate maintainer reporting with the optional package-era reference absent.
- Before using the optional reference, validate that the data is present and not corrupted. If the optional reference data is invalid or corrupted, output a warning and skip the comparison for that reference.

## Boundaries

- Keep changes focused on maintainer reporting and comparison behavior.
- Prefer warning-and-skip behavior over aborting for optional-reference issues.
- Do not change runtime reset, repair, removal, chooser, or dependency behavior unless that broader workflow change is explicitly in scope.

## Post-Edit Checklist

- [ ] MOFA stayed the primary parity baseline.
- [ ] Package-era behavior did not override MOFA unless explicitly reported.
- [ ] Optional package-era reference remained optional.
- [ ] Warning-and-skip behavior remained intact when the reference was missing.
- [ ] Both-sources-unavailable scenario produces a clear error and skips comparison.
- [ ] Parity gaps and retained package-era logic are worded explicitly and concisely.
- [ ] `zsh -n scripts/mofa-consult.zsh` ran after helper edits.
- [ ] Reporting expectations were checked with and without the optional reference.
- [ ] Invalid or corrupted optional reference data triggers a warning and skips comparison.

**Reference**: Follow `AGENTS.md` first, then `scripts/mofa-consult.zsh`, then optional package-era materials for secondary comparison.