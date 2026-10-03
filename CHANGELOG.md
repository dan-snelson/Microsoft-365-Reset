# Microsoft 365 Reset

## Changelog

### Version 2.0.1 (03-Oct-2026)
- Addressed findings from a third Monocle security review
    - :warning: **Breaking Change:** :warning: An operation now fails (exit `20`) when any path it should remove is not removed (for example, a root-owned folder left in the console user's home folder, or a removal blocked by macOS privacy protections); previously these logged a `WARNING` and the operation reported success. Per-user temp-folder cleanup and private staging cleanup stay best-effort. Grant your management agent Full Disk Access via a PPPC profile
    - `reset_teams` / `reset_teams_force`: Teams background archive, staging, and restore now run as the console user and no longer change file ownership; current Teams backgrounds are staged in a `M365R_Teams_Backgrounds.*` folder in the user's home folder (instead of `/private/tmp`), so backgrounds kept after a failed restore survive a restart and are opened for the user in interactive modes
    - Reset operations (`reset_factory`, `reset_word`, `reset_excel`, `reset_powerpoint`, `reset_outlook`, `reset_onenote`, `reset_onedrive`, `reset_teams`, `reset_teams_force`) no longer delete profile-delivered `/Library/Managed Preferences` files; only `remove_office` removes them
    - Microsoft package verification now requires `pkgutil --check-signature` to succeed and report an Apple-issued distribution certificate before comparing the Microsoft signer
    - Custom MAU channels now also require an `https://` `FullUpdaterLocation`; non-HTTPS values are ignored with a `WARNING` and the standard Microsoft download is used
    - The Microsoft identity keychain-database cleanup (`reset_onedrive`, `reset_credentials`) and the `com.microsoft.Office365V2.plist` rename (`reset_license`, `reset_credentials`) now run as the console user
    - Auto-repair now moves a damaged or version-mismatched app aside (instead of deleting it) after the replacement package verifies, and restores it when the install fails, leaves nothing in place, or (Teams, OneDrive, and MAU) leaves a new bundle that fails codesign; previously a Teams bundle that failed codesign after install was retried after the original had already been discarded
    - swiftDialog preflight now re-reads the installed version after an upgrade and exits `10` if it is still unreadable or below the required minimum
- Reliability fixes
    - Per-app caches in the console user's temp folder are now cleaned as the console user; earlier releases targeted root's temp folder, so these removals did nothing
    - Force-quit now uses exact process names or anchored prefixes (for example, `^Microsoft Teams` and `^OneDrive`), so other vendors' Finder extensions and the Teams audio driver host are no longer matched by substring; OneDrive's Finder extension is matched by its bundle path, and `OneDrive Sync Service` is now included
    - Microsoft, Zoom, and WebEx launchd jobs are stopped with `launchctl bootout` by label in the console user's GUI domain or the system domain (previously `launchctl stop` with a plist path, which did nothing); `reset_autoupdate` reloads the MAU agent and daemon afterward, including when auto-repair fails, and fails (exit `20`) when a job cannot be reloaded
    - `reset_license` / `reset_credentials` restart `cfprefsd` only for the console user and root, not for other logged-in users
    - Home-folder lookup now prefers directory services over a `/Users/<shortname>` guess when `dscl` cannot return the path
    - The completion dialog now shows a warning icon (instead of the green checkmark) when one or more operations failed
- Internal
    - Pinned the Semgrep CLI in `.github/workflows/security-scan.yml` to `1.179.0` (previously the latest release via `--upgrade`)
    - `scripts/mofa-consult.zsh` writes its report to the per-user `$TMPDIR` by default (instead of a fixed `/var/tmp` path), refuses a symlinked `--output` path (opened once with no-follow), no longer pushes your MOFA fork by default (pass `--push-origin`), and updates the `reset_factory` and `reset_teams` parity notes
    - `AGENTS.md` and `.github` instructions: never run `chown -R` as root on a tree the console user can write; console-user data may be staged in the home folder only as the console user; damaged apps are moved aside and restored on a failed install; exit `20` includes paths an operation could not remove

### Version 2.0.0 (30-Sep-2026)
- Addressed critical findings from a second Monocle security review
    - :warning: **Breaking Change:** :warning: `self-service` mode now exits `10` during preflight when no `--operations` / `$5` allowlist is supplied; pass `--allow-all-operations` or set Parameter `$6` to `true` for deliberately broad, admin-only policies (`test` and `debug` keep the logged `WARNING`)
    - `remove_office` no longer deletes `/Library/Application Support/Microsoft` or forgets the Defender (`com.microsoft.wdav`) package receipt, matching current MOFA Office Removal; Office-owned `MAU2.0`, `MERP2.0`, and `Office365` are still removed, and Defender and Edge data under `/Library/Application Support/Microsoft` are preserved (like MOFA, the shared `/Library/Logs/Microsoft` folder is still removed)
    - `remove_defender` now fails (exit `20`) when the Defender uninstaller exits non-zero or the app bundle remains
    - Auto-repair removes a damaged app (Word, Excel, PowerPoint, Outlook, OneNote, OneDrive, Teams, and MAU), a version-mismatched Office app, or an outdated Teams app only after the replacement package downloads and passes verification; outdated Office apps, OneDrive, and MAU are still updated in place
    - `reset_teams` / `reset_teams_force` retry a failed Teams package download up to five times (MOFA-aligned) instead of stopping after the first failure
    - Removals under the console user's home folder refuse any path whose parent directories resolve through a symlink, so a user-planted link cannot redirect a root deletion; Office template and add-in glob cleanup now routes through `safeRemove`, and Teams background archive, staging, and restore are skipped with a `WARNING` on the same condition
    - Removals under the console user's home folder now run as the console user (with no `root` fallback), so a symlink swapped in after the parent check cannot redirect the deletion outside what the user can already delete; root-owned folders left in the home folder are not removed and log a `WARNING`
    - The parent-directory symlink check now requires the resolved path to stay under the resolved home folder (case-sensitive), comparing only the portion below the home folder case-insensitively
    - `reset_teams` / `reset_teams_force` now fail (exit `20`) before removing Teams data when classic backgrounds cannot be archived or current backgrounds cannot be staged, instead of continuing and deleting them; backgrounds under a symlinked parent directory are skipped with a `WARNING` and cleanup continues
    - Teams background archive and restore moves no longer follow a destination symlink, and restore keeps backgrounds in staging with a `WARNING` when the destination already exists
    - Custom MAU channels now require an `https://` `ManifestServer`; non-HTTPS values are ignored with a `WARNING`
    - An unreadable app version no longer triggers the legacy Office 2016 installer or version-based reinstalls (Office apps, OneDrive, Teams, and MAU); the code-signature check decides
    - User-context commands (restart prompt, `open`, `tccutil`, keychain, `defaults`) run once in the console user's session instead of re-running under plain `sudo -u` after a non-zero exit
    - Keychain deletions no longer copy `security` output (including the deleted item's account and identity attributes) into the client log; each deletion logs a sanitized `INFO` line naming only the item label, service, or creator, and unexpected failures log a `WARNING`
    - `reset_excel` deletes the `Microsoft.Office.Excel.ProtectedDataServices` certificate in the console user's session instead of searching root's keychains
    - Every run that reaches preflight now ends with a `NOTICE` summary line in all modes (including `silent`, which has no completion dialog): succeeded and failed operation counts, failed operation IDs, elapsed time, and exit code (for example, `Exiting: 9 succeeded, 1 failed (reset_teams); Elapsed Time: 0h:1m:12s; exit code 20`)
    - Teams background restore creates container folders as the console user (MOFA-aligned) instead of leaving root-owned parents
    - swiftDialog trust check now verifies the code signature against a Team ID requirement, checks ownership of `Contents/` and `Contents/MacOS/`, and exits `10` if the version is still unreadable after reinstall
    - swiftDialog install stages `Dialog.pkg` in the root-private run directory, requires a passing Gatekeeper assessment, and verifies regular-file type and root ownership before `installer` runs
    - Preflight exits `10` when the console user's home resolves to `/`, `/var/root`, a relative path, or a missing folder; home paths containing spaces are no longer truncated
    - Microsoft package staging is removed on every failure path, so Teams download retries no longer retain failed downloads until exit
    - Treat `_mbsetupuser` (Setup Assistant) as no console user
    - Intro dialog now tells users to save their work before continuing
    - `README.md` now leads with a destructive-script caution, adds an impact column to the operations table, and clarifies that `test` is not a dry-run and `silent` skips confirmation
- Reviewed [MOFA](https://github.com/cocopuff2u/MOFA) repo
- Hardened root path trust based on a Monocle security review
    - Microsoft repair packages now download into a root-private per-run staging directory instead of `/Users/Shared/OnDemandInstaller`, and are checked for regular-file and root ownership before `installer` runs
    - swiftDialog command file stays root-owned and world-readable; it is no longer `chown`ed to the console user
    - swiftDialog must resolve inside `/Library/Application Support/Dialog/Dialog.app`, be root-owned and not group/other-writable, and be signed by Team ID `PWA5E9TQ59`; one reinstall is attempted before exiting `10`
    - Removed `/usr/local/bin` from `PATH`; all swiftDialog invocations use the validated absolute path
    - `reset_teams` / `reset_teams_force` stage Teams backgrounds in a private `mktemp -d` directory instead of a fixed `/tmp` path, and retain them with a warning if restore fails
- Added `remove_defender` to the interactive destructive-action confirmation, and log an `INFO` line when the user acknowledges it
- `debug` mode uses a timestamped `PS4` and suspends xtrace inside keychain-deletion, Microsoft package-install, and swiftDialog-install helpers
- Internal
    - `Resources/createSelfExtracting.zsh` now generates wrappers that pin `PATH`, extract into a private `mktemp -d` directory, run the extracted script with `/bin/zsh --no-rcs`, forward `"$@"`, preserve the exit code, and clean up, and restricts `--target` to inert filename characters (rejecting `.` and `..`)
    - Untracked the stale generated self-extracting wrapper and ignored `Resources/*_self-extracting-*.sh`
    - `AGENTS.md` and `.github` agent instructions now codify root path trust guardrails, the `self-service` allowlist gate, exit codes, and expanded release version markers
    - Removed the superseded standalone `Resources/Adobe Acrobat Add-in Removal for Microsoft 365 (1.0.2).zsh`; use the `remove_acrobat_addin` operation instead
    - `scripts/mofa-consult.zsh` removed `/usr/local/bin` from `PATH` and synced `remove_office` and `reset_teams` report notes with `2.0.0` behavior
    - Corrected `.github` release-preparation and maintainer-parity instructions to match `AGENTS.md` exit-code expectations and current `scripts/mofa-consult.zsh` behavior; `VERSION.txt` is documented as a local, gitignored marker
    - Refreshed pinned GitHub Actions SHAs in `.github/workflows/security-scan.yml`: `actions/checkout` `v7.0.1`, `github/codeql-action/upload-sarif` `v4.38.2`, and `gitleaks/gitleaks-action` `v3.0.0` (Node 24 runtime; Node 20 is removed from GitHub-hosted runners)

### Version 1.4.0 (02-Sep-2026)
- Reviewed [MOFA](https://github.com/cocopuff2u/MOFA) repo
- Added an admin-configurable silent-mode force-quit skip list `silentSkipForceQuitOps` (Feature Request #20)

### Version 1.3.0 (04-Aug-2026)
- Reviewed [MOFA](https://github.com/cocopuff2u/MOFA) repo
    - Reclassified deferred app cleanup after repair as MOFA-aligned behavior and narrowed the documented Teams divergences
    - Ensured `reset_teams_force` installs current Teams when no app bundle exists
    - Hardened MOFA reporting to validate complete operation wiring and expected runtime metadata before reporting coverage
- Aligned the selection dialog icon and overlay icon with the intro dialog
- Pinned seven GitHub Actions to immutable commit SHAs, clearing all Semgrep findings

### Version 1.2.0 (20-May-2026)
- Reviewed [MOFA](https://github.com/cocopuff2u/MOFA) repo
- Reclassified `reset_license` and `reset_credentials` as MOFA-aligned coverage in `scripts/mofa-consult.zsh` instead of intentional divergences
- Clarified `README.md` MOFA notes to separate aligned behavior, intentional divergences, and repo-local operations
- Fixed `--operations` / Jamf `$5` CSV parsing so comma-separated operation IDs execute as separate selections in `silent` mode (Addresses #16; thanks for the detailed report and recommended fix, @meschwartz!)
- Constrained interactive operation picker to CSV-listed operations when `--operations` / Jamf `$5` is provided in `self-service`, `test`, or `debug` mode (Addresses #15; thanks for the suggestion, @andreilabin!)

### Version 1.1.0 (01-May-2026)
- Reviewed [MOFA](https://github.com/cocopuff2u/MOFA) repo
- Clarified reset operation picker copy to reflect that Word, Excel, PowerPoint, Outlook, and OneNote defer app-specific cleanup when a repair occurs, and that `reset_factory` may require a later run for repaired app cleanup
- Documented `reset_teams_force` and `remove_acrobat_addin` as repo-local workflows without current MOFA community-script equivalents
- Synced internal auto-repair operation metadata so `reset_teams_force` stays aligned with documented repair behavior

### Version 1.0.0 (13-Apr-2026)
- Official `1.0.0` release
