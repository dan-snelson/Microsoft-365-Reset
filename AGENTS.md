# AGENTS.md

**Single source of truth for coding agents** (Claude Code, Cursor, Copilot, Aider, etc.).
Takes precedence over `README.md`, `CLAUDE.md`, and similar instruction files.
Claude Code users: symlink with `ln -s AGENTS.md CLAUDE.md` or reference via `@AGENTS.md` from a minimal `CLAUDE.md`.

## Caveman Mode

Respond terse like smart caveman. All technical substance stay. Only fluff die. Active every response unless user says `stop caveman` or `normal mode`.

- Drop articles, filler, pleasantries, hedging.
- Fragments OK. Short synonyms preferred. Technical terms and code exact.
- Pattern: `[thing] [action] [reason]. [next step].`
- Switch levels with `/caveman lite | full | ultra | wenyan`.
- Drop caveman style for security warnings, irreversible actions, or user confusion; resume after clear part done.
- Code, commits, PRs, explanations stay normal when clarity matters.

Guidance for coding agents working in this repository.

## Orchestration Contract

This file codifies project rules, boundaries, workflows, and repeatable skills. If same correction repeats, formalize it here instead of re-prompting it.

- Keep durable repository guidance near the top of this file.
- Keep fast-changing release or status details lower in this file or in canonical docs such as `README.md` and `CHANGELOG.md`.
- Avoid timestamps, counters, or ephemeral task notes in the stable instruction prefix.

## Project Overview

Microsoft 365 Reset provides a safe, clear, swiftDialog-driven workflow to repair, reset, or remove Microsoft 365 components on macOS while preserving parity with the original package workflows where intended. Primary artifact: `Microsoft-365-Reset.zsh`. Supported modes: `self-service`, `silent`, `test`, and `debug`.

## Key Commands

- Validate syntax after **every** script edit: `zsh -n Microsoft-365-Reset.zsh`
- After modifying MOFA helper logic: `zsh -n scripts/mofa-consult.zsh`
- View canonical version marker: `cat VERSION.txt`
- When changing `scripts/mofa-consult.zsh`, validate behavior both with and without `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` present locally
- When changing workflow behavior, validate `self-service` and `silent` assumptions before widening scope

## Agent Workflow

- Start non-trivial changes in Plan mode or equivalent.
- In Plan mode, make no changes and propose no code until confidence is high; ask follow-up questions until behavior, parity impact, and scope are clear.
- Default user-facing communication mode: `$caveman full`, except for security warnings, irreversible actions, or clear user confusion.
- Treat context like a scalpel, not a net; provide only files, lines, and examples needed.
- Use surgical edits; reference exact functions, ranges, or list-item IDs instead of pasting large sections.
- After any edit to `Microsoft-365-Reset.zsh` or `scripts/mofa-consult.zsh`, run `zsh -n` immediately, then validate the affected workflow assumptions.
- Confirm this file is loaded before starting a session.
- Prefer batching related work into one well-scoped prompt.
- Never let UI-only behavior leak into `silent` or break deterministic operation ordering.
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

- Read any repository file, including optional package-era reference artifacts.
- Run `zsh -n`, syntax checks, and Markdown consistency reviews.
- Make small targeted edits that follow the rules below.
- Update log copy, dialog copy, or maintainer wording when semantics do not change.

**Ask before doing**

- Modify operation ordering, dependency relationships, or chooser logic.
- Change reset, repair, or removal semantics.
- Change default behavior, exit-code semantics, logging contracts, or CLI parameters.
- Modify release artifacts under `Resources/`.
- Change the hard-coded client log path.
- Add production dependencies or external tooling.
- Update `VERSION.txt` or prepare a release.

**Never do**

- Hardcode secrets, API keys, organization-specific data, or credentials.
- Modify files outside current task scope without approval.
- Change MOFA or package-era parity behavior without documenting the reason and parity impact.
- Break deterministic execution ordering or let UI-only behavior leak into `silent`.
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

- Microsoft 365 reset, repair, and removal workflows on macOS
- swiftDialog-driven user flow in `self-service`, `test`, and `debug`
- silent automation flow in `silent`
- deterministic operation ordering and dependency resolution
- structured logging and predictable exit codes

Out of scope:

- non-macOS support
- broad architectural rewrites unless explicitly requested
- adding production dependencies without explicit user approval
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
- Keep any divergence from MOFA only when there is a defensible product, safety, platform, or workflow reason.
- When diverging from MOFA, document the reason in `README.md` and call out the parity impact in change notes or review summaries.

## Key Files

- `Microsoft-365-Reset.zsh`: main script and runtime behavior source
- `scripts/mofa-consult.zsh`: maintainer helper for MOFA sync and inclusion reporting
- `Resources/createSelfExtracting.zsh`: maintainer helper for generating self-extracting wrappers of the main script
- `README.md` and `CHANGELOG.md`: usage, behavior, and release history
- `VERSION.txt`: canonical release marker
- `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/`: optional local package-era scripts and `Distribution` reference used for secondary maintainer comparisons
- `.gitignore`: ignore rules for expanded package artifacts and generated wrappers

## Current Runtime Hotspots

- MOFA remains the primary parity baseline; if the package-era reference points at different chooser or dependency behavior, document any retained divergence instead of silently inheriting legacy behavior.
- `scripts/mofa-consult.zsh` must produce a clean maintainer report whether `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` is present or absent locally.
- Changes that touch reset, repair, or removal operations must keep `self-service` and `silent` aligned on ordering, dependency handling, and exit behavior.
- Generated `Resources/*_self-extracting-*.sh` files are build artifacts; avoid churn unless packaging refresh is explicitly requested.

## Repository Rules

- Prefer minimal targeted edits over broad rewrites.
- Avoid hidden behavior changes during refactors.
- If changing operation behavior, call out parity impact explicitly.
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
10. Do not add or remove CLI parameters unless explicitly requested.
11. Keep the client-side log path hard-coded unless explicitly requested: `scriptLog="/var/log/org.churchofjesuschrist.log"`.

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
2. Ensure the top `CHANGELOG.md` entry matches shipped behavior and correct date.
3. Confirm `README.md` reflects current reset, repair, and removal workflows and parameters.
4. Verify MOFA and package-era divergence notes still match actual behavior.
5. Run syntax validation on every modified Zsh file.
6. Validate `self-service` and `silent` assumptions end-to-end.
7. Leave generated self-extracting wrappers untracked unless packaging refresh is explicitly requested.

## Maintenance

This file is versioned with the project. When core style rules, validation requirements, or boundaries change, update `AGENTS.md` and note the change in `CHANGELOG.md` under `Internal` when appropriate. Keep this file concise enough that agents can consume it reliably in one pass.
