#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='no-init_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

../../../node-deb --verbose \
                  -- app.sh

dpkg -i "$output.deb"

declare -r target_file='/var/log/no-init/TEST_OUTPUT'

[ ! -f "$target_file" ] || die 'Target file present when it should not have been'
no-init                 || die 'Could not run executable'
[ -f "$target_file" ]   || die 'Target file not present when it should have been'

apt-get purge -y no-init
