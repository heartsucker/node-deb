#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
declare -r output='no-init_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

../../../node-deb --verbose \
                  -- app.sh

dpkg -i "$output.deb"

declare -r target_file='/var/log/no-init/TEST_OUTPUT'

[ ! -f "$target_file" ]
no-init
[ -f "$target_file" ]

apt-get purge -y no-init
