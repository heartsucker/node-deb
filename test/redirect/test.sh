#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
declare -r output='redirect_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

../../../node-deb --verbose \
                  -- app.sh

declare -r target_file='/var/log/redirect/TEST_OUTPUT'
declare -r target_file_stdout='/var/log/redirect/TEST_OUTPUT_STDOUT'
declare -r target_file_stderr='/var/log/redirect/TEST_OUTPUT_STDERR'
declare -r target_file_redirect='/var/log/redirect/TEST_OUTPUT_REDIRECT'

dpkg -i "$output.deb"

redirect
[ -f "$target_file" ]
[ -f "$target_file_stdout" ]
[ -f "$target_file_stderr" ]
[ -f "$target_file_redirect" ]
! grep -q '{{' "$(which redirect)"

apt-get purge -y redirect
