#!/bin/bash
set -eo pipefail

die() {
    echo 'TEST ERROR:' "$@" 1>&2
    exit 1
}
