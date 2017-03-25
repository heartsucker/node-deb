#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='upstart-app_0.1.0_all'
declare -r target_file='/var/log/systemd-app/TEST_OUTPUT'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  -- app.sh

rm -rf "$target_file"
dpkg -i "$output.deb"
sleep 1
rm -rf "$target_file"
[ -f "$target_file" ] || die 'Target file did not exist when it should have'

systemctl stop systemd-app

rm -rf "$target_file"
sleep 1
[ ! -f "$target_file" ] || die 'Target file exists when it should not have'
