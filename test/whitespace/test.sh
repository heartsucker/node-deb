#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='whitespace_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --no-delete-temp \
                  --verbose \
                  -- 'whitespace file.js' 'whitespace folder' || true

declare -ar files=("whitespace file.js" 
                   "whitespace folder/"
                   "whitespace folder/file1.js"
                   "whitespace folder/file 2.js"
                   "whitespace folder/\"file 3\".js"
                   "whitespace folder/'file 4'.js")

for file in "${files[@]}"; do
  stat "$output/usr/share/whitespace/app/whitespace file.js" > /dev/null || \
    die "White space file missing: \`$file\`"
done 

dpkg -i "$output.deb"
apt-get purge -y whitespace
