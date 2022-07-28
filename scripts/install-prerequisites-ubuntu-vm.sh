#!/usr/bin/env bash
# ----------------------------------------------------------------------------------------
# Copyright (c) William Berry
# email: wberry.cpp@gmail.com
# github: https://github.com/wsberry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may freely use this source code and its projects in compliance with the License.
#
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License src distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------------

clear

sudo apt-get update

if [[ ! -e "./.essentials-installed" ]];
then
  sudo apt-get install build-essential gcc make perl dkms curl
  touch "./.essentials-installed"
  reboot
if

# Check that the VBoxGuestAdditions is mounted:
#
if [[ ! -f /media/$USER/VBox_GAs*/VBoxLinuxAdditions.run ]]; then
  echo -e "\n  Missing VM 'VBoxGuestAdditions.iso'.\n  Add this ISO using the VirtualBox VM mannager.\n  See: 'Settings/Storage' 'Controller: IDE Controller'.\n\n"
else
  sudo /media/$USER/VBox_GAs*/VBoxLinuxAdditions.run
fi

sudo usermod -aG vboxsf $USER
sudo apt-get install git
sudo apt-get install cmake-qt-gui
sudo apt-get install firefox
sudo apt-get install catfish
sudo apt install ca-certificates

# Beyond Compare (30 days of use without license):
#
wget https://www.scootersoftware.com/bcompare-4.4.1.26165_amd64.deb
sudo apt install ./bcompare-4.4.1.26165_amd64.deb

# CLion File Scanner Config...
#
sudo snap install clion --classic
sudo chmod 777 /etc/sysctl.conf
echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf
sudo sysctl -p --system

#sudo apt-get autoclean autoremove

echo -e "\n\n  Done!\n\n  You will need to restart your System before all the updates take effect!\n\n"
