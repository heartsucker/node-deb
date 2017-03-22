#!/bin/bash
set -e

mkdir -p /tmp
cd test/simple-project/app
../../../node-deb --verbose \
                  --no-delete-temp \
                  -- app.js lib/

declare -r output_dir='simple-project_0.1.0_all/'

if ! grep -q 'Package: simple-project' "$output_dir/DEBIAN/control"; then
  echo 'Package name was wrong'
  exit 1
fi

if ! grep -q 'Version: 0.1.0' "$output_dir/DEBIAN/control"; then
  echo 'Package version was wrong'
  exit 1
fi

echo "Success for simple-project"
rm -rf "$output_dir" *.deb
