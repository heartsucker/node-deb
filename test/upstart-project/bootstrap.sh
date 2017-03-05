#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update > /dev/null
apt-get install -y -f jq nodejs > /dev/null
apt-get purge upstart-project &> /dev/null || true

# pulling everything out of the shared folder because dpkg keeps
# installing everthing as owned by vagrant:vagrant instead of root:root
cd /root
if [ -a '/root/vagrant' ]; then
  rm -rf /root/vagrant;
fi
if [ -a '/root/node-deb' ]; then
  rm -rf /root/node-deb;
fi
cp -r /vagrant/ .
mv vagrant/ node-deb/
cd /root/node-deb/test/upstart-project
./../../node-deb --no-delete-temp -- app.sh

for pkg in $(find . -name '*.deb'); do
  dpkg -i "$pkg"
  echo "Package installed: $pkg"
done

set +e
service upstart-project start 2>&1

exit 0
