#!/bin/bash

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
