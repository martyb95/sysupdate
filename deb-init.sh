#!/bin/bash

# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then
   printf "\n\n*************** Please run as root ***************\n\n\n"
   exit 1
fi

# Update the system
apt-get update && apt-get upgrade -y && apt-get autoremove -y
# Install required software
apt-get install -y wget unzip dmidecode nano sudo

USR="martin"
if [[ ! -z $1 ]]; then USR=$1; fi

# Create new user & add to sudoers
adduser $USR
usermod -aG sudo $USR
HDIR="/home/${USR}"

#===============================
#  Add Flatpak Package Manager
#===============================
VAL=$(apk list -I "flatpak" 2>/dev/null | grep -c "flatpak")
if [[ $VAL == 0 ]]; then
  printf "\n\n================= Installing Flatpak Package Manager ==============\n\n"
  apt-get install -y flatpak
  flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'
fi

#==================================
# Downloading the required scripts
#==================================
if [[ ! -d /$HDIR/scripts ]]; then
  printf "\n\n================= Downloading scripts to /$HDIR/scripts/ ==============\n\n"
  mkdir -p /$HDIR/scripts/
  cd /$HDIR/scripts
  
  sURL="https://tinyurl.com/sys-src"
  wget -q $sURL
  if [[ ! -f sys-src ]]; then
     printf "\n\n********** Cannot find $URL *******\n\n\n";
     exit 1
  fi
  
  mv sys-src scripts.zip
  if [[ -f scripts.zip ]]; then unzip -o -q scripts.zip; fi
  rm -f scripts.zip
fi


if [[ ! -d /$HDIR/scripts ]]; then
   printf "\n\n********** Script Directory does NOT exist. *******\n\n\n";
   exit 1
else
   chown -R ${USR}:${USR} /$HDIR/scripts
   chmod +x /$HDIR/scripts/*.sh
fi

printf "OK to Reboot Now (y/n) [Y] "
read ANS
if [ -z $ANS ]; then ANS="Y"; fi
if [ $ANS == "Y" ]; then reboot; fi
