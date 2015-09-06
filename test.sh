#!/bin/bash

_pwd=`pwd`

finish() {
  cd "$_pwd"
  find test -name *.deb -type f | xargs rm -f
}

trap "finish" EXIT

err() {
  echo "$@" >&2
}

die() {
  err "$@"
  exit 1
}

failures=0

test-simple-project() {
  echo "Running tests for simple-project"
  cd "$_pwd/test/simple-project"
  local is_success=1
  output=`../../node-deb --no-delete-temp -- app.js lib/`

  if [ "$?" -ne 0 ]; then
    local is_success=0
    err "$output"
  fi

  local output_dir='simple-project_0.1.0_all/'

  if ! grep -q 'Package: simple-project' "$output_dir/DEBIAN/control"; then
    err 'Package name was wrong'
    local is_success=0
  fi

  if ! grep -q 'Version: 0.1.0' "$output_dir/DEBIAN/control"; then
    err 'Package version was wrong'
    local is_success=0
  fi

  if [ "$is_success" -eq 1 ]; then
    echo "Success for simple-project"
    rm -rf "$output_dir"
  else
    err "Failure for simple project"
    : $((failures++))
  fi
}

test-whitespace-project() {
  echo "Running tests for whitespace-project"
  cd "$_pwd/test/whitespace-project"

  local is_success=1

  output=`../../node-deb -- 'whitespace file.js' 'whitespace folder' 2>&1`
  if [ "$?" -ne 0 ]; then
    local is_success=0
  fi

  output+='\n'
  output+=`../../node-deb --  whitespace\ file.js whitespace\ folder 2>&1`
  if [ "$?" -ne 0 ]; then
    local is_success=0
  fi

  if [[ $output == '*No such file or directory*' ]]; then
    err 'There was an error with the test.'
    err -e "$output"
    err 'Unable to locate a directory. This is likely an error with `find`.'
  fi

  if [ "$is_success" -eq 1 ]; then
    echo "Success for whitespace-project"
  else
    err "Failure for whitespace-project"
    : $((failures++))
  fi
}

test-node-deb-override-project() {
  echo "Running tests for node-deb-override-project"
  cd "$_pwd/test/node-deb-override-project"
  local is_success=1
  output=`../../node-deb --no-delete-temp -- app.js lib/`

  if [ "$?" -ne 0 ]; then
    local is_success=0
    err "$output"
  fi

  local output_dir='overriden-package-name_0.1.1_all/'

  if ! grep -q 'Package: overriden-package-name' "$output_dir/DEBIAN/control"; then
    err 'Package name was wrong'
    local is_success=0
  fi

  if ! grep -q 'Version: 0.1.1' "$output_dir/DEBIAN/control"; then
    err 'Package version name was wrong'
    local is_success=0
  fi

  if ! grep -q 'Maintainer: overriden maintainer' "$output_dir/DEBIAN/control"; then
    err 'Package maintainer was wrong'
    local is_success=0
  fi

  if ! grep -q 'Description: overriden description' "$output_dir/DEBIAN/control"; then
    err 'Package description was wrong'
    local is_success=0
  fi

  if [ "$is_success" -eq 1 ]; then
    echo "Success for simple-project"
    rm -rf "$output_dir"
  else
    err "Failure for simple project"
    : $((failures++))
  fi
}

test-commandline-override-project() {
  echo "Running tests for commandline-override-project"
  cd "$_pwd/test/commandline-override-project"
  local is_success=1
  output=`../../node-deb --no-delete-temp \
    -n overriden-package-name \
    -v 0.1.1 \
    -u overriden-user \
    -g overriden-group \
    -m 'overriden maintainer' \
    -d 'overriden description' \
    -- app.js lib/`

  if [ "$?" -ne 0 ]; then
    local is_success=0
    err "$output"
  fi

  local output_dir='overriden-package-name_0.1.1_all/'

  if ! grep -q 'Package: overriden-package-name' "$output_dir/DEBIAN/control"; then
    err 'Package name was wrong'
    local is_success=0
  fi

  if ! grep -q 'Version: 0.1.1' "$output_dir/DEBIAN/control"; then
    err 'Package version name was wrong'
    local is_success=0
  fi

  if ! grep -q 'Maintainer: overriden maintainer' "$output_dir/DEBIAN/control"; then
    err 'Package maintainer was wrong'
    local is_success=0
  fi

  if ! grep -q 'Description: overriden description' "$output_dir/DEBIAN/control"; then
    err 'Package description was wrong'
    local is_success=0
  fi

  if [ "$is_success" -eq 1 ]; then
    echo "Success for simple-project"
    rm -rf "$output_dir"
  else
    err "Failure for simple project"
    : $((failures++))
  fi
}

echo '--------------------------'
test-simple-project
echo '--------------------------'
test-whitespace-project
echo '--------------------------'
test-node-deb-override-project
echo '--------------------------'
test-commandline-override-project
echo '--------------------------'

if [ "$failures" -eq 0 ]; then
  echo "Success for all tests"
else
  die "Tests contained $failures failure(s)."
fi

finish
