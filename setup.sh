#!/bin/bash

list="adb anydesk apktool deskreen discord fastboot freedownloadmanager g++-aarch64-linux-gnu gcc-aarch64-linux-gnu \
		gdb-multiarch gnome-shell-extension-gsconnect gnome-tweaks google-chrome-stable gparted lm-sensors neofetch \
		openjdk-17-jre openjdk-17-jdk openmpi-bin openmpi-common patchelf python2.7 python3-pip python3-tk python-is-python3 \
		scenebuilder scrcpy screen snapd speedtest-cli squashfs-tools teamviewer telegram-desktop typora wireshark \
		zram-config zsh"
aliases=$(cat aliases)

# Setting up git
sudo apt install git -y
git config --global user.name "Giovix92"
git config --global user.email "ggualtierone@gmail.com"
git config --global review.review.lineageos.org.username "Giovix92"

# Setting up android build env
git clone https://github.com/akhilnarang/scripts
bash scripts/setup/android_build_env.sh

# Install programs
sudo apt install $list -y

# Add the Gerrit Change-id hook
mkdir -p ~/.git/hooks
git config --global core.hooksPath ~/.git/hooks
curl -Lo ~/.git/hooks/commit-msg https://review.lineageos.org/tools/hooks/commit-msg
chmod u+x ~/.git/hooks/commit-msg

# Add custom zsh aliases
sudo chsh --shell /usr/bin/zsh
echo $aliases >> /home/giovix92/.zshrc
