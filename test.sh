#!/bin/bash
set -e

declare -ar all_versions=('debian-stretch'
                          'debian-jessie'
                          'debian-wheezy'
                          'ubuntu-xenial'
                          'ubuntu-trusty'
                          'ubuntu-precise')

declare -ar all_tests=('simple-project'
                       'whitespace-project'
                       'node-deb-override-project')

fail() {
    printf '\n\033[31;1mTest failed!\033[0m\n\n'
}

trap 'fail' EXIT

cur_dir="$(dirname $(readlink -f $0))"
declare -r cur_dir

print_yellow() {
    printf "\033[33;1m$@\033[0m\n\n"
}

print_green() {
    printf "\033[32;1m$@\033[0m\n\n"
}

print_divider() {
    printf "\033[34;1m--------------------------------------------\033[0m\n"
}

print_yellow 'Running generic checks (no docker)'
print_divider

print_yellow 'Running CLI checks'
PAGER=cat ./node-deb --help           > /dev/null
PAGER=cat ./node-deb --show-readme    > /dev/null
PAGER=cat ./node-deb --show-changelog > /dev/null
print_green 'CLI check success'

print_divider

for tst in "${all_tests[@]}"; do
  for image in "${all_versions[@]}"; do
    print_yellow "Running test $tst for image $image"
    docker run --rm \
               --volume "$cur_dir:/src" \
               --workdir '/src' \
               "heartsucker/node-deb-test:$image" \
               "/src/test/$tst/test.sh"
    print_green "Success for test $test for image $image"
    print_divider
  done
done

# clear the trap
trap - EXIT
trap

print_green 'Success!'
