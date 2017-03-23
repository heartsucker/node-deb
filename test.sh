#!/bin/bash
set -e

declare -ar all_versions=('debian-stretch'
                          'debian-jessie'
                          'debian-wheezy'
                          'ubuntu-xenial'
                          'ubuntu-trusty'
                          'ubuntu-precise')

declare -ar all_tests=('simple-project'
                       'whitespace-project')

cur_dir="$(dirname $(readlink -f $0))"
declare -r cur_dir

# TODO colorize output, add breaks between tests, make it readable for humans

echo 'Running generic checks (no docker)'
echo 'Running CLI checks'
PAGER=cat ./node-deb --help           > /dev/null
PAGER=cat ./node-deb --show-readme    > /dev/null
PAGER=cat ./node-deb --show-changelog > /dev/null
echo 'Done running generic checks'

for tst in "${all_tests[@]}"; do
  for image in "${all_versions[@]}"; do
    docker run --rm \
               --volume "$cur_dir:/src" \
               --workdir '/src' \
               "heartsucker/node-deb-test:$image" \
               "/src/test/$tst/test.sh"
  done
done
