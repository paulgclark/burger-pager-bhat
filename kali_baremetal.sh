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
uhd_images_downloader -t b2xx_b200_fpga_default b2xx_b200mini_fpga_default b2xx_common_fw_default

# install urh
pipx install urh
pipx ensurepath

# fix numpy issue
pipx runpip urh install numpy==1.26.4
pipx runpip urh install setuptools

