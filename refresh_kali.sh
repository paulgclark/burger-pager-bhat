#!/usr/bin/bash

proj_dir="$HOME"/burger-pager-working
gold_dir="$HOME"/burger-pager-bhat

# delete existing directory if there
if [ -d "$proj_dir" ]; then
  rm -rf "$proj_dir"
fi

# create working directory and copy files
mkdir "$proj_dir"
cp "$gold_dir"/urh_files/capture_467M_s1M.complex "$proj_dir"/.
cp "$gold_dir"/urh_files/lsr.proto.xml "$proj_dir"/.
cp "$gold_dir"/instructions.pdf "$proj_dir"/.

# change to working directory and start urh
cd "$proj_dir" || exit
urh
