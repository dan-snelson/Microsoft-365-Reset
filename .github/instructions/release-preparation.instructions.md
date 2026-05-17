---
name: Release Preparation
description: Release-scope rules for version alignment, changelog discipline, syntax validation, and safe validation of Microsoft-365-Reset before shipping.
applyTo: "**/*.{zsh,md,txt}"
---

# Release Preparation

**Priority Order**: 1. Release Scope Discipline → 2. Version Alignment → 3. Syntax Validation → 4. Self-Service and Silent Validation

## 1. Release Scope Discipline (Non-Negotiable)

- Update **only** files explicitly included in the release scope.
- Treat `Microsoft-365-Reset.zsh` as the primary runtime artifact.
- Leave generated `Resources/*_self-extracting-*.sh` wrappers unchanged unless a packaging refresh is explicitly requested.
- Do not modify `Resources/` release artifacts, workflow semantics, or CLI defaults during release prep unless the release scope explicitly requires it.
- If a file outside the allowed extensions (`.zsh`, `.md`, `.txt`) is encountered in the release scope, exclude it from the release and log a warning.

## 2. Version Alignment

- Keep `scriptVersion` in `Microsoft-365-Reset.zsh`, `VERSION.txt`, and the top entry in `CHANGELOG.md` aligned when preparing a release.
- If version markers drift, stop release preparation immediately and correct the mismatch before continuing.
- Update `CHANGELOG.md` only for shipped behavior. Do not document speculative or deferred work.

## 3. Syntax Validation (Required After Zsh Edits)

- After editing `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- After editing `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- Run `zsh -n` against **every** modified `.zsh` file that is in release scope.
- Treat syntax validation as mandatory even for small behavioral changes.
- If `zsh -n` fails for a file that is **not explicitly listed** above, investigate the error. Determine whether the file should be excluded from scope or corrected before proceeding.

## 4. Self-Service and Silent Validation

- Validate both `self-service` and `silent` expectations before release.
- Confirm that `silent` mode remains independent of dialog UI and that no UI-only behavior has leaked into automation paths.
- Ensure `self-service` and `silent` have identical behavior for:
  - Deterministic operation ordering
  - Dependency handling
  - Exit behavior
- If release changes touch parity-sensitive behavior, verify that MOFA remains the primary baseline and document any intentional divergence.

## 5. Failure Handling

- A version mismatch **blocks** release preparation.
- A failed `zsh -n` syntax check **blocks** release preparation.
- Any validation result that breaks `self-service` or `silent` alignment **blocks** release preparation.
- If release prep uncovers unintended wrapper churn, revert that churn from scope unless a packaging refresh was explicitly requested.

## 6. Post-Edit Checklist

- [ ] Release scope stayed limited to the requested files only.
- [ ] `scriptVersion`, `VERSION.txt`, and `CHANGELOG.md` are aligned (when version changes were in scope).
- [ ] `zsh -n Microsoft-365-Reset.zsh` ran after main script edits.
- [ ] `zsh -n scripts/mofa-consult.zsh` ran after MOFA helper edits.
- [ ] `self-service` and `silent` expectations were reviewed together.
- [ ] Generated self-extracting wrappers were left unchanged unless explicitly requested.
- [ ] Files outside allowed extensions were excluded with a warning logged.

**Reference**: For all release scope decisions, resolve ambiguity by consulting `AGENTS.md`. If `AGENTS.md` is silent on the matter, defer to the current repo behavior in `Microsoft-365-Reset.zsh`.