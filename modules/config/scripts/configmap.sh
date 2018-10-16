#!/bin/bash

# Run kubectl configured to convert and not use API server.
KCONVERT="kubectl --server 127.0.0.8 convert --local"

# Directory to get revision of when reporting git_sha"
GIT_DIR=${3:-""}

# Reads the contents of a ConfigMap as string:string JSON map suitable for Terraform.
function main() {
	local filename=${1}
	if [ -z ${filename} ] || [ ! -f ${filename} ]; then
		echo "A filename containing a ConfigMap must be specified" >&2 && exit 1
	fi

	local key=${2}
	if [ -z ${key} ]; then
		print_configmap ${filename} | close_json
	else
		read_configmap_value ${filename} ${key} | print_first_configmap - | close_json
	fi

}

# Use kubectl to extract keys + values of ConfigMap.
function print_configmap() {
	local filename=${1}

	${KCONVERT} -f ${filename} -o go-template='{{range $k, $v := .data}},"{{js $k}}":"{{js $v}}"{{end}}'
}

# Use kubectl to extract keys + values of first ConfigMap in list of them.
function print_first_configmap() {
	local filename=${1}

	${KCONVERT} -f ${filename} -o go-template='{{range $flk, $flv := .items}}{{range $lk, $lv := $flv.items}}{{range $k, $v := $lv.data}},"{{js $k}}":"{{js $v}}"{{end}}{{end}}{{end}}'
}

# Convert YAML formatted ConfigMap Value to temporary string:string ConfigMap for given file and key.
function read_configmap_value() {
	local filename=${1}
	local key=${2}

	local git_hash=""
	if [ ! -z ${GIT_DIR} ]; then
		git_hash=$(printf "\n  git_sha: %s\n" $(git_sha))
	fi

	cat <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: temp
data:${git_hash}
  _name: ${key}
$(${KCONVERT} -f ${filename} -o go-template="{{range \$k, \$v := .data}}{{if eq \$k \"${key}\"}}{{\$v}}{{end}}{{end}}" | sed "s/^/  /g")
EOF
}

# Places brackets around JSON body
function close_json() {
	echo "{$(cat)}" | sed 's/{,/{/g'
}

function git_sha() {
	git -C ${GIT_DIR} rev-parse HEAD 2>/dev/null
}

main "$@"
