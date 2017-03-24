#!/bin/bash

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
