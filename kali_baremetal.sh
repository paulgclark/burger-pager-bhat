#!/usr/bin/bash

# install prereqs
sudo apt update
#sudo apt -y upgrade
sudo apt install -y pipx libuhd-dev uhd-host
# allow access to usrp in user mode
sudo cp /usr/libexec/uhd/utils/uhd-usrp.rules /etc/udev/rules.d/.
sudo udevadm control --reload-rules
sudo udevadm trigger
# get fpga images for b200
sudo uhd_images_downloader 

# install urh
pipx install urh
pipx ensurepath

# fix numpy issue
pipx runpip urh install numpy==1.26.4
pipx runpip urh install setuptools

echo "Install complete. Reboot and remember to rebuild your drivers in URH"
