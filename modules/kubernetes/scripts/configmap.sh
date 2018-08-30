#!/bin/bash

# Reads the contents of a ConfigMap as string:string JSON map suitable for Terraform.
function main() {
	local filename=${1}
	if [ -z ${filename} ] || [ ! -f ${filename} ]; then
		echo "A filename containing a ConfigMap must be specified" >&2 && exit 1
	fi

	read_configmap ${filename}
}

# Use kubectl to extract keys + values of ConfigMap.
function read_configmap() {
	local filename=${1}
	local template=

	local contents="$(kubectl --server 127.0.0.8 convert -f ${filename} -o go-template='{{range $k, $v := .data}}"{{$k}}":"{{$v}}",{{end}}ENDMAP' | grep ",ENDMAP" | sed -e "s/,ENDMAP//g")"
	echo "{${contents}}"
}

main "$@"
