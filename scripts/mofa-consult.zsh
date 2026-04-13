#!/bin/zsh --no-rcs

####################################################################################################
#
# mofa-consult
#
# Maintainer helper to sync a sibling MOFA checkout and report possible inclusions for this repo.
#
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
setopt PIPE_FAIL

autoload -Uz is-at-least

scriptName="mofa-consult"
scriptVersion="1.0.0"
defaultMofaRepo="../MOFA"
defaultOutputPath="/var/tmp/M365R-MOFA-report.md"
upstreamURL="https://github.com/cocopuff2u/MOFA.git"

scriptDirectory="$(cd "$(dirname "$0")" && pwd)"
repoRoot="$(cd "${scriptDirectory}/.." && pwd)"
m365ScriptPath="${repoRoot}/Microsoft-365-Reset.zsh"
readmePath="${repoRoot}/README.md"
agentsPath="${repoRoot}/AGENTS.md"
distributionPath="${repoRoot}/Resources/Microsoft_Office_Reset_2.0.0b1_expanded/Distribution"

mofaRepoPath="${defaultMofaRepo}"
outputPath="${defaultOutputPath}"
runSync="true"
runReport="true"
pushOrigin="true"

typeset -a candidateItems
typeset -a intentionalItems
typeset -a localOnlyItems
typeset -a reportLines

function usage() {
    cat <<EOF
Usage: ./scripts/mofa-consult.zsh [options]

Options:
  --sync-only            Sync ../MOFA and skip report generation (pushes origin/main by default)
  --report-only          Generate the report from the local MOFA checkout without syncing
  --mofa-repo PATH       Override the default sibling MOFA checkout path (${defaultMofaRepo})
  --output PATH          Override the default report path (${defaultOutputPath})
  --no-push-origin       Skip the default origin/main push during sync
  --help                 Show this help text
EOF
}

function info() {
    print -r -- "[INFO] ${1}"
}

function warning() {
    print -r -- "[WARNING] ${1}" >&2
}

function error() {
    print -r -- "[ERROR] ${1}" >&2
}

function dieUsage() {
    error "${1}"
    usage >&2
    exit 1
}

function dieSync() {
    error "${1}"
    exit 2
}

function dieReport() {
    error "${1}"
    exit 3
}

function escapeForMarkdown() {
    local value="${1}"
    value="${value//|/\\|}"
    print -r -- "${value}"
}

function pathToFileURL() {
    local value="${1}"
    value="${value//\%/%25}"
    value="${value// /%20}"
    value="${value//\#/%23}"
    value="${value//\?/%3F}"
    value="${value//\[/%5B}"
    value="${value//\]/%5D}"
    print -r -- "file://${value}"
}

function appendReportLine() {
    reportLines+=("${1}")
}

function emitCodexPrompt() {
    local codexPrompt

    codexPrompt="Use \$workspace to review ${outputPath}, then inspect ${m365ScriptPath}, ${readmePath}, and ${agentsPath}. Evaluate the candidate inclusion items, intentional divergences, and local-only operations against the current Microsoft 365 Reset behavior and maintainer guidance, then recommend any safe follow-up changes for this repo."

    print -r -- "Codex Chat prompt: ${codexPrompt}"
    if command -v pbcopy >/dev/null 2>&1; then
        print -rn -- "${codexPrompt}" | pbcopy
        print -r -- "Codex Chat prompt copied to clipboard."
    fi
}

function addCandidateItem() {
    candidateItems+=("${1}")
}

function addIntentionalItem() {
    local item="${1}"
    local existingItem
    for existingItem in "${intentionalItems[@]}"; do
        [[ "${existingItem}" == "${item}" ]] && return 0
    done
    intentionalItems+=("${item}")
}

function addLocalOnlyItem() {
    localOnlyItems+=("${1}")
}

function resolveExistingPath() {
    local targetPath="${1}"
    (
        cd "${targetPath}" 2>/dev/null && pwd
    )
}

function extractFeedField() {
    local feedPath="${1}"
    local targetName="${2}"
    local targetKey="${3}"

    /usr/bin/awk -v target_name="${targetName}" -v target_key="${targetKey}" '
        /"packages"[[:space:]]*:[[:space:]]*\[/ {
            in_packages=1
            next
        }

        in_packages && /^[[:space:]]*{/ {
            in_object=1
            object=""
            next
        }

        in_packages && in_object {
            object = object $0 "\n"

            if ($0 ~ /^[[:space:]]*}[[:space:]]*,?[[:space:]]*$/) {
                if (index(object, "\"name\": \"" target_name "\"") > 0) {
                    pattern = "\"" target_key "\"[[:space:]]*:[[:space:]]*\"[^\"]*\""
                    if (match(object, pattern)) {
                        value = substr(object, RSTART, RLENGTH)
                        sub("^\"" target_key "\"[[:space:]]*:[[:space:]]*\"", "", value)
                        sub("\"$", "", value)
                        print value
                        exit
                    }
                }

                in_object=0
                object=""
            }
        }
    ' "${feedPath}"
}

function scriptContainsOperation() {
    local operationID="${1}"
    /usr/bin/grep -q "function op_${operationID}()" "${m365ScriptPath}"
}

function distributionContainsChoice() {
    local choiceID="${1}"
    /usr/bin/grep -Fq "${choiceID}" "${distributionPath}"
}

function appendPackageEraSection() {
    local distributionURL
    local operationID
    local localOpLabel
    local classification
    local note

    typeset -A packageChoiceIDForOperation
    typeset -A packageEraReason

    local packageEraOnlyOperations=(
        remove_onenote_data
        remove_defender
    )

    packageChoiceIDForOperation[remove_onenote_data]="com.microsoft.remove.OneNote.Data"
    packageChoiceIDForOperation[remove_defender]="com.microsoft.remove.Defender"

    packageEraReason[remove_onenote_data]="Package-era OneNote cached data removal workflow retained from the original Distribution."
    packageEraReason[remove_defender]="Package-era Defender removal workflow retained from the original Distribution."

    appendReportLine ""
    appendReportLine "## Package-Era Operations"
    appendReportLine ""

    if [[ ! -f "${distributionPath}" ]]; then
        warning "Package-era Distribution not found; skipping package-era coverage section: ${distributionPath}"
        appendReportLine "_Skipped: package-era Distribution reference not found at \`${distributionPath}\`._"
        return 0
    fi

    distributionURL="$(pathToFileURL "${distributionPath}")"
    appendReportLine "| Package Reference | Local Operation | Classification | Notes |"
    appendReportLine "| --- | --- | --- | --- |"

    for operationID in "${packageEraOnlyOperations[@]}"; do
        localOpLabel="${operationID}"
        classification="Covered"
        note="${packageEraReason[${operationID}]}"

        if ! distributionContainsChoice "${packageChoiceIDForOperation[${operationID}]}"; then
            classification="Candidate inclusion"
            note="Expected package-era Distribution choice ${packageChoiceIDForOperation[${operationID}]} is missing from the local reference."
            addCandidateItem "${operationID}: expected package-era Distribution choice ${packageChoiceIDForOperation[${operationID}]} is missing"
        elif ! scriptContainsOperation "${operationID}"; then
            classification="Candidate inclusion"
            note="Package-era Distribution includes this operation, but the local operation is missing from Microsoft-365-Reset.zsh."
            addCandidateItem "${operationID}: package-era Distribution includes this operation but the local operation is missing"
        else
            note="${note} Current local operation remains present."
        fi

        appendReportLine "| [Distribution](${distributionURL}) | \`${localOpLabel}\` | ${classification} | $(escapeForMarkdown "${note}") |"
    done
}

function ensureUpstreamRemote() {
    local currentURL
    currentURL="$(git -C "${mofaRepoPath}" remote get-url upstream 2>/dev/null)"

    if [[ -z "${currentURL}" ]]; then
        info "Adding MOFA upstream remote: ${upstreamURL}"
        git -C "${mofaRepoPath}" remote add upstream "${upstreamURL}" >/dev/null || return 1
        return 0
    fi

    if [[ "${currentURL}" != "${upstreamURL}" ]]; then
        info "Updating MOFA upstream remote URL"
        git -C "${mofaRepoPath}" remote set-url upstream "${upstreamURL}" >/dev/null || return 1
    fi

    return 0
}

function syncMofaRepo() {
    local currentBranch
    local currentHead
    local upstreamHead

    currentBranch="$(git -C "${mofaRepoPath}" branch --show-current 2>/dev/null)"
    [[ "${currentBranch}" == "main" ]] || dieSync "MOFA checkout must be on branch main; found '${currentBranch:-unknown}'"

    [[ -z "$(git -C "${mofaRepoPath}" status --porcelain 2>/dev/null)" ]] || dieSync "MOFA checkout must be clean before syncing"
    git -C "${mofaRepoPath}" remote get-url origin >/dev/null 2>&1 || dieSync "MOFA checkout is missing an origin remote"

    ensureUpstreamRemote || dieSync "Unable to ensure MOFA upstream remote configuration"

    info "Fetching MOFA remotes"
    git -C "${mofaRepoPath}" fetch --prune upstream || dieSync "Unable to fetch upstream MOFA changes"
    git -C "${mofaRepoPath}" fetch --prune origin || dieSync "Unable to fetch fork MOFA changes"

    git -C "${mofaRepoPath}" rev-parse --verify upstream/main >/dev/null 2>&1 || dieSync "upstream/main is not available after fetch"

    if ! git -C "${mofaRepoPath}" merge-base --is-ancestor HEAD upstream/main; then
        dieSync "Local MOFA main has commits that are not fast-forwardable to upstream/main"
    fi

    currentHead="$(git -C "${mofaRepoPath}" rev-parse HEAD 2>/dev/null)"
    upstreamHead="$(git -C "${mofaRepoPath}" rev-parse upstream/main 2>/dev/null)"

    if [[ "${currentHead}" != "${upstreamHead}" ]]; then
        info "Fast-forwarding local MOFA main to upstream/main"
        git -C "${mofaRepoPath}" merge --ff-only upstream/main || dieSync "Unable to fast-forward local MOFA main"
    else
        info "Local MOFA main already matches upstream/main"
    fi

    if [[ "${pushOrigin}" == "true" ]]; then
        info "Pushing synced MOFA main to origin/main"
        git -C "${mofaRepoPath}" push origin main:main || dieSync "Unable to push synced MOFA main to origin/main"
    else
        info "Skipping origin push by request"
    fi
}

function buildScriptCoverageSection() {
    local operationID
    local classification
    local note
    local mofaScriptRelativePath
    local mofaScriptPath
    local mofaScriptURL
    local localOpLabel

    typeset -A mofaScriptPathForOperation
    typeset -A intentionalNoteForOperation
    typeset -A localOnlyReason

    local mappedOperations=(
        reset_factory
        reset_word
        reset_excel
        reset_powerpoint
        reset_outlook
        remove_outlook_data
        reset_onenote
        reset_onedrive
        reset_teams
        reset_autoupdate
        reset_license
        reset_credentials
        remove_office
        remove_skypeforbusiness
        remove_zoomplugin
        remove_webexpt
    )

    local localOnlyOperations=(
        reset_teams_force
        remove_acrobat_addin
    )

    mofaScriptPathForOperation[reset_factory]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Office_Factory_Reset.zsh"
    mofaScriptPathForOperation[reset_word]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Word_Reset.zsh"
    mofaScriptPathForOperation[reset_excel]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Excel_Reset.zsh"
    mofaScriptPathForOperation[reset_powerpoint]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_PowerPoint_Reset.zsh"
    mofaScriptPathForOperation[reset_outlook]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Outlook_Reset.zsh"
    mofaScriptPathForOperation[remove_outlook_data]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Outlook_Data_Removal.zsh"
    mofaScriptPathForOperation[reset_onenote]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_OneNote_Reset.zsh"
    mofaScriptPathForOperation[reset_onedrive]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_OneDrive_Reset.zsh"
    mofaScriptPathForOperation[reset_teams]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Teams_Reset.zsh"
    mofaScriptPathForOperation[reset_autoupdate]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_AutoUpdate_Reset.zsh"
    mofaScriptPathForOperation[reset_license]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_License_Reset.zsh"
    mofaScriptPathForOperation[reset_credentials]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_OfficeLicenseSignIn_Reset.zsh"
    mofaScriptPathForOperation[remove_office]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_Office_Removal.zsh"
    mofaScriptPathForOperation[remove_skypeforbusiness]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_Microsoft_SkypeForBusiness_Removal.zsh"
    mofaScriptPathForOperation[remove_zoomplugin]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_ZoomPlugin_Removal.zsh"
    mofaScriptPathForOperation[remove_webexpt]="office_reset_tools/mofa_community_maintained/scripts/MOFA_Community_WebExPT_Removal.zsh"

    intentionalNoteForOperation[reset_factory]="README parity note: reset_factory performs its own MOFA-style suite cleanup in addition to dependency expansion."
    intentionalNoteForOperation[reset_word]="README parity note: Word, Excel, PowerPoint, Outlook, and OneNote stop after repair instead of continuing with configuration cleanup."
    intentionalNoteForOperation[reset_excel]="README parity note: Word, Excel, PowerPoint, Outlook, and OneNote stop after repair instead of continuing with configuration cleanup."
    intentionalNoteForOperation[reset_powerpoint]="README parity note: Word, Excel, PowerPoint, Outlook, and OneNote stop after repair instead of continuing with configuration cleanup."
    intentionalNoteForOperation[reset_outlook]="README parity note: Word, Excel, PowerPoint, Outlook, and OneNote stop after repair instead of continuing with configuration cleanup."
    intentionalNoteForOperation[reset_onenote]="README parity note: Word, Excel, PowerPoint, Outlook, and OneNote stop after repair instead of continuing with configuration cleanup."
    intentionalNoteForOperation[reset_teams]="README parity note: reset_teams preserves Teams backgrounds, resets Teams TCC state, opens Screen Recording settings in interactive modes, and preserves app bundles unless repair is required."
    intentionalNoteForOperation[reset_autoupdate]="README parity note: AutoUpdate registration treats new Teams as TEAMS21 while keeping classic Teams on the legacy product ID."
    intentionalNoteForOperation[reset_license]="README parity note: reset_license and reset_credentials split MOFA's license-only and broader sign-in reset flows."
    intentionalNoteForOperation[reset_credentials]="README parity note: reset_license and reset_credentials split MOFA's license-only and broader sign-in reset flows."

    localOnlyReason[reset_teams_force]="Local-only force-reinstall path for Teams."
    localOnlyReason[remove_acrobat_addin]="Local-only Adobe Acrobat add-in cleanup workflow."

    appendReportLine "## Script Coverage"
    appendReportLine ""
    appendReportLine "| MOFA Script | Local Operation | Classification | Notes |"
    appendReportLine "| --- | --- | --- | --- |"

    for operationID in "${mappedOperations[@]}"; do
        mofaScriptRelativePath="${mofaScriptPathForOperation[${operationID}]}"
        mofaScriptPath="${mofaRepoPath}/${mofaScriptRelativePath}"
        mofaScriptURL="$(pathToFileURL "${mofaScriptPath}")"
        localOpLabel="${operationID}"
        classification="Covered"
        note=""

        if [[ ! -f "${mofaScriptPath}" ]]; then
            classification="Candidate inclusion"
            note="Mapped MOFA community script is missing from the sibling checkout."
            addCandidateItem "${operationID}: expected MOFA script missing at ${mofaScriptRelativePath}"
        elif ! scriptContainsOperation "${operationID}"; then
            classification="Candidate inclusion"
            note="Mapped local operation is not present in Microsoft-365-Reset.zsh."
            addCandidateItem "${operationID}: mapped MOFA script exists but local operation is missing"
        elif [[ -n "${intentionalNoteForOperation[${operationID}]}" ]]; then
            classification="Intentional divergence"
            note="${intentionalNoteForOperation[${operationID}]}"
            addIntentionalItem "${operationID}: ${note}"
        else
            note="Mapped MOFA community script is represented by a local operation."
        fi

        appendReportLine "| [$(basename "${mofaScriptRelativePath}")](${mofaScriptURL}) | \`${localOpLabel}\` | ${classification} | $(escapeForMarkdown "${note}") |"
    done

    appendPackageEraSection

    appendReportLine ""
    appendReportLine "## Local-Only Operations"
    appendReportLine ""
    appendReportLine "| Local Operation | Classification | Notes |"
    appendReportLine "| --- | --- | --- |"

    for operationID in "${localOnlyOperations[@]}"; do
        note="${localOnlyReason[${operationID}]}"
        if ! scriptContainsOperation "${operationID}"; then
            note="Expected local-only operation is missing from Microsoft-365-Reset.zsh."
            addCandidateItem "${operationID}: expected local-only operation is missing from Microsoft-365-Reset.zsh"
            classification="Candidate inclusion"
        else
            classification="Local-only operation"
            addLocalOnlyItem "${operationID}: ${note}"
        fi

        appendReportLine "| \`${operationID}\` | ${classification} | $(escapeForMarkdown "${note}") |"
    done

    appendReportLine ""
}

function buildFeedComparisonSection() {
    local feedPath="${mofaRepoPath}/latest_raw_files/macos_standalone_latest.json"
    local component
    local feedComponentName
    local feedPrimaryURL
    local feedAppOnlyURL
    local feedApplicationID
    local feedFullVersion
    local localPrimary
    local localFallback
    local localApplicationID
    local localThreshold
    local classification
    local note
    local displayName
    local fallbackNote

    typeset -A feedNameForComponent
    typeset -A localPrimaryURL
    typeset -A localFallbackURL
    typeset -A localApplicationIDForComponent
    typeset -A localMinimumThreshold

    local components=(Word Excel PowerPoint Outlook OneNote OneDrive Teams MAU)

    feedNameForComponent[Word]="Word"
    feedNameForComponent[Excel]="Excel"
    feedNameForComponent[PowerPoint]="PowerPoint"
    feedNameForComponent[Outlook]="Outlook"
    feedNameForComponent[OneNote]="OneNote"
    feedNameForComponent[OneDrive]="OneDrive"
    feedNameForComponent[Teams]="Teams"
    feedNameForComponent[MAU]="MAU"

    localPrimaryURL[Word]="https://go.microsoft.com/fwlink/?linkid=525134"
    localPrimaryURL[Excel]="https://go.microsoft.com/fwlink/?linkid=525135"
    localPrimaryURL[PowerPoint]="https://go.microsoft.com/fwlink/?linkid=525136"
    localPrimaryURL[Outlook]="https://go.microsoft.com/fwlink/?linkid=2228621"
    localPrimaryURL[OneNote]="https://go.microsoft.com/fwlink/?linkid=820886"
    localPrimaryURL[OneDrive]="https://go.microsoft.com/fwlink/?linkid=861011"
    localPrimaryURL[Teams]="https://go.microsoft.com/fwlink/?linkid=2249065"
    localPrimaryURL[MAU]="https://go.microsoft.com/fwlink/?linkid=830196"

    localFallbackURL[Word]="https://go.microsoft.com/fwlink/?linkid=871748"
    localFallbackURL[Excel]="https://go.microsoft.com/fwlink/?linkid=871750"
    localFallbackURL[PowerPoint]="https://go.microsoft.com/fwlink/?linkid=871751"
    localFallbackURL[Outlook]="https://go.microsoft.com/fwlink/?linkid=871753"
    localFallbackURL[OneNote]="https://go.microsoft.com/fwlink/?linkid=871755"

    localApplicationIDForComponent[Word]="MSWD2019"
    localApplicationIDForComponent[Excel]="XCEL2019"
    localApplicationIDForComponent[PowerPoint]="PPT32019"
    localApplicationIDForComponent[Outlook]="OPIM2019"
    localApplicationIDForComponent[OneNote]="ONMC2019"
    localApplicationIDForComponent[OneDrive]="ONDR18"
    localApplicationIDForComponent[Teams]="TEAMS21"
    localApplicationIDForComponent[MAU]="MSau04"

    localMinimumThreshold[Teams]="23247.0"
    localMinimumThreshold[MAU]="4.49"

    appendReportLine "## Feed Comparison"
    appendReportLine ""
    appendReportLine "| Component | Classification | Notes |"
    appendReportLine "| --- | --- | --- |"

    [[ -f "${feedPath}" ]] || dieReport "MOFA stable feed not found: ${feedPath}"

    for component in "${components[@]}"; do
        displayName="${component}"
        feedComponentName="${feedNameForComponent[${component}]}"
        localPrimary="${localPrimaryURL[${component}]}"
        localFallback="${localFallbackURL[${component}]}"
        localApplicationID="${localApplicationIDForComponent[${component}]}"
        localThreshold="${localMinimumThreshold[${component}]}"

        feedPrimaryURL="$(extractFeedField "${feedPath}" "${feedComponentName}" "full_update_download")"
        feedAppOnlyURL="$(extractFeedField "${feedPath}" "${feedComponentName}" "app_only_update_download")"
        feedApplicationID="$(extractFeedField "${feedPath}" "${feedComponentName}" "application_id")"
        feedFullVersion="$(extractFeedField "${feedPath}" "${feedComponentName}" "full_version")"

        classification="Covered"
        note=""
        fallbackNote=""

        if [[ -z "${feedFullVersion}" ]]; then
            classification="Skipped"
            note="MOFA stable feed does not publish ${displayName} in macos_standalone_latest.json; local comparison was skipped."
            appendReportLine "| ${displayName} | ${classification} | $(escapeForMarkdown "${note}") |"
            continue
        fi

        if [[ "${feedPrimaryURL}" != "${localPrimary}" ]]; then
            classification="Candidate inclusion"
            note="Primary repair URL differs. Local: ${localPrimary}; MOFA stable feed: ${feedPrimaryURL}."
            addCandidateItem "${displayName}: primary repair URL differs from MOFA stable feed"
        else
            note="Primary repair URL matches MOFA stable feed."
        fi

        if [[ -n "${localApplicationID}" && "${feedApplicationID}" != "${localApplicationID}" ]]; then
            classification="Candidate inclusion"
            note="${note} Application ID differs. Local: ${localApplicationID}; MOFA stable feed: ${feedApplicationID}."
            addCandidateItem "${displayName}: application ID differs from MOFA stable feed"
        elif [[ -n "${localApplicationID}" ]]; then
            note="${note} Application ID matches ${localApplicationID}."
        fi

        if [[ -n "${localFallback}" && -n "${feedAppOnlyURL}" && "${feedAppOnlyURL}" != "N/A" ]]; then
            fallbackNote=" Local fallback repair URL remains hard-coded as ${localFallback}; MOFA stable feed publishes the app-only package as ${feedAppOnlyURL}."
            note="${note}${fallbackNote}"
        fi

        if [[ -n "${localThreshold}" ]]; then
            if is-at-least "${localThreshold}" "${feedFullVersion}"; then
                note="${note} Current MOFA version ${feedFullVersion} remains above the local minimum threshold ${localThreshold}."
            else
                classification="Candidate inclusion"
                note="${note} Current MOFA version ${feedFullVersion} is below the local minimum threshold ${localThreshold}."
                addCandidateItem "${displayName}: current MOFA version ${feedFullVersion} is below local threshold ${localThreshold}"
            fi
        fi

        appendReportLine "| ${displayName} | ${classification} | $(escapeForMarkdown "${note}") |"
    done

    appendReportLine ""
}

function writeReport() {
    local outputDirectory
    local candidateCount="${#candidateItems[@]}"
    local intentionalCount="${#intentionalItems[@]}"
    local localOnlyCount="${#localOnlyItems[@]}"
    local line

    outputDirectory="$(dirname "${outputPath}")"
    mkdir -p "${outputDirectory}" 2>/dev/null || dieReport "Unable to create report directory: ${outputDirectory}"

    : > "${outputPath}" 2>/dev/null || dieReport "Unable to write report output: ${outputPath}"

    {
        print -r -- "# MOFA Consultation Report"
        print -r -- ""
        print -r -- "- Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
        print -r -- "- Microsoft 365 Reset repo: ${repoRoot}"
        print -r -- "- MOFA repo: ${mofaRepoPath}"
        print -r -- "- Stable feed: latest_raw_files/macos_standalone_latest.json"
        print -r -- ""
        print -r -- "## Summary"
        print -r -- ""
        print -r -- "- Candidate inclusion items: ${candidateCount}"
        print -r -- "- Intentional divergences: ${intentionalCount}"
        print -r -- "- Local-only operations: ${localOnlyCount}"
        print -r -- ""

        for line in "${reportLines[@]}"; do
            print -r -- "${line}"
        done

        print -r -- "## Candidate Inclusion Items"
        print -r -- ""
        if (( candidateCount == 0 )); then
            print -r -- "- None"
        else
            for line in "${candidateItems[@]}"; do
                print -r -- "- ${line}"
            done
        fi

        print -r -- ""
        print -r -- "## Intentional Divergences"
        print -r -- ""
        if (( intentionalCount == 0 )); then
            print -r -- "- None"
        else
            for line in "${intentionalItems[@]}"; do
                print -r -- "- ${line}"
            done
        fi

        print -r -- ""
        print -r -- "## Local-Only Operation Notes"
        print -r -- ""
        if (( localOnlyCount == 0 )); then
            print -r -- "- None"
        else
            for line in "${localOnlyItems[@]}"; do
                print -r -- "- ${line}"
            done
        fi
    } > "${outputPath}" || dieReport "Unable to finish writing report output: ${outputPath}"

    info "MOFA report written to ${outputPath}"
    print -r -- "Summary: ${candidateCount} candidate inclusion item(s), ${intentionalCount} intentional divergence(s), ${localOnlyCount} local-only operation(s)"
}

function buildReport() {
    candidateItems=()
    intentionalItems=()
    localOnlyItems=()
    reportLines=()

    buildScriptCoverageSection
    buildFeedComparisonSection
    writeReport
    emitCodexPrompt
}

function validateInputs() {
    [[ -f "${m365ScriptPath}" ]] || dieUsage "Microsoft-365-Reset.zsh not found at expected path: ${m365ScriptPath}"

    if [[ "${runSync}" == "true" || "${runReport}" == "true" ]]; then
        [[ -d "${mofaRepoPath}" ]] || dieUsage "MOFA repo path not found: ${mofaRepoPath}"
    fi

    if [[ "${runSync}" == "true" ]]; then
        [[ -d "${mofaRepoPath}/.git" ]] || dieUsage "MOFA repo path is not a git checkout: ${mofaRepoPath}"
    fi
}

while [[ $# -gt 0 ]]; do
    case "${1}" in
        --sync-only)
            runSync="true"
            runReport="false"
            shift
            ;;
        --report-only)
            runSync="false"
            runReport="true"
            shift
            ;;
        --mofa-repo)
            [[ -n "${2:-}" ]] || dieUsage "Missing value for --mofa-repo"
            mofaRepoPath="${2}"
            shift 2
            ;;
        --output)
            [[ -n "${2:-}" ]] || dieUsage "Missing value for --output"
            outputPath="${2}"
            shift 2
            ;;
        --no-push-origin)
            pushOrigin="false"
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            dieUsage "Unknown argument: ${1}"
            ;;
    esac
done

if [[ "${runSync}" != "true" && "${runReport}" != "true" ]]; then
    dieUsage "Nothing to do. Choose sync, report, or both."
fi

if [[ -d "${mofaRepoPath}" ]]; then
    mofaRepoPath="$(resolveExistingPath "${mofaRepoPath}")"
fi

validateInputs

if [[ "${runSync}" == "true" ]]; then
    syncMofaRepo
fi

if [[ "${runReport}" == "true" ]]; then
    buildReport
fi

exit 0
