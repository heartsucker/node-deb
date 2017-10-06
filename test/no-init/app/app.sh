#!/bin/bash
set -eu

declare -r target_file='/var/log/no-init/TEST_OUTPUT'
mkdir -p "$(dirname "$target_file")"

touch "$target_file"
