#!/bin/bash

### Base ###
menu() {
	echo """
╔═══════════════════════════╗
║                           ║
║ Giovix92's dotfiles setup ║
║                           ║
╚═══════════════════════════╝
"""
}

init() {
	list=""
}

error() {
	echo "[!!!] Something happened while setting up $1. Aborting."
	exit 1
}

### Various setups ###
setup_anydesk() {
	wget -qO- https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor > anydesk.gpg
	sudo install -D -o root -g root -m 644 anydesk.gpg /etc/apt/keyrings/anydesk.gpg
	sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list'
	rm -f anydesk.gpg
}

setup_vscode() {
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt install apt-transport-https
}

setup_fdm() {
	wget -q https://dn3.freedownloadmanager.org/6/latest/freedownloadmanager.deb
	sudo apt install ./freedownloadmanager.deb
	rm -f freedownloadmanager.deb
	sudo apt-key export 093B2149 | sudo gpg --yes --dearmour -o /etc/apt/trusted.gpg.d/freedownloadmanager.gpg
}

setup_typora() {
	wget -qO- https://typora.io/linux/public-key.asc | gpg --dearmor > typora.gpg
	sudo install -D -o root -g root -m 644 typora.gpg /usr/share/keyrings/typora.gpg
	sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/typora.gpg] https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list'
	rm -f typora.gpg
}

setup_git() {
	git config --global user.name "Giovix92"
	git config --global user.email "ggualtierone@gmail.com"
	git config --global review.review.lineageos.org.username "Giovix92"
}

setup_android_build_env() {
	git clone https://github.com/akhilnarang/scripts tmp/
	gnome-terminal --wait -- ./tmp/setup/android_build_env.sh
	rm -rf tmp/
}

setup_apps() {
	gnome-terminal --wait -- bash -c 'sudo apt update && sudo apt -f install $(cat app_list) -y'
}

setup_gerrit_changeid_hook() {
	[ -d ~/.git/hooks ] && return 0
	mkdir -p ~/.git/hooks
	git config --global core.hooksPath ~/.git/hooks
	curl -Lo ~/.git/hooks/commit-msg https://review.lineageos.org/tools/hooks/commit-msg
	chmod u+x ~/.git/hooks/commit-msg
}

extras() {
	cp aliases ~/.bash_aliases

	# Prevent Windows time shifting
	timedatectl set-local-rtc 1

	# HACK: Set gnome-remote-desktop screen sharing mode to extend
	gsettings set org.gnome.desktop.remote-desktop.rdp screen-share-mode extend

	# HACK: Use OMEN key as fan switching shortcut.
	# See https://github.com/Giovix92/dotfiles/blob/master/scripts/switchfanmode.
	# Also, let it run as sudo.
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "OMEN Key"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "bash /home/giovix92/dotfiles/scripts/switchfanmode"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "XF86Launch2"
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

	[ ! -f "/etc/sudoers.d/switchfanmode" ] && echo "giovix92 ALL = NOPASSWD: /bin/bash /home/giovix92/dotfiles/scripts/switchfanmode" | sudo tee /etc/sudoers.d/switchfanmode
}

clear
init
menu
echo "[i] Setting up AnyDesk..."; setup_anydesk > /dev/null 2>&1 || error "AnyDesk"
echo "[i] Setting up VSCode..."; setup_vscode > /dev/null 2>&1 || error "VSCode"
echo "[i] Setting up FDM..."; setup_fdm > /dev/null 2>&1 || error "FDM"
echo "[i] Setting up Typora..."; setup_typora > /dev/null 2>&1 || error "Typora"
echo "[i] Setting up Git..."; setup_git > /dev/null 2>&1 || error "Git"
echo "[i] Setting up Android build env..."; setup_android_build_env > /dev/null 2>&1 || error "android build env"
echo "[i] Setting up Apps..."; setup_apps > /dev/null 2>&1 || error "apps"
echo "[i] Setting up Gerrit changeid hook..."; setup_gerrit_changeid_hook > /dev/null 2>&1 || error "Gerrit changeid hook"
echo "[i] Finishing..."; extras || error "extras"

read -p "[i] Finished! Press a key to exit."
exit
