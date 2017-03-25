#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='simple_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js lib/

grep -q 'Package: simple' "$output/DEBIAN/control" || die 'Incorrect package name'
grep -q 'Version: 0.1.0' "$output/DEBIAN/control"  || die 'Incorrect package version'

dpkg -i "$output.deb"
apt-get purge -y simple
