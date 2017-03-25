#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='upstart-app_0.1.0_all'
declare -r target_file='/var/log/upstart-app/TEST_OUTPUT'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  -- app.sh

rm -rf "$target_file"
dpkg -i "$output.deb"
sleep 1
[ -f "$target_file" ] || die 'Target file not present when it should have been'

if hash systemctl 2> /dev/null; then
  systemctl stop upstart-app
elif hash service 2> /dev/null; then
  service upstart-app stop
else
  echo "Can't stop service"
fi

rm -rf "$target_file"
sleep 1
[ ! -f "$target_file" ] || die 'Target file present when it should not have been'

apt-get purge -y upstart-app
