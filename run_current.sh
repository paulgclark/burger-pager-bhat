#!/bin/bash

name=`basename $PWD`

function print_usage {
  echo "Container Usage: "
  echo "  ./run_container"
  echo ""
  echo "  NOTE: No command line options are used. This scripts is a CLI to the container."
  exit
}

# permissions for USB
xhost +
XAUTH=/tmp/.docker.xauth
sudo touch $XAUTH
xauth nlist | sed -e 's/^..../ffff/' | sudo xauth -f $XAUTH nmerge -

# shared volume with container
share_str="-v `pwd`/share:/home/sdr/share"
# make share directory if it doesn't already exist
mkdir -p share

# main execution string
docker_arg_str="docker run -it --privileged --ipc=host --net=host -e DISPLAY=$DISPLAY -v $XAUTH:$XAUTH -e XAUTHORITY:$XAUTH -v /dev/bus/usb:/dev/bus/usb"

# run with all execution strings
bash -c "$docker_arg_str $share_str $name"
