#!/bin/bash
set -eu

declare -r target_file='/var/log/systemd-project/TEST_OUTPUT'

rm -rf "$target_file"

while true; do
  touch "$target_file"
done
