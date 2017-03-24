#!/bin/bash

test-extra-files-project() {
  echo 'Running tests for extra-files-project'
  declare -i is_success=1

  cd "$_pwd/test/extra-files-project" || die 'cd error'

  output=$(../../node-deb --no-delete-temp \
    --verbose \
    --extra-files extra-files \
    -- foo.sh)

  if [ "$?" -ne 0 ]; then
    is_success=0
  fi

  dpkg_output=$(dpkg -c extra-files-project_0.1.0_all.deb)

  if echo "$dpkg_output" | grep -Eq '/extra-files/'; then
    is_success=0
    err 'Extra files contained bad prefix'
  fi

  if ! echo "$dpkg_output" | awk '{ print $NF }' | grep -Eq '^\./var/lib/extra-files-project/bar\.txt$'; then
    is_success=0
    err 'Extra files did not contain the target file'
  fi

  if [ "$is_success" -eq 1 ]; then
    echo "Success for extra-files-project"
    rm -rf "$_pwd/test/extra-files-project/extra-files-project_0.1.0_all*"
  else
    err "Failure for extra-files-project"
    err "$output"
    err "$dpkg_output"
    : $((failures++))
  fi
}

test-upstart-project() {
  echo 'Running tests for upstart-project'
  declare -r target_file='/var/log/upstart-project/TEST_OUTPUT'
  declare -i is_success=1

  # Make sure process can be started
  vagrant up --provision upstart && \
  vagrant ssh upstart -c "if [ -a '$target_file' ]; then sudo rm -rf '$target_file'; fi" && \
  echo 'Sleeping...' && \
  sleep 3 && \
  vagrant ssh upstart -c "[ -f '$target_file' ]"

  if [ "$?" -ne 0 ]; then
    is_success=0
    err 'Failure on checking file existence for target host'
  fi

  # Make sure process can be stopped
  vagrant ssh upstart -c "sudo service upstart-project stop && { if [ -a '$target_file' ]; then sudo rm -rf '$target_file'; fi }" && \
  echo 'Sleeping...' && \
  sleep 3 && \
  vagrant ssh upstart -c "[ ! -f '$target_file' ]"

  if [ "$?" -ne 0 ]; then
    is_success=0
    err 'Failure on checking file absence for target host after process was stopped'
  fi

  if [ "$is_success" -ne 1 ]; then
    err 'Failure for upstart-project'
    : $((failures++))
  else
    vagrant destroy -f upstart
    echo 'Success for upstart-project'
  fi
}

test-systemd-project() {
  echo 'Running tests for systemd-project'
  declare -r target_file='/var/log/systemd-project/TEST_OUTPUT'
  declare -i is_success=1

  # Make sure process can be started
  vagrant up --provision systemd && \
  vagrant ssh systemd -c "if [ -a '$target_file' ]; then sudo rm -rf '$target_file'; fi" && \
  echo 'Sleeping...' && \
  sleep 3 && \
  vagrant ssh systemd -c "[ -f '$target_file' ]"

  if [ "$?" -ne 0 ]; then
    is_success=0
    err 'Failure on checking file existence for target host'
  fi

  # Make sure process can be stopped
  vagrant ssh systemd -c "sudo systemctl stop systemd-project && { if [ -a '$target_file' ]; then sudo rm -rf '$target_file'; fi }" && \
  echo 'Sleeping...' && \
  sleep 3 && \
  vagrant ssh systemd -c "[ ! -f '$target_file' ]"

  if [ "$?" -ne 0 ]; then
    is_success=0
    err 'Failure on checking file absence for target host after process was stopped'
  fi

  if [ "$is_success" -ne 1 ]; then
    err 'Failure for systemd-project'
    : $((failures++))
  else
    vagrant destroy -f systemd
    echo 'Success for systemd-project'
  fi
}

test-no-init-project() {
  echo 'Running tests for no-init-project'
  declare -r target_file='/var/log/no-init-project/TEST_OUTPUT'
  declare -i is_success=1

  vagrant up --provision no-init && \
  sleep 3 && \
  vagrant ssh no-init -c "[ ! -f '$target_file' ]"

  if [ "$?" -ne 0 ]; then
    is_success=0
    err 'Failure on checking file absence for target host'
  fi

  vagrant ssh no-init -c "no-init-project" && \
  vagrant ssh no-init -c "[ -f '$target_file' ]"

  if [ "$is_success" -ne 1 ]; then
    err 'Failure for no-init-project'
    : $((failures++))
  else
    vagrant destroy -f no-init
    echo 'Success for no-init-project'
  fi
}

test-redirect-project() {
  echo 'Running tests for redirect-project'
  declare -r target_file='/var/log/redirect-project/TEST_OUTPUT'
  declare -r target_file_stdout='/var/log/redirect-project/TEST_OUTPUT_STDOUT'
  declare -r target_file_stderr='/var/log/redirect-project/TEST_OUTPUT_STDERR'
  declare -r target_file_redirect='/var/log/redirect-project/TEST_OUTPUT_REDIRECT'
  declare -i is_success=1

  vagrant up --provision redirect && \
  vagrant ssh redirect -c "sudo redirect-project" && \
  echo 'App was run.' && \
  vagrant ssh redirect -c "[ -f '$target_file' ] && [ -f '$target_file_stdout' ] && [ -f '$target_file_stderr' ] && [ -f '$target_file_redirect' ]" && \
  echo 'Files were found.' && \
  vagrant ssh redirect -c "{ ! grep -q '{{' \"$(which redirect-project)\"; }" && \
  echo 'Everything was replaced.'

  if [ "$?" -ne 0 ]; then
    is_success=0
  fi

  if [ "$is_success" -ne 1 ]; then
    err 'Failure for redirect-project'
    : $((failures++))
  else
    vagrant destroy -f redirect
    echo 'Success for redirect-project'
  fi
}

test-dog-food() {
  echo 'Running the dog food test'
  cd "$_pwd" || die 'cd error'
  declare -i is_success=1

  if ! ./node-deb --verbose --no-delete-temp -- node-deb templates/; then
    is_success=0
  fi

  declare -r node_deb_version=$(jq -r '.version' "./package.json")
  declare -r output_dir="node-deb_${node_deb_version}_all/"

  if [ $(find "$output_dir" -name 'node-deb' -type f | wc -l) -lt 1 ]; then
    is_success=0
    err "Couldn't find node-deb in output"
  fi

  if [ $(find "$output_dir" -name 'templates' -type d | wc -l) -lt 1 ] || [ $(find "$output_dir/" -type f | grep 'templates' | wc -l) -lt 1 ]; then
    is_success=0
    err "Couldn't find templates"
  fi

  rm -rf "$output_dir"

  if [ "$is_success" -ne 1 ]; then
    : $((failures++))
    err 'Failure for the dog food test'
  else
    echo 'Success for the dog food test'
  fi
}
