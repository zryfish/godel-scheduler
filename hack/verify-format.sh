#!/bin/bash

REPO_ROOT=${REPO_ROOT:-"$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"}

local_pkg=${LOCAL_PKG_PREFIX:-"github.com/kubewharf/godel-scheduler"}

# the first arg is relative path in repo root
# so we can format only for the file or files the directory
path=${1:-${REPO_ROOT}}

find_files() {
    find ${1:-.} -not \( \( \
        -wholename '*/output' \
        -o -wholename '*/.git/*' \
        -o -wholename '*/vendor/*' \
        -o -name 'bindata.go' \
        -o -name 'datafile.go' \
        -o -name '*.pb.go' \
        -o -name '*.go.bak' \
        \) -prune \) \
        -name '*.go'
}

# gofmt exits with non-zero exit code if it finds a problem unrelated to
# formatting (e.g., a file does not parse correctly). Without "|| true" this
# would have led to no useful error message from gofmt, because the script would
# have failed before getting to the "echo" in the block below.
diff=$(find_files | xargs gofmt -d -s 2>&1) || true
if [[ -n "${diff}" ]]; then
  echo "${diff}" >&2
  echo >&2
  echo "Run ./hack/update-format.sh" >&2
  exit 1
fi