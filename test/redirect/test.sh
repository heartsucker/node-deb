#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

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

redirect                           || die 'Could not run redirect script'
[ -f "$target_file" ]              || die 'Target file not present'
[ -f "$target_file_stdout" ]       || die 'stdout target file not present'
[ -f "$target_file_stderr" ]       || die 'stderr target file not present'
[ -f "$target_file_redirect" ]     || die 'redirect target file not present'
! grep -q '{{' "$(which redirect)" || die 'Variable interpolator still present in template'

apt-get purge -y redirect
