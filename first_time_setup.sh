#!/bin/bash

# this file only needs to be run once on a given machine, after that, you
# only need to build the docker images and run them

# this is the standard install process recommended by the docker team
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# allow running w/o root
sudo groupadd docker
sudo usermod -aG docker $USER

# this allows for user-mode access from the container to the USRP hardware via USB
tar xvf src/udev_rules.tar.gz
sudo mv ./*.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
# now add the groups referenced by the rules files
sudo groupadd usrp
sudo usermod -aG usrp $USER
sudo sh -c "echo '@usrp\t-\trtprio\t99' >> /etc/security/limits.conf"
sudo groupadd plugdev
sudo usermod -aG plugdev $USER

# this kernel setting is shared with the docker clients
sudo sysctl -w kernel.shmmax=2147483648

echo ""
echo "**********************************************************************"
echo "NOTE: YOU MUST REBOOT BEFORE YOU CAN BUILD AND RUN THESE CONTAINERS!!!"
echo "**********************************************************************"
