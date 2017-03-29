#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='real-app_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

# TODO move this outside docker do we only do it once
npm install

../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js

! find "$output/usr/share/real-app/app/node_modules/" -name 'node-deb' 2> /dev/null || \
  die 'node-deb found in node_modules output'

dpkg -i "$output.deb"

real-app &
sleep 1
curl --verbose localhost:8080/

apt-get purge -y real-app
