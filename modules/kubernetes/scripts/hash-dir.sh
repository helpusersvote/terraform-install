#!/usr/bin/env bash
set -euo pipefail

# Calculates a hash for the directory given as an argument and outputs it in a JSON object.
function main() {
	if [ ${#} -eq 0 ] || [ ${1} == "-h" ] || [ ${1} == "--help" ]; then
		echo "${0}: Calculates hashes of directories"
		echo
		echo "Usage: ${0} <DIRECTORY>"
		exit 1
	fi

	local path="${1}"
	printf '{"hash":"%s"}\n' $(hash-dir ${path})
}

# Returns a SHA1 hash of the SHA1 hash of every file in the directory.
function hash-dir() {
	local dir=${1}

	find ${dir} -maxdepth 1 -type f -exec sha1sum {} + | sort -z | sha1sum | cut -d" " -f1
}

main "$@"
