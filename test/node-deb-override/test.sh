#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='overridden-package-name_0.1.1_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js lib

grep -q 'Package: overridden-package-name' "$output/DEBIAN/control" \
  || die 'Package name not overridden'
grep -q 'Version: 0.1.1' "$output/DEBIAN/control" \
  || die 'Version not overridden'
grep -q 'Maintainer: overridden maintainer' "$output/DEBIAN/control" \
  || die 'Maintainer not overridden'
grep -q 'Description: overridden description' "$output/DEBIAN/control" \
  || die 'Description not overridden'
grep -q 'POSTINST_OVERRIDE' "$output/DEBIAN/postinst" \
  || die 'postinst script not overridden'
grep -q 'POSTRM_OVERRIDE' "$output/DEBIAN/postrm" \
  || die 'postrm script not overridden'
grep -q 'PRERM_OVERRIDE' "$output/DEBIAN/prerm" \
  || die 'prerm script not overridden'
grep -q 'SYSTEMD_SERVICE_OVERRIDE' "$output/lib/systemd/system/overridden-package-name.service" \
  || die 'systemd unit not overridden'
grep -q 'UPSTART_CONF_OVERRIDE' "$output/etc/init/overridden-package-name.conf" \
  || die 'Upstat conf not overridden'
grep -q 'EXECUTABLE_OVERRIDE' "$output/usr/share/overridden-package-name/bin/overridden-executable-name" \
  || die 'Executable not overridden'
# TODO add more tests

dpkg -i "$output.deb"
apt-get purge -y overridden-package-name
