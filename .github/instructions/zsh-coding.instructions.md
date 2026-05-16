---
name: Microsoft 365 Reset Zsh Conventions
description: Repo-specific Zsh editing rules for Microsoft-365-Reset. Enforces validation, deterministic execution, silent safety, logging discipline, and existing script style.
applyTo: "**/*.zsh"
---

# Microsoft 365 Reset Zsh Conventions

**Priority Order**: 1. Syntax Validation -> 2. Silent Safety -> 3. Deterministic Execution -> 4. Existing Style

## 1. Required Validation

- After edits to `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- After edits to `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- After any other Zsh edit, run `zsh -n` on the modified file before considering the change complete.
- Treat validation as mandatory even for small, local edits.

## 2. Mode Safety

- `self-service` is the primary guided flow.
- `silent` is the primary automation flow and must not depend on dialog UI.
- Keep `self-service` and `silent` aligned on operation ordering, dependency handling, and exit behavior.
- Never let UI-only behavior leak into `silent`.
- `test` and `debug` are maintainer-facing modes and must not accidentally redefine production semantics.

## 3. Logging and Operational Conventions

- Route operational logging through existing project logging functions such as `preFlight`, `notice`, `info`, `warning`, `errorOut`, and `fatal`.
- Keep log wording and severity consistent with current repo behavior.
- Preserve the hard-coded client log path `/var/log/org.churchofjesuschrist.log` unless explicitly requested otherwise.
- Keep deterministic execution ordering and reliable failure handling intact.

## 4. Script Style

- Preserve existing section-header and separator style.
- Keep function naming and declaration style consistent with the repo.
- Use explicit quoting such as `"${var}"` patterns already established in the repo.
- Keep comments concise and consistent with the current script voice.
- Prefer ASCII punctuation in script text and logs unless a clear reason requires otherwise.

## 5. Scope and Boundaries

- Prefer minimal, surgical edits over broad rewrites.
- Resolve ambiguity in favor of `AGENTS.md` and current repo behavior.
- Do not add production dependencies without explicit approval.
- Do not change operation semantics, defaults, CLI parameters, or release artifacts unless the task explicitly requires it.

## 6. Post-Edit Checklist

- [ ] Ran `zsh -n` against every modified Zsh file.
- [ ] Confirmed no UI-only behavior leaked into `silent`.
- [ ] Preserved deterministic execution ordering and dependency handling.
- [ ] Used existing project logging functions.
- [ ] Kept comments concise and style-consistent.
- [ ] Left `/var/log/org.churchofjesuschrist.log` unchanged unless explicitly requested.

**Reference**: `AGENTS.md` defines repo boundaries, validation, mode expectations, and scripting style; follow it when instructions conflict.