#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
declare -r output='simple_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js lib/

grep -q 'Package: simple' "$output/DEBIAN/control"
grep -q 'Version: 0.1.0' "$output/DEBIAN/control"

dpkg -i "$output.deb"
apt-get purge -y simple
