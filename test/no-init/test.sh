#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/app"
source '../../test-helpers.sh'

declare -r output='no-init_0.1.0_all'

finish() {
  rm -rf "$output" *.deb
}

../../../node-deb --verbose \
                  -- app.sh

list_groups() {
  cut -d: -f1 /etc/group | sort
}

list_users() {
  cut -d: -f1 /etc/passwd | sort
}

old_groups=$(list_groups)
declare -r old_groups

old_users=$(list_users)
declare -r old_users

dpkg -i "$output.deb"
sleep 1

[[ "$(list_groups)" == "$old_groups" ]] || die 'Groups unequal'
[[ "$(list_users)" == "$old_users" ]] || die 'Users unequal'

declare -r target_file='/var/log/no-init/TEST_OUTPUT'

[ ! -f "$target_file" ] || die 'Target file present when it should not have been'
no-init                 || die 'Could not run executable'
[ -f "$target_file" ]   || die 'Target file not present when it should have been'

apt-get purge -y no-init
