---
name: Workflow Change
description: Rules for reset, repair, removal, chooser, and dependency-ordering changes in Microsoft-365-Reset. Prioritizes MOFA-first behavior, deterministic execution, and self-service or silent parity.
applyTo: "Microsoft-365-Reset.zsh"
---

# Workflow Change

**Priority Order**: 1. MOFA Baseline -> 2. Smallest Owning Surface -> 3. Silent Safety -> 4. Deterministic Ordering

## 1. Baseline and Scope

- Start from the nearest reset, repair, removal, chooser, or dependency-ordering pattern that already owns the behavior.
- Treat MOFA as the primary parity baseline.
- Use `Resources/Microsoft_Office_Reset_2.0.0b1_expanded/` only as an optional secondary reference when MOFA does not cover the behavior or retained package-era logic needs comparison.
- Make the change in the smallest owning surface instead of spreading logic across helpers, UI code, and callers.

## 2. Workflow Safety Rules

- Preserve deterministic execution ordering and dependency resolution.
- Keep `self-service` and `silent` aligned on operation ordering, dependency handling, and exit behavior.
- Never let UI-only behavior leak into `silent`.
- Avoid hidden behavior changes during refactors.

## 3. Implementation Rules

- Follow current repo behavior before reaching for package-era behavior.
- Prefer local, surgical edits over broad rewrites.
- Keep chooser logic explicit and preserve warning text when the workflow depends on destructive or user-visible actions.
- Use existing project logging functions for workflow decisions, warnings, and failures.
- Keep the hard-coded log path `/var/log/org.churchofjesuschrist.log` unchanged unless explicitly requested otherwise.

## 4. Required Validation After Edits

- After edits to `Microsoft-365-Reset.zsh`, run `zsh -n Microsoft-365-Reset.zsh` immediately.
- If the workflow change also touches `scripts/mofa-consult.zsh`, run `zsh -n scripts/mofa-consult.zsh`.
- Validate the changed workflow assumptions in both `self-service` and `silent` before expanding scope.
- If the change intentionally diverges from MOFA, document the reason and parity impact.

## 5. Documentation and Boundaries

- Update `README.md` and `CHANGELOG.md` only when the workflow change is user-visible and in scope.
- Ask before changing defaults, CLI parameters, operation ordering, or release artifacts.
- Do not touch generated self-extracting wrappers unless the task explicitly requests packaging refresh.

## 6. Post-Edit Checklist

- [ ] Change stayed in the smallest owning surface.
- [ ] MOFA remained the primary baseline, or any divergence was called out explicitly.
- [ ] Deterministic ordering and dependency resolution were preserved.
- [ ] No UI-only behavior leaked into `silent`.
- [ ] `zsh -n Microsoft-365-Reset.zsh` ran after main-script edits.
- [ ] `self-service` and `silent` assumptions were reviewed together.

**Reference**: `AGENTS.md` is the single source of truth; use package-era material only as secondary context.