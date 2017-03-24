#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
declare -r output='overridden-package-name_0.1.1_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --no-delete-temp \
                  --verbose \
                  -n overridden-package-name \
                  -v 0.1.1 \
                  -u overridden-user \
                  -g overridden-group \
                  -m 'overridden maintainer' \
                  -d 'overridden description' \
                  -- app.js lib/

grep -q 'Package: overridden-package-name' "$output/DEBIAN/control"
grep -q 'Version: 0.1.1' "$output/DEBIAN/control"
grep -q 'Maintainer: overridden maintainer' "$output/DEBIAN/control"
grep -q 'Description: overridden description' "$output/DEBIAN/control"
# TODO more checks
# TODO add node_deb object overrides to ensure these beat them

dpkg -i "$output.deb"
apt-get purge -y "overridden-package-name"
