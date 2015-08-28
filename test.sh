#!/bin/bash
set -e

_pwd=`pwd`

finish() {
  cd $_pwd
  find test -name *.deb -type f -exec rm -f {} \;
}

trap "finish" EXIT

test-simple-project() {
  echo "Running tests for simple-project"
  cd "$_pwd/test/simple-project"
  ../../node-deb app.js lib/
  echo "Success for simple-project"
}

test-whitespace-project() {
  echo "Running tests for whitespace-project"
  cd "$_pwd/test/whitespace-project"
  ../../node-deb 'whitespace file.js' 'whitespace folder'
  ../../node-deb whitespace\ file.js whitespace\ folder
  echo "Success for whitespace-project"
}

test-simple-project
test-whitespace-project
