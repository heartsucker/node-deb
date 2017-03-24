#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/.."
node_deb_version=$(jq -r '.version' 'package.json')
declare -r node_deb_version
declare -r output="node-deb_${node_deb_version}_all/"

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

./node-deb --no-delete-temp \
           --verbose \
           -- node-deb templates/

if [ $(find "$output" -name 'node-deb' -type f | wc -l) -lt 1 ]; then
  echo "Couldn't find node-deb in output"
  exit 1
fi

if [ $(find "$output" -name 'templates' -type d | wc -l) -lt 1 ] || [ $(find "$output/" -type f | grep 'templates' | wc -l) -lt 1 ]; then
  echo "Couldn't find templates"
  exit 1
fi

dpkg -i "node-deb_${node_deb_version}_all.deb"
node-deb --verbose \
         -- node-deb templates/
apt-get purge -y node-deb
