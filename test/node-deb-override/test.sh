#!/bin/bash
set -e
set -u

cd "$(dirname $0)/app"
declare -r output='overridden-package-name_0.1.1_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js lib

grep -q 'Package: overridden-package-name' "$output/DEBIAN/control"
grep -q 'Version: 0.1.1' "$output/DEBIAN/control"
grep -q 'Maintainer: overridden maintainer' "$output/DEBIAN/control"
grep -q 'Description: overridden description' "$output/DEBIAN/control"
grep -q 'POSTINST_OVERRIDE' "$output/DEBIAN/postinst"
grep -q 'POSTRM_OVERRIDE' "$output/DEBIAN/postrm"
grep -q 'PRERM_OVERRIDE' "$output/DEBIAN/prerm"
grep -q 'SYSTEMD_SERVICE_OVERRIDE' "$output/etc/systemd/system/overridden-package-name.service"
grep -q 'UPSTART_CONF_OVERRIDE' "$output/etc/init/overridden-package-name.conf"
grep -q 'EXECUTABLE_OVERRIDE' "$output/usr/share/overridden-package-name/bin/overridden-executable-name"
# TODO add more tests

dpkg -i "$output.deb"
apt-get purge -y overridden-package-name
