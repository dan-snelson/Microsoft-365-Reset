---
name: Maintainer Parity
description: Rules for MOFA comparison, package-era parity reporting, and optional-reference handling in scripts/mofa-consult.zsh.
applyTo: "scripts/mofa-consult.zsh"
---

# Maintainer Parity

**Core Principle**: Maintain explicit, MOFA-first parity reporting while degrading cleanly when the optional package-era reference is absent.

## 1. Source Priority

- Start with `scripts/mofa-consult.zsh` and current MOFA behavior.
- Treat MOFA as the primary parity baseline.
- Use `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` only as an optional secondary comparison source.
- Do not let package-era behavior silently override current MOFA behavior.

## 2. Optional Reference Handling

- Preserve warning-and-skip behavior when `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` is missing locally.
- Missing optional reference data should not abort maintainer reporting.
- Keep the report clean and explicit about what could and could not be compared.
- When the optional reference is present, compare it without changing runtime workflow semantics.

## 3. Report Wording Rules

- State MOFA coverage explicitly.
- State retained package-era logic explicitly when it still informs the repo.
- Call out parity gaps or deliberate divergence in direct language.
- Prefer wording that distinguishes current behavior, retained legacy behavior, and unavailable comparison data.

## 4. Validation Requirements

- After edits to `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- If parity work also edits `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- Validate maintainer reporting with the optional package-era reference present.
- Validate maintainer reporting with the optional package-era reference absent.

## 5. Boundaries

- Keep changes focused on maintainer reporting and comparison behavior.
- Prefer warning-and-skip behavior over aborting for optional-reference issues.
- Do not change runtime reset, repair, removal, chooser, or dependency behavior unless that broader workflow change is explicitly in scope.

## 6. Post-Edit Checklist

- [ ] MOFA stayed the primary parity baseline.
- [ ] Optional package-era reference remained optional.
- [ ] Warning-and-skip behavior remained intact when the reference was missing.
- [ ] Parity gaps and retained package-era logic are worded explicitly.
- [ ] `zsh -n scripts/mofa-consult.zsh` ran after helper edits.
- [ ] Reporting expectations were checked with and without the optional reference.

**Reference**: Follow `AGENTS.md` first, then `scripts/mofa-consult.zsh`, then optional package-era materials for secondary comparison.