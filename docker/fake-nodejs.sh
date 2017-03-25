#!/bin/bash
set -e
set -u

wrk_dir=$(mktemp -d)
declare -r wrk_dir
declare -r deb_dir="$wrk_dir/deb"

cd "$wrk_dir"
mkdir -p "$deb_dir/DEBIAN"

cat > "$deb_dir/DEBIAN/control" <<-EOF
Package: nodejs
Version: 6.0.0
Section: base
Priority: optional
Architecture: all
Maintainer: nodejs
Description: nodejs
EOF

dpkg-deb --build "$deb_dir" fake-nodejs.deb
dpkg -i fake-nodejs.deb
