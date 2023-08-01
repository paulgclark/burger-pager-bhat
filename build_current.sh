#!/bin/bash 

# process arg
if [ -z "$1" ]; then
	clean_str=""
elif [ "$1" == "clean" ]; then
	clean_str="clean"
else
	echo "Usage: ./build_current.sh"
	echo "       ./build_current.sh clean"
	echo ""
	echo "Builds the container defined in the current directory"
	exit 0
fi

# build the container

name=$(basename "$PWD")
docker build $clean_str -t "$name" .

# clean up

