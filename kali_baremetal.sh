#!/usr/bin/bash

# update system and install prereqs
sudo apt update
sudo apt -y upgrade
sudo apt install -y libuhd-dev uhd-host
sudo cp /usr/libexec/uhd/utils/uhd-usrp.rules /etc/udev/rules.d/.
sudo udevadm control --reload-rules

# install urh
pipx install urh
pipx ensurepath

# fix numpy issue
pipx runpip urh install numpy==1.26.4
pipx runpip urh install setuptools

echo "Installation complete. Please reboot before continuing..."
