#!/bin/bash

#  Brewfile has some rules.
# 1. The command line tool registered with Homebrew is "brew 'app-name'" (installed with the brew install command)
# 2. Command line tools that are not registered in Homebrew are "tap 'app-name'" (installed with the brew tap command)
# 3. Normal applications are "cask 'app-name'" (those installed using Homebrew Cask)
# 4. The app to install from the App Store is "mas 'app name' id:XX"
#  'brew cask' can be used if you install Homebrew, but 'mas' requires 'mas-cli' to be installed.

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"

# Define variables
BIN=$(cd $(dirname $0); pwd)
PARENT=$(cd $(dirname $0)/../; pwd)
INSTLOG="$BIN/install.log"
######

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null ; do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

wait_yn(){
    YN="xxx"
    while [ $YN != 'y' ] && [ $YN != 'n' ] ; do
        read -p "$1 [y/n]" YN
    done
}
######

clear

# give the user an option to exit out
wait_yn $'[\e[1;33mACTION\e[0m] - Would you like to start with the install?'
if [[ $YN = y ]] ; then
    echo -e "$CNT - Setup starting..."
else
    echo -e "$CNT - This script will now exit, no changes were made to your system."
    exit
fi

# Install CLI for Xcode
echo -en "$CNT - Now installing CLI for Xcode."
xcode-select --install &>> $INSTLOG
show_progress $!

# Install rosetta
wait_yn $'[\e[1;33mACTION\e[0m] - Would you like to install rosetta?'
if [[ $YN = y ]] ; then
    sudo softwareupdate --install-rosetta --agree-to-licensesudo softwareupdate --install-rosetta --agree-to-license &>> $INSTLOG
fi

# Install homebrew
if ! type brew &> /dev/null ; then
    echo -en "$CNT - Now installing Homebrew."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>> $INSTLOG
    show_progress $!
    echo -e "$COK - Installed."
else
    echo -e "$CNT - Since Homebrew is already installed, skip this phase and proceed."
fi

# brew path setting
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# Install app from Brewfile
wait_yn $'[\e[1;33mACTION\e[0m] - Would you like to install app from Brewfile?'
if [[ $YN = y ]] ; then
    brew bundle install --file $BIN/Brewfile &>> $INSTLOG
    echo -e "$COK - Installed."
fi

# Install custom app
wait_yn $'[\e[1;33mACTION\e[0m] - Would you like to install custom app?'
if [[ $YN = y ]] ; then
    cd
    git clone http://github.com/possatti/pokemonsay &>> $INSTLOG
    cd pokemonsay
    ./install.sh &>> $INSTLOG
    echo export \""PATH="\$PATH:/Users/$USER/bin\" >> ~/.zshrc

    echo -e "$COK - Installed."
fi

# Copy Config Files
wait_yn $'[\e[1;33mACTION\e[0m] - Would you like to copy config files?'
if [[ $YN = y ]] ; then
    echo -e "$CNT - Copying config files..."

    # copy the configs directory
    cp -rT $PARENT/. ~/ &>> $INSTLOG
    echo -e "$COK - Installed."
    ln -s ~/Documents ~/Documents-ln
    ln -s ~/Downloads ~/Downloads-ln
fi

# Enable services
yabai --start-service
skhd --start-service

brew bundle dump

# Script is done
echo -e "$CNT - Script had completed!"
