# Black Hat Arsenal Lab

## Native Install Process - Ubuntu/Kali
First, run the installer (you will need to enter your password):
```
./kali_baremetal.sh
```

Then create a working directory with the project files:
```
./refresh_kali.sh
```

You can then follow the instructions in the PDF file.

## Docker Install Process

### Creating the Docker installer
If you have a tar.gz file already, you can ignore this
step. If not, create the installer with:
./create_docker_installer.sh

### Install Instructions - Docker
The first step is to untar the bundle, which you may
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


