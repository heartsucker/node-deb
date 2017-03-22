#!/bin/bash
set -e
set -u

declare -ar images=('debian-wheezy'
                    'debian-jessie'
                    'debian-stretch'
                    'ubuntu-precise'
                    'ubuntu-trusty'
                    'ubuntu-xenial')

for image in ${images[@]}; do
  docker build -t heartsucker/node-deb-test:$image $image
done

for image in ${images[@]}; do
  : #docker push heartsucker/node-deb-test:$image
done
