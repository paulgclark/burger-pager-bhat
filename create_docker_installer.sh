#!/usr/bin/bash -x

# get version number
source version.sh

# make temp installer directory
rm -f burger-pager
mkdir -p burger-pager

# do a bunch of stuff inside the burger-pager directory
(
cd burger-pager || exit

# add files for the host
cp ../build_current.sh .
cp ../Dockerfile .
cp ../first_time_setup.sh .
cp ../run_current.sh .
cp ../README.md .

# now create an archive for the container files
rm -f xfr_files.tar.gz
mkdir xfr_files
cp ../burger-tutorial.txt xfr_files/.
cp ../py/*.py xfr_files/.
cp ../py/*.grc xfr_files/.
cp ../py/*.txt xfr_files/.
cp ../urh_files/* xfr_files/.
tar -czf xfr_files.tar.gz xfr_files
rm -rf xfr_files
)

# build top-level installer
tar -czf burger-pager-v$version.tar.gz burger-pager

# cleanup
rm -rf burger-pager
