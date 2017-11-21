#!/bin/bash
set -e

declare -ar all_images=('debian-stretch'
                        'debian-jessie'
                        'debian-wheezy'
                        'ubuntu-xenial'
                        'ubuntu-trusty')

# TODO wheezy doesn't have a good upstat image
declare -ar upstart_images=('ubuntu-trusty')

# TODO debian doesn't have nice images for this
declare -ar systemd_images=('ubuntu-xenial')

# TODO why doesn't this work in jessie / xenial?
declare -ar sysv_images=('debian-stretch'
                         'debian-wheezy'
                         'ubuntu-trusty')

declare -ar all_tests=('simple'
                       'whitespace'
                       'node-deb-override'
                       'commandline-override'
                       'extra-files'
                       'no-init'
                       'no-default-dependencies'
                       'real-app'
                       'real-cli')

declare -ar simple_tests=('dog-food'
                          'npm-install')

print_yellow() {
    printf "\033[33;1m%s\033[0m\n\n" "$*"
}

print_green() {
    printf "\033[32;1m%s\033[0m\n\n" "$*"
}

print_divider() {
    printf "\033[34;1m--------------------------------------------\033[0m\n"
}

usage() {
  # Local var because of grep
  declare helpdoc='HELP'
  helpdoc+='DOC'

  echo 'Usage: test.sh [opts]'
  echo 'Opts:'
  grep "$helpdoc" "$0" -B 1 | egrep -v '^--$' | sed -e 's/^  //g' -e "s/# $helpdoc: //g"
}

while [ -n "$1" ]; do
  param="$1"
  value="$2"

  case $param in
    --distribution | -d)
      # HELPDOC: The distro to test. Blank == all.
      distro="$value"
      shift
      ;;
    --help | -h)
      # HELPDOC: Print this message then exit.
      usage
      exit 0
      ;;
    --test | -t)
      # HELPDOC: The test to run. Blank == all.
      test_name="$value"
      shift
      ;;
    *)
      echo "Unnown argument: $param"
      usage
      exit 1
      ;;
  esac
  shift
done

# if we're in TravisCI land, and we've updated the docker images then rebuild them so the tests match
if [ -n "$TRAVIS_BRANCH" ]; then
  # we have to fetch because travis pulls the current branch only by default
  declare build_head=$(git rev-parse HEAD)
  git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
  git fetch
  git checkout -qf develop
  git checkout "$build_head"

  if [ -n "$(git diff --name-only develop -- docker)" ]; then
    ./docker/docker.sh
  fi
fi

fail() {
    printf '\n\033[31;1mTest failed!\033[0m\n\n'
}

trap 'fail' EXIT


for tst in "${all_tests[@]}"; do
  if [[ "$tst" != "${test_name:-$tst}" ]]; then continue; fi

  for image in "${all_images[@]}"; do
    if [[ "$image" != "${distro:-$image}" ]]; then continue; fi

    print_yellow "Running test $tst for image $image"
    docker run --rm \
               --volume "$PWD:/src" \
               --workdir '/src' \
               "heartsucker/node-deb-test:$image" \
               "/src/test/$tst/test.sh"
    print_green "Success for test $tst for image $image"
    print_divider
  done
done

for image in "${systemd_images[@]}"; do
  if [[ 'systemd' != "${test_name:-systemd}" ]]; then continue; fi
  if [[ "$image" != "${distro:-$image}" ]]; then continue; fi

  print_yellow "Running systemd test for image $image"
  name="$image-node-deb"

  docker rm -f "$name" || echo 'container not removed'

  docker run --volume "$PWD:/src" \
             --workdir '/src' \
             --name "$name" \
             --detach \
             --privileged \
             --volume /:/host \
             "heartsucker/node-deb-test:$image" \
             '/sbin/init'
  docker start "$name"
  docker exec "$name" \
              '/src/test/systemd-app/test.sh'
  docker rm -f "$name"

  # TODO add trap that kills the container

  print_green "Success for systemd test for image $image"
  print_divider
done

for image in "${upstart_images[@]}"; do
  if [[ 'upstart' != "${test_name:-'upstart'}" ]]; then continue; fi
  if [[ "$image" != "${distro:-$image}" ]]; then continue; fi

  print_yellow "Running upstart test for image $image"
  name="$image-node-deb"

  docker rm -f "$name" || echo 'container not removed'

  docker run --volume "$PWD:/src" \
             --workdir '/src' \
             --name "$name" \
             --detach \
             "heartsucker/node-deb-test:$image" \
             '/sbin/init'
  docker start "$name"
  docker exec "$name" \
              '/src/test/upstart-app/test.sh'
  docker rm -f "$name"

  # TODO add trap that kills the container

  print_green "Success for upstart test for image $image"
  print_divider
done

for image in "${sysv_images[@]}"; do
  if [[ 'sysv' != "${test_name:-sysv}" ]]; then continue; fi
  if [[ "$image" != "${distro:-$image}" ]]; then continue; fi

  print_yellow "Running sysv test for image $image"
  name="$image-node-deb"

  docker run --rm \
             --volume "$PWD:/src" \
             --workdir '/src' \
             --name "$name" \
             "heartsucker/node-deb-test:$image" \
             '/src/test/sysv-app/test.sh'

  print_green "Success for sysv test for image $image"
  print_divider
done

for tst in "${simple_tests[@]}"; do
  if [[ "$tst" != "${test_name:-$tst}" ]]; then continue; fi

  for image in "${all_images[@]}"; do
    if [[ "$image" != "${distro:-$image}" ]]; then continue; fi

    print_yellow "Running simple test $tst for image $image"
    docker run --rm \
               --volume "$PWD:/src" \
               --workdir '/src' \
               "heartsucker/node-deb-test:$image" \
               "/src/test/$tst.sh"
    print_green "Success for test $tst for image $image"
    print_divider
  done
done

# clear the trap so we don't print the fail message
trap - EXIT
trap

print_green 'Success!'
