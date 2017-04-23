#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='real-cli_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

# TODO move this outside docker do we only do it once
npm install

../../../node-deb --verbose \
                  -- cli.js

dpkg -i "$output.deb"

run_cli() {
  cd /tmp/
  declare -r out='wat'
  declare -r outfile='some-file.txt'

  echo "$out" > "$outfile"

  real-cli "$outfile" | grep -q "$out"
}

run_cli

apt-get purge -y real-cli
