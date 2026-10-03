# Security Policy

Thank you for helping keep **Microsoft-365-Reset** secure!  

This tool runs with **`root` privileges** and can perform destructive operations (including permanent data removal), so we take security seriously.

## Supported Versions

Only the **latest release** is actively supported for security updates.

- Current stable: [v2.0.1](https://github.com/dan-snelson/Microsoft-365-Reset/releases) (and newer)
- Older releases, including `2.0.0`, `1.x`, and the `2.0.0` betas, receive no security patches; upgrade to the current release.

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

- Always test in a lab/VM before broad deployment (especially `remove_office`, `remove_outlook_data`, `remove_onenote_data`, and `remove_defender` operations).
- In interactive modes, the script requires explicit confirmation for destructive actions.
- In `self-service` mode, always supply an `--operations` / Parameter `$5` allowlist; an empty allowlist exits `10` during preflight unless `--allow-all-operations` / Parameter `$6` is `true` (reserve that for deliberately broad, admin-only policies).
- In `silent` mode, double-check your `--operations` or Parameter `$5` list — there is no UI confirmation.
- `test` mode is **not** a dry run; it performs real operations.
- Microsoft packages must pass `pkgutil --check-signature` (exit status, an Apple-issued distribution certificate, and the Microsoft signer) and content-length checks during auto-repair; a damaged or version-mismatched app is moved aside only after its replacement passes verification, and is restored if the install fails or (Teams, OneDrive, and MAU) the new bundle fails codesign.
- Root path trust guardrails:
    - `PATH` is pinned to `/usr/bin:/bin:/usr/sbin:/sbin`
    - swiftDialog must be root-owned, not group/other-writable, and signed by Team ID `PWA5E9TQ59`
    - Downloads and temporary files are staged in root-private `mktemp -d` directories and checked for regular-file type and root ownership before `installer` runs
    - The swiftDialog command file stays root-owned
    - Keychain deletions discard `security` output and log only the item label, service, or creator, so deleted account and identity attributes never reach the client log
    - Removals under the console user's home folder are refused when a parent directory resolves through a symlink, and run as the console user (never root), so a symlink swapped in after the check cannot redirect the deletion
    - Moves, renames, and keychain-database edits of the console user's own data (including Teams backgrounds) run as the console user; root never changes ownership of files under the home folder
    - Custom MAU manifest URLs (`ManifestServer` and `FullUpdaterLocation`) must use `https://`
- Run only from trusted sources (official GitHub releases or your own signed packages).
- Consider wrapping the script in a Jamf Pro policy with scoped Smart Groups and clear end-user communication.

## Code Security Practices

- This repository is scanned with **Semgrep** using the `p/r2c-security-audit`, `p/ci`, and `p/secrets` rulesets.
- Commits are scanned for secrets with **Gitleaks**.
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

Last updated: 03-Oct-2026
