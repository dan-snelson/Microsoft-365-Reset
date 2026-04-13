# Security Policy

Thank you for helping keep **Microsoft-365-Reset** secure!  

This tool runs with **`root` privileges** and can perform destructive operations (including permanent data removal), so we take security seriously.

## Supported Versions

Only the **latest release** is actively supported for security updates.

- Current stable/beta: [v1.0.0](https://github.com/dan-snelson/Microsoft-365-Reset/releases) (and newer)
- Older releases receive no security patches.

We strongly recommend always using the latest version, especially in Jamf Pro Self Service or MDM deployments.

## Reporting a Vulnerability

If you discover a **security vulnerability** in this project, please report it **responsibly** and privately.

**Do NOT** open a public GitHub issue or Pull Request that discloses the vulnerability.

### How to Report
Send an email to:  
**security@snelson.us**

Please include as much of the following as possible:

- Description of the vulnerability and its potential impact
- Steps to reproduce the issue (include exact commands or Jamf parameters used)
- Affected version(s) of Microsoft-365-Reset
- Any suggested mitigation or fix (if you have one)
- Your name/handle (optional — we’ll credit you unless you prefer anonymity)

You should receive an acknowledgment within **48 hours** (usually much faster).  
We will work with you to understand, reproduce, and fix the issue, then coordinate public disclosure once a fix is ready.

## Security Best Practices When Using This Tool

- Always test in a lab/VM before broad deployment (especially `remove_office`, `remove_outlook_data`, and `remove_onenote_data` operations).
- In interactive modes, the script requires explicit confirmation for destructive actions.
- In silent/Jamf mode, double-check your `--operations` or parameter `$5` list — there is no UI confirmation.
- The script performs **signature verification** (`codesign`) and content-length checks on Microsoft packages during auto-repair.
- Run only from trusted sources (official GitHub releases or your own signed packages).
- Consider wrapping the script in a Jamf Pro policy with scoped Smart Groups and clear end-user communication.

## Code Security Practices

- This repository is scanned with **Semgrep** using the `p/r2c-security-audit`, `p/ci`, and `p/secrets` rulesets.
- Tracked `*.zsh` files are syntax-checked with `zsh -n`.
- Tracked `*.sh` and `*.bash` files are linted with **ShellCheck** when present in the repository.
- We avoid dangerous patterns common in shell scripts (e.g., unsafe `eval`, unquoted variables where possible, etc.).
- All external downloads (swiftDialog, Microsoft packages) are verified where feasible.
- Contributions are reviewed for security impact before merging.

## Disclosure Policy

- We follow **coordinated disclosure**: the reporter and maintainers agree on a reasonable timeline before public disclosure.
- Security fixes will be released as quickly as possible, usually with a new tagged release and clear changelog entry.
- We will credit the reporter (unless anonymity is requested) in the release notes and SECURITY.md.

## Questions or General Security Concerns?

For non-vulnerability questions (e.g., “Is it safe to run in my environment?”), please open a regular GitHub Discussion or Issue.

---

**We. All. Miss. Paul.** — and we want every Mac Admin to be able to reset M365 with confidence and peace of mind.

Grateful for the Mac Admins community that keeps us all safer.  

— Dan K. Snelson  

Last updated: April 2026
