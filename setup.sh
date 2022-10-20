#!/bin/bash

list="adb anydesk apktool deskreen discord fastboot freedownloadmanager g++-aarch64-linux-gnu gcc-aarch64-linux-gnu \
		gdb-multiarch gnome-shell-extension-gsconnect gnome-tweaks google-chrome-stable gparted lm-sensors neofetch \
		openjdk-17-jre openjdk-17-jdk openmpi-bin openmpi-common patchelf python2.7 python3-pip python3-tk python-is-python3 \
		scenebuilder scrcpy screen snapd speedtest-cli squashfs-tools teamviewer telegram-desktop typora wireshark \
		zram-config zsh"
aliases=$(cat aliases)

echo "- Setting up Git..."
sudo apt install git -y
git config --global user.name "Giovix92"
git config --global user.email "ggualtierone@gmail.com"
git config --global review.review.lineageos.org.username "Giovix92"

echo "- Installing Android build binaries..."
git clone https://github.com/akhilnarang/scripts
bash scripts/setup/android_build_env.sh

clear
echo "- Installing personal programs..."
sudo apt install $list -y

clear
echo "- Adding custom zsh aliases..."
chsh --shell /usr/bin/zsh
echo $aliases >> /home/giovix92/.zshrc

echo "- Done!"