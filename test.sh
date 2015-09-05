#!/bin/bash
set -e

_pwd=`pwd`

finish() {
  cd "$_pwd"
  find test -name *.deb -type f | xargs rm -f
}

trap "finish" EXIT

die() {
  echo "$@" >&2
  exit 1
}

test-simple-project() {
  echo "Running tests for simple-project"
  cd "$_pwd/test/simple-project"
  ../../node-deb -- app.js lib/
  echo "Success for simple-project"
}

test-whitespace-project() {
  echo "Running tests for whitespace-project"
  cd "$_pwd/test/whitespace-project"

  output=`../../node-deb -- 'whitespace file.js' 'whitespace folder' 2>&1`
  output+='\n'
  output+=`../../node-deb --  whitespace\ file.js whitespace\ folder 2>&1`

  if [[ $output == '*No such file or directory*' ]]; then
    echo 'There was an error with the test.' >&2
    echo -e "$output" >&2
    die 'Unable to locate a directory. This is likely an error with `find`.'
  fi

  echo "Success for whitespace-project"
}

test-simple-project
test-whitespace-project

finish
