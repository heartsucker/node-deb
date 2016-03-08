#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update > /dev/null
apt-get install -y -f jq nodejs > /dev/null
apt-get purge no-init-project &> /dev/null || true

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
cd /root/node-deb/test/no-init-project
./../../node-deb --no-delete-temp -- app.sh package.json

for pkg in $(find . -name '*.deb'); do
  dpkg -i "$pkg"
  echo "Package installed: $pkg"
done

exit 0
