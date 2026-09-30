---
name: Microsoft 365 Reset Zsh Conventions
description: Repo-specific Zsh editing rules for Microsoft-365-Reset. Enforces validation, deterministic execution, silent safety, logging discipline, and existing script style.
applyTo: "**/*.zsh"
---

# Microsoft 365 Reset Zsh Conventions

**Priority Order**: 1. Syntax Validation → 2. Silent Safety → 3. Root Path Trust → 4. Deterministic Execution → 5. Existing Style

**Conflict Resolution Rule**: When priorities conflict, resolve in the order listed above. For example, if validation and style conflict, prioritize validation. If Silent Safety conflicts with Existing Style, prioritize Silent Safety.

## 1. Required Validation

- After edits to `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh`.
- After edits to `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- After any other Zsh edit, run `zsh -n` on the modified file before considering the change complete.
- Treat validation as mandatory even for small, local edits.
- If `zsh -n` fails, identify and fix all syntax errors before proceeding. Do not continue until validation passes.

## 2. Mode Safety

- `self-service` is the primary guided flow.
- `silent` is the primary automation flow and must not depend on dialog UI.
- Keep `self-service` and `silent` aligned on operation ordering and dependency handling; exit codes follow the intentional mode differences in `AGENTS.md` (`silent` exits `2` with no operations, `self-service` exits `10` with an empty allowlist unless opted in).
- Never let UI-only behavior leak into `silent`.
- `test` and `debug` are maintainer-facing modes and must not accidentally redefine production semantics.

## 3. Logging and Operational Conventions

- Route operational logging through existing project logging functions such as `preFlight`, `notice`, `info`, `warning`, `errorOut`, and `fatal`.
- Keep log wording and severity consistent with current repo behavior.
- Preserve the hard-coded client log path `/var/log/org.churchofjesuschrist.log` unless explicitly requested otherwise.
- Keep deterministic execution ordering and reliable failure handling intact.

## 4. Root Path Trust

- Keep `PATH` pinned to `/usr/bin:/bin:/usr/sbin:/sbin`; do not re-add `/usr/local/bin`.
- Invoke swiftDialog only through the validated `"${dialogBinary}"` path set by `dialogTrustCheck`, never bare `dialog`.
- Stage downloads and temporary files in root-private `mktemp -d` directories (for example under `"${workDirectory}"`), never in fixed `/tmp`, `/Users/Shared`, or other user-writable paths.
- Verify regular-file type and root ownership before passing staged packages to `installer`.
- Keep the swiftDialog command file root-owned; do not `chown` it to the console user.
- Run console-user commands through `runAsUser` (once, in the user's session); do not add retry fallbacks that re-run under plain `sudo -u`.
- Remove paths through `safeRemove` instead of bare `rm -rf`.
- Add `setopt localoptions noxtrace` to helpers that handle keychain items, package installs, or other sensitive data so `debug` traces stay safe.

## 5. Script Style

- Preserve existing section-header and separator style.
- Keep function naming and declaration style consistent with the repo.
- Use explicit quoting such as `"${var}"` patterns already established in the repo.
- Keep comments concise and consistent with the current script voice.
- Prefer ASCII punctuation in script text and logs unless a clear reason requires otherwise.

## 6. Scope and Boundaries

- Prefer minimal, surgical edits over broad rewrites.
- For **new files**: Ensure they follow the same conventions, validation steps, and style rules as existing files in the repo.
- For **deleted files**: Confirm that no dependencies are broken and that removal does not affect `self-service`, `silent`, or logging behavior.
- Resolve ambiguity in favor of `AGENTS.md` and the behavior defined in the latest committed version of the repository.
- Do not add production dependencies without explicit approval.
- Do not change operation semantics, defaults, CLI parameters, or release artifacts unless the task explicitly requires it.

## 7. Post-Edit Checklist

- [ ] Ran `zsh -n` against every modified Zsh file and fixed any failures before proceeding.
- [ ] Confirmed no UI-only behavior leaked into `silent`.
- [ ] Preserved deterministic execution ordering and dependency handling.
- [ ] Used existing project logging functions.
- [ ] Preserved root path trust: pinned `PATH`, validated `"${dialogBinary}"`, private `mktemp -d` staging, `runAsUser`, `safeRemove`, and `noxtrace` in sensitive helpers.
- [ ] Kept comments concise and style-consistent.
- [ ] Left `/var/log/org.churchofjesuschrist.log` unchanged unless explicitly requested.
- [ ] New files follow repo conventions; deleted files did not break dependencies.

**Reference**: `AGENTS.md` defines repo boundaries, validation, mode expectations, and scripting style; follow it when instructions conflict. Use the behavior defined in the latest committed version of the repository as the authoritative source for current repo behavior.