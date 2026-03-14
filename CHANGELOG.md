# Microsoft 365 Reset

## Changelog

### Version 0.0.1a3 (14-Mar-2026)
- Fixed argument parsing so Jamf-style leading positional parameters no longer trigger `Unknown argument` before CLI flags are processed (Addresses [Issue #3](https://github.com/dan-snelson/Microsoft-365-Reset/issues/3); thanks for the heads-up, @eirikt!)

### Version 0.0.1a2 (13-Mar-2026)
- Aligned cleanup targets with MOFA community-maintained reset scripts
- Added OneDrive integration cleanup targets to the full Microsoft 365 removal workflow
- Added MAU `HTTPStorages` binarycookie cleanup targets during AutoUpdate reset
- Added MOFA-style factory reset cleanup behavior to `reset_factory`
- Updated app reset flows to stop after repair/reinstall instead of continuing with configuration cleanup
- Added `reset_license` to preserve MOFA's license-only reset workflow alongside `reset_credentials`
- Added `reset_teams_force` to provide a Teams force-reinstall path within the unified operation model
- Updated Teams reset to preserve custom backgrounds, reset Teams TCC state in the logged-in user context, preserve installed app bundles outside force-reinstall mode, and reopen Screen Recording settings in interactive modes
- Expanded AutoUpdate registration to include current Teams, Edge channels, and Defender ATP when present
- Fixed Microsoft package header parsing so `reset_teams_force` can validate CDN downloads correctly
- Updated progress bar behavior so a running operation no longer appears complete before it finishes
- Updated new Teams AutoUpdate registration to use the current `TEAMS21` product ID and expanded Teams process shutdown coverage

### Version 0.0.1a1 (12-Mar-2026)
- Initial unified script implementation
- Added CLI validation for missing `--mode` and `--operations` values
- Added preflight guard to require a non-root console user and block unsafe `/var/root` user-scope targeting
- Updated keychain credential removal helpers and operation flows to execute user-keychain deletes in logged-in user context
- Made package downloads deterministic by removing background transfer mode from repair downloads
- Updated README exit code documentation for `silent` mode with no selected operations
