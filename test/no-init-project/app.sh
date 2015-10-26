#!/bin/bash
set -ex

target_file='/var/log/no-init-project/TEST_OUTPUT'

rm -rf "$target_file"

while true; do
  touch "$target_file"
  sleep 1
done
