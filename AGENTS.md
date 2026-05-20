# AGENTS.md

**Single source of truth for coding agents** (Claude Code, Cursor, Copilot, Aider, etc.).
Takes precedence over `README.md`, `CLAUDE.md`, and similar instruction files.
Claude Code users: symlink with `ln -s AGENTS.md CLAUDE.md` or reference via `@AGENTS.md` from a minimal `CLAUDE.md`.

## Caveman Mode

Respond terse like smart caveman. All technical substance stay. Only fluff die. Active every response unless user says `stop caveman` or `normal mode`.
- Code, commits, PRs, explanations stay normal when clarity matters.

Guidance for coding agents working in this repository.

## Orchestration Contract

This file codifies project rules, boundaries, workflows, and repeatable skills. If same correction repeats, formalize it here instead of re-prompting it.
- Avoid timestamps, counters, or ephemeral task notes in the stable instruction prefix.

## Project Overview

Microsoft 365 Reset provides a safe, clear, swiftDialog-driven workflow to repair, reset, or remove Microsoft 365 components on macOS while preserving parity with the original package workflows where intended. Primary artifact: `Microsoft-365-Reset.zsh`. Supported modes: `self-service`, `silent`, `test`, and `debug`.

## Key Commands
- When changing workflow behavior, validate `self-service` and `silent` assumptions before widening scope

## Agent Workflow
- Use codified Skills when they fit instead of re-describing the workflow.

## Skills

Invoke relevant skill name during planning.

### Operation / Workflow Change Skill

1. Plan from the nearest reset, removal, chooser, or dependency-ordering pattern.
2. Check current MOFA behavior first; use the package-era reference only when MOFA does not cover the behavior.
3. Implement only in the smallest owning surface.
4. Run required `zsh -n` checks immediately after the edit.
5. Validate `self-service` and `silent` assumptions before considering adjacent cleanup.
6. Update `README.md` and `CHANGELOG.md` when the behavior is user-visible.

### Maintainer Reporting / Parity Skill

1. Trace current behavior in `scripts/mofa-consult.zsh` and any related local reference artifacts.
2. Preserve warning-and-skip behavior when the expanded package-era reference is absent.
3. Keep report wording explicit about MOFA coverage, retained package-era logic, and any parity gaps.
4. Run `zsh -n scripts/mofa-consult.zsh`.
5. Update docs only if maintainer workflow or output expectations changed.

### Release Preparation Skill

1. Keep `scriptVersion`, `VERSION.txt`, and the top `CHANGELOG.md` entry aligned.
2. Update only files explicitly in release scope.
3. Run syntax checks on every modified Zsh file.
4. Validate both `self-service` and `silent` expectations before release.
5. Do not rebuild or commit generated self-extracting wrappers unless the task explicitly requires it.

## Boundaries

**Always allowed without asking**
- Update log copy, dialog copy, or maintainer wording when semantics do not change.

**Ask before doing**
- Update `VERSION.txt` or prepare a release.

**Never do**
- Commit generated `*_self-extracting-*.sh` wrappers unless explicitly asked.

## Source of Truth

When files disagree, prefer:

1. `Microsoft-365-Reset.zsh` for implemented behavior, exit codes, workflow ordering, and supported modes.
2. `scripts/mofa-consult.zsh` for MOFA sync, package-era comparison behavior, and optional-reference handling.
3. `README.md` and `CHANGELOG.md` for documented workflows, examples, and release notes.
4. `VERSION.txt` for canonical release marker.
5. `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` and its `Distribution` file for package-era reference behavior when available locally.

## Mission and Scope

Mission: provide a safe, clear Microsoft 365 repair, reset, and removal workflow on macOS with swiftDialog-driven guidance and deterministic automation.

In scope:
- structured logging and predictable exit codes

Out of scope:
- changing operation semantics without documenting and confirming intent

## Implementation Priorities

1. Treat current MOFA behavior as the primary parity baseline for reset and removal workflows.
2. Use the package-era reference to preserve retained chooser logic, dependency relationships, and legacy coverage where MOFA does not provide a current equivalent.
3. Preserve operator and end-user clarity in dialog text and warnings.
4. Keep changes minimal, targeted, and safe.
5. Maintain deterministic execution and reliable failure handling.
6. Keep docs synchronized with script behavior.

## Behavior Precedence

- Prefer MOFA behavior over package-era behavior by default.
- Use the package-era reference as secondary context unless MOFA does not cover the behavior in question.
- Treat package-era report coverage in `scripts/mofa-consult.zsh` as optional maintainer context when the local expanded package reference is unavailable.
- `Resources/createSelfExtracting.zsh`: maintainer helper for generating self-extracting wrappers of the main script
- `README.md` and `CHANGELOG.md`: usage, behavior, and release history
- `VERSION.txt`: canonical release marker

- MOFA remains the primary parity baseline; if the package-era reference points at different chooser or dependency behavior, document any retained divergence instead of silently inheriting legacy behavior.
- `scripts/mofa-consult.zsh` must produce a clean maintainer report whether `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` is present or absent locally.
- For maintainer-only reporting changes, prefer warning-and-skip behavior over aborting when optional local reference artifacts are missing.
- Keep naming, formatting, and copy consistent with existing script patterns.
- Check `git status` before editing shared docs or assets so unrelated local work is not overwritten.
- Treat generated `*_self-extracting-*.sh` wrappers as build artifacts and leave them untracked unless the user explicitly asks to commit one.
- Do not add new production dependencies without explicit approval.

## Scripting Style

These rules override ad-hoc prompting. Match established `Microsoft-365-Reset.zsh` style unless the user explicitly asks otherwise.

1. Preserve section headers and separator style (`####################################################################################################`).
2. Keep function declaration style and naming conventions consistent (`function xyz() { ... }`).
3. Use explicit quoting (`"${var}"`) and existing variable naming patterns.
4. Keep comments concise, practical, and in the existing voice.
5. Prefer ASCII punctuation in script text and logs unless there is a clear reason not to.
6. Route operational logs through `preFlight`, `notice`, `info`, `warning`, `errorOut`, and `fatal`.
7. Keep log format consistent: `<script name> (<version>): <timestamp>  [LEVEL] <message>`.
8. Keep elapsed-time format consistent: `Elapsed Time: %dh:%dm:%ds`.
9. Keep dialog conventions consistent: use global `fontSize` via `--messagefont "size=${fontSize}"`, keep warning emphasis readable and intentional, and keep selection UI behavior consistent with current picker flow.
## Mode Expectations

- `self-service` is the primary guided user flow.
- `silent` is the primary automation flow and must not depend on dialog UI.
- `test` and `debug` are maintainer-facing modes and must not redefine production semantics by accident.

## Quality Bar

- Keep deterministic execution ordering and dependency resolution intact.
- Keep logs structured, readable, and predictable.
- Preserve operator and end-user clarity in dialog copy and warnings.
- Let optional maintainer reference artifacts degrade with warning-and-skip behavior rather than unnecessary aborts.
- Avoid regressions in MOFA parity handling, package-era comparison coverage, and exit-code predictability.

## Required Validation

1. Run `zsh -n` against every modified Zsh file.
2. At minimum, run `zsh -n Microsoft-365-Reset.zsh` after modifying the main script and `zsh -n scripts/mofa-consult.zsh` after modifying the MOFA helper.
3. Verify behavior-sensitive changes against workflow assumptions in `self-service` and `silent`.
4. When changing `scripts/mofa-consult.zsh`, preserve clean report generation both when the package-era expanded reference is present and when it is absent.
5. Update `README.md` when behavior, parameters, or examples change.
6. Update `CHANGELOG.md` for meaningful user-visible behavior changes.
7. For docs-only changes, review rendered Markdown, terminology, and cross-file consistency.
8. Do not add new production dependencies without explicit user confirmation.

## Release Checklist

Apply only for release prep.

1. Keep `scriptVersion` and `VERSION.txt` aligned.
2. Validate `self-service` and `silent` assumptions end-to-end.
3. Leave generated self-extracting wrappers untracked unless packaging refresh is explicitly requested.


- A report with zero `Candidate inclusion` items usually means no workflow change is needed.
- Current intentional divergences must be verified against `Microsoft-365-Reset.zsh`, not accepted from report wording alone.

- Treat the maintainer report as a hypothesis generator. Confirm each candidate, divergence, and local-only item in the owning code path before recommending changes.
- Verify parity from implementation outward: `Microsoft-365-Reset.zsh` first, then `README.md`, then optional package-era context. This avoids docs-led false positives.

### Notable Code / Commands / Config

- `showCompletionDialog()`: confirms whether deferred-cleanup behavior is user-visible and already documented.

### Decisions & Rationale

- Do not recommend workflow edits when the report shows no candidate inclusions and current divergences are both implemented and documented.
- Prefer small documentation cleanup over runtime change when the only defect is duplicated wording or report-summary drift.
- Keep MOFA as the primary baseline and use package-era materials only to explain retained local behavior or missing MOFA coverage.

### Documentation / Next Steps

- Keep `README.md` MOFA-alignment, intentional-divergence, and repo-local sections aligned with the report classifications.
- Re-check local-only operations if MOFA later ships first-class equivalents for them.
- If AGENTS guidance changes the durable review workflow again, consider adding an `Internal` note to `CHANGELOG.md` when that change is broad enough to matter for maintainers.

## Maintenance

This file is versioned with the project. When core style rules, validation requirements, or boundaries change, update `AGENTS.md` and note the change in `CHANGELOG.md` under `Internal` when appropriate. Keep this file concise enough that agents can consume it reliably in one pass.
