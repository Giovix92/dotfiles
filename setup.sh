#!/bin/bash

install_brew_prerequisites() {
  echo "- Checking Xcode CLI tools"
  # Only run if the tools are not installed yet
  # To check that try to print the SDK path
  xcode-select -p &> /dev/null
  if [ $? -ne 0 ]; then
    echo "- Xcode CLI tools not found. Installing them..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l |
      grep "\*.*Command Line" |
      tail -n 1 | sed 's/^[^C]* //')
      echo "Prod: ${PROD}"
    softwareupdate -i "$PROD" --verbose;
  else
    echo "- Xcode CLI tools installed! Proceeding..."
  fi
}

install_brew() {
  URL_BREW="https://raw.githubusercontent.com/Homebrew/install/master/install"
  echo -n "- Installing brew ... "
  echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2&>1
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

install_brew_packages() {
  for i in $@; do
    echo -n "- Installing $i ... "
    # Treat it as a non-cask package
    brew install $i > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      echo "Done!"
    else
      echo "Failed, or already installed."
    fi
  done
}

install_brew_cask_packages() {
  for i in $@; do
    echo -n "- Installing $i ... "
    # Treat it as a cask package
    brew install --cask $i > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      echo "Done!"
    else
      echo "Failed, or already installed."
    fi
  done
}

export CI=1
VERSION="1.0"
echo "- Giovix92's dotfiles setup, v$VERSION."

# Check installed OS
if [ "$(command -v sw_vers)" != "" ]; then
  OS_TYPE=$(sw_vers -productName)
  OS_VER=$(sw_vers -productVersion)
  IS_LINUX=false
elif [ "$(command cat /etc/*-release)" != "" ]; then
  source /etc/*-release
  OS_TYPE=$NAME
  OS_VER=$VERSION
  IS_LINUX=true
else
  echo "- Can't determine the OS type. Aborting."
  exit 1
fi

echo "- Detected os: $OS_TYPE $OS_VER"

if ! $IS_LINUX; then
  install_brew_prerequisites
  if install_brew; then 
    echo "Installed!"
  else 
    echo "Failed brew installation. Exiting."
    exit 1
  fi
  install_brew_cask_packages google-chrome sublime-text anydesk visual-studio-code typora vmware-fusion discord whatsapp telegram-desktop microsoft-teams termius
  install_brew_packages python@3.9 python@3.10 repo brotli dos2unix git openssl cmake htop automake unrar p7zip xz thefuck doxygen binutils zlob aria2 ffmpeg gnupg ngrep gcc protobuf ssh-copy-id e2fsprogs ext4fuse
else
  echo "TBD"
fi

# Setup Git
echo -n "- Setting up Git ... "
git config --global user.name "Giovix92"
git config --global user.email "ggualtierone@gmail.com"
git config --global review.review.lineageos.org.username "Giovix92"
echo "Done!"

# Add the Gerrit Change-id hook - from https://github.com/SebaUbuntu/dotfiles/blob/master/setup.sh#L50
echo -n "- Setting up Gerrit Change-Id hook ... "
mkdir -p ~/.git/hooks
git config --global core.hooksPath ~/.git/hooks
cp commit-msg ~/.git/hooks/commit-msg
chmod u+x ~/.git/hooks/commit-msg
echo "Done!"
