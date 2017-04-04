#!/bin/bash
set -e

declare -ar all_images=('debian-stretch'
                        'debian-jessie'
                        'debian-wheezy'
                        'ubuntu-xenial'
                        'ubuntu-trusty'
                        'ubuntu-precise')

# TODO wheezy doesn't have a good upstat image
# TODO precise breaks for... some reason?
declare -ar upstart_images=('ubuntu-trusty')

# TODO debian doesn't have nice images for this
declare -ar systemd_images=('ubuntu-xenial')

# TODO why doesn't this work in jessie / xenial?
declare -ar sysv_images=('debian-stretch'
                         'debian-wheezy'
                         'ubuntu-trusty'
                         'ubuntu-precise')

declare -ar all_tests=('simple'
                       'whitespace'
                       'node-deb-override'
                       'commandline-override'
                       'extra-files'
                       'redirect'
                       'no-init'
                       'real-app')

declare -ar simple_tests=('dog-food'
                          'npm-install')

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

for tst in "${all_tests[@]}"; do
  for image in "${all_images[@]}"; do
    print_yellow "Running test $tst for image $image"
    docker run --rm \
               --volume "$cur_dir:/src" \
               --workdir '/src' \
               "heartsucker/node-deb-test:$image" \
               "/src/test/$tst/test.sh"
    print_green "Success for test $tst for image $image"
    print_divider
  done
done

for image in "${systemd_images[@]}"; do
  print_yellow "Running systemd test for image $image"
  name="$image-node-deb"

  docker rm -f "$name" || echo 'container not removed'

  docker run --volume "$cur_dir:/src" \
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
  print_yellow "Running upstart test for image $image"
  name="$image-node-deb"

  docker rm -f "$name" || echo 'container not removed'

  docker run --volume "$cur_dir:/src" \
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
  print_yellow "Running sysv test for image $image"
  name="$image-node-deb"

  docker run --rm \
             --volume "$cur_dir:/src" \
             --workdir '/src' \
             --name "$name" \
             "heartsucker/node-deb-test:$image" \
             '/src/test/sysv-app/test.sh'

  print_green "Success for sysv test for image $image"
  print_divider
done

for tst in "${simple_tests[@]}"; do
  for image in "${all_images[@]}"; do
    print_yellow "Running simple test $tst for image $image"
    docker run --rm \
               --volume "$cur_dir:/src" \
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
