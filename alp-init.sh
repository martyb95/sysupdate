#!/bin/ash

USR="martin"
if [[ ! -z $1 ]]; then USR=$1; fi
HDIR="/home/${USR}"

#=============================
# Setup Alpine Repositories
#=============================
RET=$( cat /etc/apk/repositories | grep -c 'uwaterloo.ca/alpine/edge/community' )
if [ ${RET} == 0 ]; then
    printf "\n\n================= Setting Up APK Repositories ==============\n\n"
    mv /etc/apk/repositories /etc/apk/repositories.bak
    touch /etc/apk/repositories
    echo 'http://mirror.dst.ca/alpine/latest-stable/main' >> /etc/apk/repositories
    echo 'http://mirror.dst.ca/alpine/latest-stable/community' >> /etc/apk/repositories
    echo '#http://mirror.dst.ca/alpine/edge/main' >> /etc/apk/repositories
    echo '#http://mirror.dst.ca/alpine/edge/community' >> /etc/apk/repositories
    echo '#http://mirror.dst.ca/alpine/edge/testing' >> /etc/apk/repositories
fi

#=============================
#  Setup SUDO for Users
#=============================
printf "\n\n================= Updating ALPINE System ==============\n\n"
apk update
apk upgrade
apk add sudo bash bash-completion nano wget xz curl shadow unzip git dmidecode
if [ ! -f /etc/sudoers.d/wheel ]; then
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
fi

#=============================
#  Add User to Wheel Group
#=============================
if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') = 1 ]; then
    printf "\n\n================= Adding ${USR^^} to Sudo Group ==============\n\n"
    if [ $(id -nG ${USR} 2>/dev/null | grep -c 'wheel') = 1 ]; then  adduser ${USR} wheel; fi
fi

#===============================
#  Add Flatpak Package Manager
#===============================
VAL=$(apk list -I "flatpak" 2>/dev/null | grep -c "flatpak")
if [[ $VAL == 0 ]]; then
  printf "\n\n================= Installing Flatpak Package Manager ==============\n\n"
  apk add flatpak
  flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'
fi

#==================================
# Downloading the required scripts
#==================================
if [[ ! -d /$HDIR/scripts ]]; then
  printf "\n\n================= Downloading scripts to /$HDIR/scripts/ ==============\n\n"
  mkdir /$HDIR/scripts/
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
