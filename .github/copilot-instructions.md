# Repository Guidance

## Caveman Mode

Respond terse like smart caveman. All technical substance stay. Only fluff die. Active every response unless user says `stop caveman` or `normal mode`.

- Drop articles, filler, pleasantries, hedging.
- Fragments OK. Short synonyms preferred. Technical terms and code exact.
- Pattern: `[thing] [action] [reason]. [next step].`
- Switch levels with `/caveman lite | full | ultra | wenyan`.
- Drop caveman style for security warnings, irreversible actions, or user confusion; resume after clear part done.
- Code, commits, PRs, explanations stay normal when clarity matters.

### Mission

Microsoft 365 Reset should provide safe, clear, swiftDialog-driven workflow to repair, reset, or remove Microsoft 365 components on macOS while preserving parity with original package workflows where intended.

### Product Boundaries

- In scope: Microsoft 365 reset, repair, removal workflows on macOS.
- In scope: swiftDialog-driven `self-service`, `test`, and `debug` flows.
- In scope: `silent` automation flow, deterministic operation ordering, dependency resolution, structured logging, predictable exit codes.
- Out of scope: non-macOS support.
- Out of scope: broad architectural rewrites unless user explicitly requests them.
- Out of scope: new production dependencies without explicit user approval.
- Out of scope: operation semantic changes unless documented and confirmed.

### Implementation Priorities

1. Treat current MOFA behavior as primary parity baseline for reset and removal workflows.
2. Use package-era reference to preserve chooser logic, dependency relationships, and legacy coverage where MOFA lacks current equivalent.
3. Preserve operator and end-user clarity in dialog text and warnings.
4. Keep changes minimal, targeted, safe.
5. Maintain deterministic execution and reliable failure handling.
6. Keep docs synchronized with script behavior.

### Behavior Precedence

- Prefer MOFA behavior over package-era behavior by default.
- Use `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` as secondary context unless MOFA does not cover behavior.
- Treat `scripts/mofa-consult.zsh` package-era report coverage as optional maintainer context when local expanded reference is unavailable.
- Keep divergence from MOFA only for defensible product, safety, platform, or workflow reason.
- When behavior diverges from MOFA, document reason in `README.md` and call out parity impact in change notes or review summary.

### Scripting Style

- Maintain established style of `Microsoft-365-Reset.zsh` unless user explicitly requests different style.
- Preserve section headers and separator style: `####################################################################################################`
- Keep function declaration style consistent: `function xyz() { ... }`
- Use explicit quoting like `${var}` pattern already present in script, preserving current variable naming style.
- Keep comments concise, practical, and in existing voice.
- Prefer ASCII punctuation in script text and logs unless clear reason exists.
- Route operational logs through helper wrappers: `preFlight`, `notice`, `info`, `warning`, `errorOut`, `fatal`.
- Keep log format consistent: `<script name> (<version>): <timestamp>  [LEVEL] <message>`
- Keep elapsed-time format consistent: `Elapsed Time: %dh:%dm:%ds`
- Keep dialog conventions consistent, including global `fontSize` with `--messagefont "size=${fontSize}"`.
- Do not add or remove CLI parameters unless explicitly requested.
- Keep client log path hard-coded as `scriptLog="/var/log/org.churchofjesuschrist.log"` unless explicitly requested otherwise.

### Validation And Docs

- Run `zsh -n` against every modified Zsh file.
- At minimum, run `zsh -n Microsoft-365-Reset.zsh` after modifying main script and `zsh -n scripts/mofa-consult.zsh` after modifying MOFA helper.
- Verify behavior-sensitive changes against `self-service` and `silent` flow assumptions.
- When changing `scripts/mofa-consult.zsh`, preserve clean report generation both with and without local expanded package reference.
- Update `README.md` when behavior, parameters, or examples change.
- Update `CHANGELOG.md` for meaningful user-visible behavior changes.
- Do not add new production dependencies without explicit user confirmation.

### Change Discipline

- Prefer minimal, targeted edits over broad rewrites.
- Avoid hidden behavior changes during refactors.
- Call out parity impact explicitly when operation behavior changes.
- For maintainer-only reporting changes, prefer warning-and-skip behavior over aborting when optional local reference artifacts are missing.
- Treat generated `*_self-extracting-*.sh` wrappers as build artifacts; leave untracked unless user explicitly asks to commit one.
- Keep naming, formatting, and copy consistent with existing script patterns.

