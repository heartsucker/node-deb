#!/bin/bash
set -eu

declare -r target_file='/var/log/no-init/TEST_OUTPUT'

rm -rf "$target_file"
touch "$target_file"
