#!/bin/ash

USR="martin"
REPLY=""
RET=""
PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "

if [[ ! -z $1 ]]; then USR=$1; fi
HDIR="/home/${USR}"


#=============================
# Setup Alpine Repositories
#=============================
RET=$( cat /etc/apk/repositories | grep -c 'http://mirror.dst.ca' )
if [ ${RET} == 0 ]; then
    printf "\n\n================= Setting Up APK Repositories ==============\n\n"
    mv /etc/apk/repositories /etc/apk/repositories.bak
    touch /etc/apk/repositories
	echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories
	echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories
	echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories
	echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories
	echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories
	
    #echo 'http://mirror.dst.ca/alpine/latest-stable/main' >> /etc/apk/repositories
    #echo 'http://mirror.dst.ca/alpine/latest-stable/community' >> /etc/apk/repositories
    #echo 'http://mirror.dst.ca/alpine/edge/main' >> /etc/apk/repositories
    #echo 'http://mirror.dst.ca/alpine/edge/community' >> /etc/apk/repositories
    #echo '#http://mirror.dst.ca/alpine/edge/testing' >> /etc/apk/repositories
fi

#=============================
#  Update the system
#=============================
printf "\n\n================= Updating ALPINE System ==============\n\n"
apk update
apk upgrade
apk add sudo bash bash-completion nano wget curl unzip

#=============================
#  Setup SUDO for Users
#=============================
if [ ! -f /etc/sudoers.d/wheel ]; then
   printf "\n\n================= Adding Wheel Group ==============\n\n"
   echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
fi

#=============================
#  Add User to System
#=============================
if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') != 1 ]; then
    printf "\n\n================= Adding ${USR} to System ==============\n\n"
    adduser ${USR}
fi

#================================
#  Add User to Wheel/Sudo Group
#================================
if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') == 1 ]; then
    printf "\n\n================= Adding ${USR} to Sudo Group ==============\n\n"
    if [ $(id -nG ${USR} 2>/dev/null | grep -c 'wheel') != 1 ]; then adduser ${USR} wheel; fi
fi

#=============================
# Update Terminal Profile
#=============================
RET=$( cat /etc/profile | grep -c 'PS1="\[\033}' )
if [ ${RET} == 0 ]; then
   printf "\n\n================= Updating Terminal Profile for ${USR} ==============\n\n"
   echo "PS1='${PS1}'" >> /etc/profile
   echo "export PS1" >> /etc/profile
fi

#=============================
# Remove MOTD
#=============================
if [ -f /etc/motd ]; then
   printf "\n\n================= Removing MOTD ==============\n\n"
   rm /etc/motd
fi

#===============================
#  Add Flatpak Package Manager
#===============================
VAL=$(apk list -I "flatpak" 2>/dev/null | grep -c "flatpak")
if [[ $VAL == 0 ]]; then
  printf "Install Flatpak [y/N]: "
  read -n 1 REPLY
  if [[ ${REPLY} == "" ]]; then REPLY="N"; fi
  if [[ ${REPLY} == "y" ]]; then REPLY="Y"; fi
  if [[ ${REPLY} == "Y" ]]; then 
     printf "\n\n================= Installing Flatpak Package Manager ==============\n\n"
     apk add flatpak
     flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'  
  fi
fi

#==================================
# Downloading the required scripts
#==================================
if [[ ! -d /$HDIR/scripts ]]; then
  printf "Install Scripts [y/N]: "
  read -n 1 REPLY
  if [[ ${REPLY} == "" ]]; then REPLY="N"; fi
  if [[ ${REPLY} == "y" ]]; then REPLY="Y"; fi
  if [[ ${REPLY} == "Y" ]]; then
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

      chown -R ${USR}:${USR} /$HDIR/scripts
      chmod +x /$HDIR/scripts/*.sh
  fi
fi

printf "Reboot System [Y/n]: "
read -n 1 REPLY
if [[ ${REPLY} == "" ]]; then REPLY="Y"; fi
if [[ ${REPLY} == "y" ]]; then REPLY="Y"; fi
if [[ ${REPLY} == "Y" ]]; then reboot; fi
