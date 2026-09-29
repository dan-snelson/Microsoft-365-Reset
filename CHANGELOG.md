# Microsoft 365 Reset

## Changelog

### Version 2.0.0b1 (29-Sep-2026)
- Hardened root path trust based on a Monocle security review
    - Microsoft repair packages now download into a root-private per-run staging directory instead of `/Users/Shared/OnDemandInstaller`, and are checked for regular-file and root ownership before `installer` runs
    - swiftDialog command file stays root-owned and world-readable; it is no longer `chown`ed to the console user
    - swiftDialog must resolve inside `/Library/Application Support/Dialog/Dialog.app`, be root-owned and not group/other-writable, and be signed by Team ID `PWA5E9TQ59`; one reinstall is attempted before exiting `10`
    - Removed `/usr/local/bin` from `PATH`; all swiftDialog invocations use the validated absolute path
    - `reset_teams` / `reset_teams_force` stage Teams backgrounds in a private `mktemp -d` directory instead of a fixed `/tmp` path, and retain them with a warning if restore fails
- Added `remove_defender` to the interactive destructive-action confirmation, and log an `INFO` line when the user acknowledges it
- Interactive modes now log a `WARNING` when no `--operations` / `$5` allowlist is supplied (behavior otherwise unchanged)
- `debug` mode uses a timestamped `PS4` and suspends xtrace inside keychain-deletion, Microsoft package-install, and swiftDialog-install helpers
- Internal
    - `Resources/createSelfExtracting.zsh` now generates wrappers that extract into a private `mktemp -d` directory, forward `"$@"`, preserve the exit code, and clean up
    - Untracked the stale generated self-extracting wrapper and ignored `Resources/*_self-extracting-*.sh`

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
