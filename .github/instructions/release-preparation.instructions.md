---
name: Release Preparation
description: Release-scope rules for version alignment, changelog discipline, syntax validation, and safe validation of Microsoft-365-Reset before shipping.
applyTo: "**/*.{zsh,md,txt}"
---

# Release Preparation

**Priority Order**: 1. Release Scope Discipline -> 2. Version Alignment -> 3. Syntax Validation -> 4. Self-Service and Silent Validation

## 1. Release Scope Discipline (Non-Negotiable)

- Update only files explicitly in release scope.
- Treat `Microsoft-365-Reset.zsh` as the primary runtime artifact.
- Leave generated `Resources/*_self-extracting-*.sh` wrappers unchanged unless packaging refresh is explicitly requested.
- Do not modify `Resources/` release artifacts, workflow semantics, or CLI defaults during release prep unless the release scope explicitly requires it.

## 2. Version Alignment

- Keep `scriptVersion` in `Microsoft-365-Reset.zsh`, `VERSION.txt`, and the top `CHANGELOG.md` entry aligned when preparing a release.
- If version markers drift, stop release preparation and fix the mismatch before widening scope.
- Update `CHANGELOG.md` only for shipped behavior, not speculative or deferred work.

## 3. Syntax Validation (Required After Zsh Edits)

- After edits to `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- After edits to `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- Run `zsh -n` against every modified Zsh file in release scope before considering the work complete.
- Treat syntax validation as required even when the behavioral change is small.

## 4. Self-Service and Silent Validation

- Validate both `self-service` and `silent` expectations before release.
- Keep `silent` independent of dialog UI and confirm no UI-only behavior leaked into automation paths.
- Keep `self-service` and `silent` aligned on deterministic operation ordering, dependency handling, and exit behavior.
- If release changes touch parity-sensitive behavior, verify that MOFA remains the primary baseline and document any intentional divergence.

## 5. Failure Handling

- A version mismatch blocks release preparation.
- A failed syntax check blocks release preparation.
- A validation result that breaks `self-service` or `silent` alignment blocks release preparation.
- If release prep uncovers unintended wrapper churn, revert that churn from scope unless packaging refresh was requested.

## 6. Post-Edit Checklist

- [ ] Release scope stayed limited to requested files.
- [ ] `scriptVersion`, `VERSION.txt`, and `CHANGELOG.md` are aligned when release scope required version changes.
- [ ] `zsh -n Microsoft-365-Reset.zsh` ran after main-script edits.
- [ ] `zsh -n scripts/mofa-consult.zsh` ran after MOFA-helper edits.
- [ ] `self-service` and `silent` expectations were reviewed together.
- [ ] Generated self-extracting wrappers were left unchanged unless explicitly requested.

**Reference**: Resolve ambiguity in favor of `AGENTS.md`, then current repo behavior in `Microsoft-365-Reset.zsh`.