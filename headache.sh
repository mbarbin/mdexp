#!/bin/bash -e

DIRS_FILE="$(dirname "$0")/.headache.dirs"

if [ ! -f "$DIRS_FILE" ]; then
    echo "Directory list file '$DIRS_FILE' not found!" >&2
    exit 1
fi

while IFS= read -r dir; do
    # Ignore empty lines and lines starting with '#'
    [ -z "$dir" ] && continue
    case "$dir" in
        \#*) continue ;;
    esac
    echo "Apply headache to directory ${dir}"

    # Use per-directory COPYING.HEADER if it exists, otherwise fall back to root
    if [ -f "${dir}/COPYING.HEADER" ]; then
        header="${dir}/COPYING.HEADER"
    else
        header="COPYING.HEADER"
    fi

    # Apply headache to .ml files
    headache -c .headache.config -h "${header}" "${dir}"/*.ml

    # Check if .mli files exist in the directory, if so apply headache
    if ls "${dir}"/*.mli 1> /dev/null 2>&1; then
        headache -c .headache.config -h "${header}" "${dir}"/*.mli
    fi
done < "$DIRS_FILE"

dune fmt
