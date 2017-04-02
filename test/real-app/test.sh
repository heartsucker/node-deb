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

[ -d "$output/usr/share/real-app/app/node_modules" ] || \
  die 'node_modules not found in Debian package'

if [[ $(find "$output/usr/share/real-app/app/node_modules/" -name 'node-deb' | wc -l) -gt 0 ]]; then
  die 'node-deb found in node_modules output'
fi

dpkg -i "$output.deb"
real-app &
sleep 1
curl --verbose localhost:8080/
apt-get purge -y real-app

../../../node-deb --verbose \
                  --no-delete-temp \
                  --install-strategy copy \
                  -- app.js

[ -d "$output/usr/share/real-app/app/node_modules" ] || \
  die 'node_modules not found in Debian package'

dpkg -i "$output.deb"
real-app &
sleep 1
curl --verbose localhost:8080/
apt-get purge -y real-app

../../../node-deb --verbose \
                  --no-delete-temp \
                  --install-strategy npm-install \
                  -- app.js

[ -d "$output/usr/share/real-app/app/node_modules" ] && \
  die 'node_modules was found in Debian package'

dpkg -i "$output.deb"
real-app &
sleep 1
curl --verbose localhost:8080/
apt-get purge -y real-app
