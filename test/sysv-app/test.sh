#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='sysv-app_0.1.0_all'
declare -r target_file='/var/log/sysv-app/TEST_OUTPUT'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  -- app.sh

rm -rf "$target_file"
dpkg -i "$output.deb"
sleep 1
[ -f "$target_file" ] || die 'Target file did not exist when it should have'

if hash systemctl 2> /dev/null; then
  systemctl disable sysv-app
  systemctl stop sysv-app
  
  rm -rf "$target_file"
  sleep 1
  [ ! -f "$target_file" ] || die 'Target file exists when it should not have'
  
  /etc/init.d/sysv-app start
  
  sleep 1
  [ -f "$target_file" ] || die 'Target file did not exist when it should have'
fi

/etc/init.d/sysv-app stop

rm -rf "$target_file"
sleep 1
[ ! -f "$target_file" ] || die 'Target file exists when it should not have'

apt-get purge -y sysv-app
