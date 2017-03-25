#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='extra-files_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  --extra-files additional \
                  -- foo.sh

[ -z "$(dpkg -c "$output.deb" | grep '/additional/')" ] \
  || die 'Path part /additional/ was present when it should not be'
dpkg -c "$output.deb" | awk '{ print $NF }' | grep -Eq '^\./var/lib/extras/bar\.txt$' \
  || die 'Extra file was not present'

dpkg -i "$output.deb"
apt-get purge -y extra-files
