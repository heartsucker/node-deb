#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/.."
source 'test/test-helpers.sh'

node_deb_version=$(jq -r '.version' 'package.json')
declare -r node_deb_version
declare -r output="node-deb_${node_deb_version}_all/"

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

npm install -g .
export PATH="/opt/node/bin:$PATH"

# TODO check the output of these for not being totally borked

PAGER=cat node-deb --help           > /dev/null
PAGER=cat node-deb --show-readme    > /dev/null
PAGER=cat node-deb --show-changelog > /dev/null

node-deb --verbose \
         --no-delete-temp \
         -- node-deb templates

# TODO more checks (but this is sufficient for now)

[ -f "$output/DEBIAN/control" ] || \
  dir 'Control file not found'
