# Microsoft 365 Reset

## Changelog

### Version 1.2.0b2 (16-May-2026)
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
