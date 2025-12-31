#!/bin/ash

#=========================================================
#      Color Codes
#=========================================================
RESTORE='\033[0m'
BLACK='\033[00;30m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;93m'
BROWN='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
WHITE='\033[01;97m'
LGRAY='\033[00;37m'
LRED='\033[01;91m'
LGREEN='\033[01;92m'
LYELLOW='\033[01;93m'
LBLUE='\033[01;94m'
LPURPLE='\033[01;95m'
LCYAN='\033[01;96m'
OVERWRITE='\e[1A\e[K'

USR="martin"
REPLY=""
RET=""
PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "

if [[ ! -z $1 ]]; then USR=$1; fi
HDIR="/home/${USR}"


function _AskYN(){
  REPLY=""
  while [[ -z ${REPLY} ]]
  do
    printf "${LGREEN}${1}? ${YELLOW}[${2}]: ${RESTORE}"
    read -n 1 REPLY
    if [[ ${REPLY} == "" ]] ; then REPLY="$2" ; else echo " "; fi

    case ${REPLY^^} in
      [Y]* ) ;;
      [N]* ) ;;
      [R]* ) ;;
      * ) printf "${RED}ERROR - Invalid Option Entered [Y/N]${RESTORE}\n\n"; REPLY="";;
    esac
  done
  REPLY=${REPLY^^}
}

#=====================================================
#   Setup Alpine Repositories
#=====================================================
printf "\n\n================= Setting Up APK Repositories ==============\n\n"
_AskYN "Find Fastest Repository [Y/n]" "Y"
if [ $REPLY == "Y" ]; then
   data=""
   for s in $(wget -qO- https://mirrors.alpinelinux.org/mirrors.txt); do
        t=$(time -f "%E" wget -q $s/MIRRORS.txt -O /dev/null 2>&1)
        echo "$s was $t"
        data="$data$t $s\n"
   done
   REPO=$( echo -e $data | sort | head -n 1 )
   mv /etc/apk/repositories /etc/apk/repositories.bak
   touch /etc/apk/repositories
   echo '$REPO/latest-stable/main'
   echo '$REPO/latest-stable/community'
   echo '$REPO/edge/main'
   echo '$REPO/edge/community'
   echo '#$REPO/edge/testing'
   
   #echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories
   #echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories
   #echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories
   #echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories
   #echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories	   		   
else
   RET=$( cat /etc/apk/repositories | grep -c 'mirror.csclub.uwaterloo.ca' )
   if [ ${RET} == 0 ]; then
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
fi

#=============================
#  Update the system
#=============================
printf "\n\n================= Updating ALPINE System ==============\n\n"
apk update && apk upgrade
apk add sudo bash bash-completion nano wget unzip

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
    printf "\n\n================= Adding ${USR} to Wheel Group ==============\n\n"
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
   _AskYN "Add Flatpak to System [Y/n]" "Y"
   if [ $REPLY == "Y" ]; then
	  if [[ ${REPLY} == "" ]]; then REPLY="N"; fi
	  if [[ ${REPLY} == "y" ]]; then REPLY="Y"; fi
	  if [[ ${REPLY} == "Y" ]]; then 
		  printf "\n\n================= Installing Flatpak Package Manager ==============\n\n"
		  apk add flatpak
		  flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'  
	  fi
   fi
fi

#==================================
# Downloading the required scripts
#==================================
if [[ ! -d /$HDIR/scripts ]]; then
   _AskYN "Download Scripts [Y/n]" "Y"
   if [ $REPLY == "Y" ]; then
 	   printf "\n\n================= Downloading scripts to /$HDIR/scripts/ ==============\n\n"
	   mkdir $HDIR/scripts/
	   cd $HDIR/scripts

	   sURL="https://tinyurl.com/sys-src"
	   wget -q $sURL
	   if [[ ! -f sys-src ]]; then
		   printf "\n\n********** Cannot find $URL *******\n\n\n";
		   exit 1
	   fi

	   if [[ -f sys-src ]]; then unzip -o -q sys-src; fi
	   rm -f sys-src
      chown -R ${USR}:${USR} $HDIR/scripts
      chmod +x $HDIR/scripts/*.sh
   fi
fi

_AskYN "Reboot Now [Y/n]" "Y"
if [ $REPLY == "Y" ]; then reboot; fi
