#!/usr/bin/env bash

# Text displayed on error or with no arguments.
USAGE="${0} [create|destroy] [manifest directory]"

# Creates or destroys manifests within cluster. KUBECONFIG should be set.
function main() {
	# check if should print help text
	if [ ${#} -eq 0 ]; then
		usage
	elif [ ${1} != "create" ] && [ ${1} != "destroy" ]; then
		usage "Either 'create' or 'destroy' must be first argument"
	elif [ ${#} -eq 1 ]; then
		usage "Manifest directory must be specified."
	fi

	local action=${1}
	local manifests=${2}

	case ${action} in
		create)
		apply_manifests ${manifests}
		;;
		destroy)
		delete_manifests ${manifests}
		;;
	esac
}

# Create manifests within cluster. Retries if necessary.
function apply_manifests() {
	local dir=${1}

	retry kubectl apply --recursive -f ${dir}
}

# Delete manifests from cluster
function delete_manifests() {
	local dir=${1}
	kubectl delete --recursive -f ${dir}
}

# Retries the given command RETRIES times with an exponentially increasing sleep starting with WAIT.
function retry() {
	local retries=${RETRIES-4}
	local timeout=${WAIT-1}
	local statusCode=0

	while [[ $retries > 0 ]]; do
		"${@}"
		statusCode=$?

		if [ $statusCode -eq 0 ]; then
			break
		fi

		echo "Error occurred running \'${@}\', retrying in ${timeout}." 1>&2
		sleep ${timeout}
		retries=$(( $retries - 1 ))
		timeout=$(( $timeout * 2 ))
	done

	return $statusCode
}

# Print usage information about the program.
function usage() {
	local code="0"
	local error="${1}"
	if [ ! -z "${error}" ]; then
		echo "Error: ${error}"
		code="1"
	fi

	echo "Usage: ${USAGE}"
	exit ${code}
}

main "$@"
