#!/bin/bash
set -e
set -u

cd "$(dirname $0)/app"
declare -r output='whitespace_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --no-delete-temp \
                  --verbose \
                  -- 'whitespace file.js' 'whitespace folder'

stat "$output/usr/share/whitespace/app/whitespace file.js" > /dev/null
stat "$output/usr/share/whitespace/app/whitespace folder/" > /dev/null
stat "$output/usr/share/whitespace/app/whitespace folder/file1.js" > /dev/null
stat "$output/usr/share/whitespace/app/whitespace folder/file 2.js" > /dev/null
stat "$output/usr/share/whitespace/app/whitespace folder/\"file 3\".js" > /dev/null
stat "$output/usr/share/whitespace/app/whitespace folder/'file 4'.js" > /dev/null

dpkg -i "$output.deb"
apt-get purge -y whitespace
