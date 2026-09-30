#!/bin/zsh

# Author: Bart Reardon
# Date: 2023-11-23
# https://github.com/bartreardon/macscripts/blob/master/create_self_extracting_script.sh

# Updated by: Dan K. Snelson
# For Microsoft 365 Reset
# Date: 29-Sep-2026
# - Extract into a root-private `mktemp -d` directory (not a fixed `/var/tmp` path)
# - Forward wrapper arguments (Jamf `$1`-`$6`, CLI flags) to the extracted script
# - Restrict `--target` to inert filename characters (rejecting `.` and `..`)
# - Pin wrapper `PATH`, use absolute tool paths, and run the extracted script with `/bin/zsh --no-rcs`

# Script for creating self extracting base64 encoded files.

# usage: file_to_self_extracting_script <file_path> [target_name]

SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FILE_TO_ENCODE="$(cd "${SCRIPT_DIR}"/.. && pwd)/Microsoft-365-Reset.zsh"
TARGET_NAME="Microsoft-365-Reset.zsh"

datestamp=$( date '+%Y-%m-%d-%H%M%S' )

file_to_self_extracting_script() {
    base64_string=$(base64 -i "$1")
    filename=$(basename "$1")
    local target_name="$(basename "${2:-${TARGET_NAME}}")"
    if [[ ! "${target_name}" =~ '^[A-Za-z0-9._-]+$' || "${target_name}" == "." || "${target_name}" == ".." ]]; then
        echo "Error: Invalid target name '${target_name}'; use letters, digits, '.', '_', or '-' only."
        exit 1
    fi
    output_script="${SCRIPT_DIR}/${filename}_self-extracting-${datestamp}.sh"

    cat <<EOF > "${output_script}"
#!/bin/sh
PATH=/usr/bin:/bin:/usr/sbin:/sbin
export PATH
base64_string='$base64_string'
target_dir="\$(/usr/bin/mktemp -d /private/var/tmp/M365R-extract.XXXXXX)" || exit 1
/bin/chmod 700 "\${target_dir}" || exit 1
trap '/bin/rm -rf "\${target_dir}"' EXIT
target_path="\${target_dir}/${target_name}"
printf '%s' "\$base64_string" | /usr/bin/base64 -d > "\${target_path}" || exit 1
/bin/chmod 700 "\${target_path}"
echo "File '\${target_path}' has been created."
/bin/zsh --no-rcs "\${target_path}" "\$@"
exit \$?
EOF
    echo "Self-extracting script '${output_script}' created."
}

printUsage() {
    echo "OVERVIEW: ${SCRIPT_NAME} is a utility that creates self extracting base64 encoded scripts."
    echo ""
    echo "USAGE: ${SCRIPT_NAME} [--file <filename>] [--target <name>]"
    echo ""
    echo "DEFAULTS:"
    echo "    Source file: ${FILE_TO_ENCODE}"
    echo "    Target name: ${TARGET_NAME} (extracted into a private mktemp -d directory at runtime)"
    echo ""
    echo "OPTIONS:"
    echo "    -f, --file <filename>     Encode the selected file"
    echo "    -t, --target <name>       Filename for the extracted script (directory is always private)"
    echo "    -h, --help                Print this message"
    echo ""
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --file|-f) FILE_TO_ENCODE="$2"; shift ;;
        --target|-t) TARGET_NAME="$2"; shift ;;
        --help|-h|help) printUsage; exit 0 ;;
        *) echo "Unknown argument: $1"; printUsage; exit 1 ;;
    esac
    shift
done

if [[ -z "$FILE_TO_ENCODE" ]]; then
    echo "Error: No file specified."
    printUsage
    exit 1
fi

file_to_self_extracting_script "${FILE_TO_ENCODE}" "${TARGET_NAME}"
