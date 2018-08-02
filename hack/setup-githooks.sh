#!/bin/bash -e

# Installs githooks to perform validations

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$(dirname ${DIR})"

echo "Installing hclfmt"
go get -v github.com/fatih/hclfmt

hclfmt="$GOPATH/bin/hclfmt"
if [ ! -x ${binPath} ]; then
	echo "Couldn't install hclfmt to ${hclfmt}"; exit 1
fi

echo "Creating githooks"
ln -s -f ../../hack/check-fmt ${ROOT}/.git/hooks/pre-commit
