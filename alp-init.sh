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
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories
    echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories
fi

#=============================
#  Setup SUDO for Users
#=============================
printf "\n\n================= Updating ALPINE System ==============\n\n"
apk update
apk upgrade
apk add sudo bash bash-completion nano wget xz curl shadow unzip
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
  apk add flatpak git
  flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'
fi

#===============================
#  Add NIX Package Manager
#===============================
if [[ ! -d /nix/store ]]; then
   printf "\n\n================= Installing NIX Package Manager ==============\n\n"
   wget -q https://nixos.org/nix/install
   sed -i s'#curl --fail -L#curl --fail -s -L#' install
   sed -i s'#{ wget #{ wget -q #' install
   sh install --daemon --yes
   rm -f /etc/init.d/nix-daemon
   touch /etc/init.d/nix-daemon
   echo '#!/sbin/openrc-run' >> /etc/init.d/nix-daemon
   echo 'description="Nix multi-user support daemon"' >> /etc/init.d/nix-daemon
   echo ' ' >> /etc/init.d/nix-daemon
   echo 'command="/usr/sbin/nix-daemon"' >> /etc/init.d/nix-daemon
   echo 'command_background="yes"' >> /etc/init.d/nix-daemon
   echo 'pidfile="/run/$RC_SVCNAME.pid"' >> /etc/init.d/nix-daemon
   chmod a+rx /etc/init.d/nix-daemon
   cp /root/.nix-profile/bin/nix-daemon /usr/sbin
   rc-update add nix-daemon
   rc-service nix-daemon start
   adduser ${USR} nixbld
   rm -f install
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
