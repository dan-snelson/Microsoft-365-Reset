---
name: Bug Report
about: Submit a bug report for Microsoft 365 Reset
title: 'Bug Report: [short description]'
labels: bug
assignees: dan-snelson
---

> Before submitting a bug report, please confirm the issue still occurs with a fresh copy of the [latest release](https://github.com/dan-snelson/Microsoft-365-Reset/releases) or the current [`main` branch](https://github.com/dan-snelson/Microsoft-365-Reset/archive/main.zip).
>
> If you can reproduce the behavior on demand, please include the details below so the failure can be traced against the script's mode, operation ordering, and log output.
>
> 1. Re-run the failing workflow from an elevated Terminal window and capture the exact command used.
> 2. If the problem is interactive, prefer reproducing with `--mode debug`; if it is automation-only, re-run the same `--mode silent --operations ...` invocation you used originally.
> 3. Attach a sanitized copy of the client-side log at `/var/log/org.churchofjesuschrist.log`.
> 4. If the failure involves app repair or reinstall, also attach relevant `/var/log/install.log` output.
> 5. If the issue is UI-related, include screenshots of the dialog shown before the failure.

**Describe the Bug**
A clear, concise description of the unexpected behavior.

**To Reproduce**
- How was the script launched? (Terminal, Jamf Pro policy, Self Service, other MDM, etc.)
- What exact command or parameter mapping was used?
- Which mode was used? (`self-service`, `test`, `debug`, or `silent`)
- Which operation IDs were selected or passed in `--operations`?

**Expected Behavior**
A clear, concise description of what you expected to happen.

**Logs / Output**
Attach sanitized logs as a compressed archive when possible.

- Client-side script log: `/var/log/org.churchofjesuschrist.log`
- Installer log excerpts if repair/reinstall was involved: `/var/log/install.log`
- Terminal debug output if available

If pasting output inline, please use fenced code blocks.

**Screenshots**
If applicable, add screenshots to help explain the problem.

**Environment**
- macOS version
- Microsoft 365 Reset version
- swiftDialog version
- Deployment method (local Terminal, Jamf Pro, other MDM)
- Affected Microsoft apps or operations

**Additional Context**
Include anything else that may matter, such as whether the issue only occurs with destructive operations, only in `silent` mode, or only when app repair/download is triggered.
