#!/bin/bash
set -e
set -u

cd "$(dirname $0)"

declare -ar images=('debian-wheezy'
                    'debian-jessie'
                    'debian-stretch'
                    'ubuntu-precise'
                    'ubuntu-trusty'
                    'ubuntu-xenial')

declare -r node_dl='./node.tar.xz'
declare -r node_out='./node'

if [ ! -f "$node_dl" ]; then
  curl 'https://nodejs.org/dist/v6.10.1/node-v6.10.1-linux-x64.tar.xz' >> "$node_dl"
fi

if [ ! -d  "$node_out" ]; then
  tar -xJf "$node_dl"
  mv 'node-v6.10.1-linux-x64' "$node_out"
fi

for image in ${images[@]}; do
  docker build -t heartsucker/node-deb-test:$image -f $image .
done

for image in ${images[@]}; do
  : docker push heartsucker/node-deb-test:$image
done
