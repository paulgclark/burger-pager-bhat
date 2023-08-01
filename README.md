# BHUSA 2023 Arsenal Lab

## Install Instructions
The first step is to untar the bundle, which you must
already have done if you're reading this!

The directory created by this untar process has a few
BASH scripts. If you have not previously run or installed
this software on your machine, change to the burger-pager
directory and run this first:
```
cd burger-pager  # if not already here
./first_time_setup.sh  # you will be asked for your password
```

Next you will need to reboot your machine (Docker's fault). After
that, you must build the Docker container with:
```
cd burger-pager
./build_current.sh
```

This will take a few minutes. To run the container:
```
./run_current.sh
```
after running this last script, you will have terminal access
to the container. Within this window, you should check that you can
run both Universal Radio Hacker and GNU Radio Companion:
```
urh
# and also try
gnuradio-companion
```


