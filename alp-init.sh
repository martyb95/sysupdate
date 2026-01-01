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
LOG="$PWD/alpine.log"
TMP="$PWD/alpine.tmp"
FN="main()"
RET=""
VER="1.10"
PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "

if [[ -n $1 ]]; then USR="$1"; fi
HDIR="/home/$USR"


#=======================================
# Title & Menu
#=======================================
function title() {
   local PREVFN="${FN}" && FN="title()"

   clear
   printf "\n${CYAN}
           █████╗ ██╗     ██████╗ ██╗███╗   ██╗███████╗                  
          ██╔══██╗██║     ██╔══██╗██║████╗  ██║██╔════╝                  
          ███████║██║     ██████╔╝██║██╔██╗ ██║█████╗                    
          ██╔══██║██║     ██╔═══╝ ██║██║╚██╗██║██╔══╝                    
          ██║  ██║███████╗██║     ██║██║ ╚████║███████╗                  
          ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝                  
                                                               
     ██╗███╗   ██╗██╗████████╗██╗ █████╗ ██╗     ██╗███████╗███████╗
     ██║████╗  ██║██║╚══██╔══╝██║██╔══██╗██║     ██║╚══███╔╝██╔════╝
     ██║██╔██╗ ██║██║   ██║   ██║███████║██║     ██║  ███╔╝ █████╗  
     ██║██║╚██╗██║██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══╝  
     ██║██║ ╚████║██║   ██║   ██║██║  ██║███████╗██║███████╗███████╗
     ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝
"
   printf "\n\n\t\t   ${YELLOW} Alpine Initial Setup     ${LPURPLE}Version: $VER\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
   FN="${PREVFN}"
}

#=======================================
# Execute command
#=======================================
function _run() {
    local _cmd="$1 1>/dev/null 2>${TMP} || errHandler $1"
    eval ${_cmd}
}

#=======================================
# Error Handler
#=======================================
function errHandler {
  local ERRCMD="$1"
  local ERRMSG=$(cat "$TMP")
  local TIMESTAMP="2025-12-20 14:23:52"
  printf "\n\n========= $TIMESTAMP =====================================================\n" >> "$LOG"
  printf "  ERROR - $ERRMSG\n" >> "$LOG"
  printf "          COMMAND:     $ERRCMD\n" >> "$LOG"
  printf "          FUNCTION:    $FN\n" >> "$LOG"
  printf "          LINE NUMBER: $BASH_LINENO\n" >> "$LOG"
  printf "===================================================================================\n" >> "$LOG"
  _run "rm -f $TMP"
}

#=======================================
# Ask Yes or No
#=======================================
function _AskYN {
  REPLY=""
  while [[ -z ${REPLY} ]]
  do
    printf "$LGREEN $1? $YELLOW[$2]: $RESTORE"
    read -n 1 REPLY
    if [[ "$REPLY" == "" ]] ; then REPLY="$2" ; else echo " "; fi
    REPLY=$(echo "$REPLY" | tr '[:lower:]' '[:upper:]')

    case "$REPLY" in
      [Y]* ) ;;
      [N]* ) ;;
      [R]* ) ;;
      * ) printf "$RED ERROR - Invalid Option Entered [Y/N]$RESTORE\n\n"; REPLY="";;
    esac
  done
}

#=====================================================
#   Setup Alpine Repositories
#=====================================================
function setupRepo {
   local PREVFN="$FN" && FN="setupRepo()"
   local REPO=""
   local LST=""
   local data=""
   local t=0
   local s=""

   printf "\n\n================= Setting Up APK Repositories ==============\n\n"
   _AskYN "Find Fastest Repository [Y/N]" "Y"
   if [[ "$REPLY" == "Y" ]]; then
      printf "\n"
      #Get list of Mirrors
      LST=$(wget -qO- https://mirrors.alpinelinux.org/mirrors.txt)

      #Remove mirrors that are known not to respond
      echo "Debug 01"
      LST=$(echo -e "$LST" | grep -v "mirror.lzu.edu.cn")
      LST=$(echo -e "$LST" | grep -v "mirror.leitecastro.com")
      LST=$(echo -e "$LST" | grep -v "mirror.serverion.com")
      LST=$(echo -e "$LST" | grep -v "repo.jing.rocks")
      LST=$(echo -e "$LST" | grep -v "mirror.siwoo.org")
      LST=$(echo -e "$LST" | grep -v "mirror.saddle.netowrk")
      echo "Debug 02"

      #Test the mirrors in the list
      for s in "$LST"; do
         t=$(time -f "%e" wget -q $s/MIRRORS.txt -O /dev/null 2>&1)
         echo "$t - $s"
         data="$data$t $s\n"
      done

      echo "Debug 03"
      REPO=$( echo -e $data | sort | sed -r '/^\s*$/d' | head -n 1 | cut -F2 )
      printf "\nSetting up Repo:$LYELLOW $REPO $RESTORE\n\n"
      read
      if [[ -n "$REPO" ]]; then
         _run "mv /etc/apk/repositories /etc/apk/repositories.bak"
         _run "touch /etc/apk/repositories"
         echo "$REPO/latest-stable/main" >/etc/apk/repositories
         echo "$REPO/latest-stable/community" >>/etc/apk/repositories
         echo "$REPO/edge/main" >>/etc/apk/repositories
         echo "$REPO/edge/community" >>/etc/apk/repositories
         echo "#$REPO/edge/testing" >>/etc/apk/repositories
      fi
   fi

   if [[ -z "$REPO" ]]; then
      RET=$( cat /etc/apk/repositories | grep -c 'mirror.csclub.uwaterloo.ca' )
      if [ ${RET} == 0 ]; then
         _run "mv /etc/apk/repositories /etc/apk/repositories.bak"
         _run "touch /etc/apk/repositories"
         echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' > /etc/apk/repositories
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
   FN="$PREVFN"
}

#=============================
#  Update the system
#=============================
function updateSystem {
   local PREVFN="$FN" && FN="updateSystem()"
   printf "\n\n================= Updating ALPINE System ==============\n\n"
   _run "apk update && apk upgrade"
   _run "apk add sudo bash bash-completion nano wget unzip"
   FN="$PREVFN"
}

#=============================
#  Setup SUDO for Users
#=============================
function addUsers {
   local PREVFN="$FN" && FN="addUsers()"
   if [ $(id "$USR" 2>/dev/null | grep -c "($USR)") != 1 ]; then
      printf "\n\n================= Adding $USR to System ==============\n\n"
      adduser "$USR"

      # Add WHEEL file
      if [ ! -f /etc/sudoers.d/wheel ]; then
         printf "\n\n================= Adding Wheel Group ==============\n\n"
         echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
      fi

      printf "\n\n================= Adding $USR to Wheel Group ==============\n\n"
      if [ $(id -nG "$USR" 2>/dev/null | grep -c 'wheel') != 1 ]; then adduser "$USR" wheel; fi
   fi
   FN="$PREVFN"
}

#=============================
# Update Terminal Profile
#=============================
function updateTerminal {
   local PREVFN="$FN" && FN="updateTerminal()"
   RET=$( cat /etc/profile | grep -c 'PS1="\[\033}' )
   if [ ${RET} == 0 ]; then
      printf "\n\n================= Updating Terminal Profile for $USR ==============\n\n"
      echo "PS1=/"$PS1/"" >> /etc/profile
      echo "export PS1" >> /etc/profile
   fi
   FN="$PREVFN"
}

#=============================
# Remove MOTD
#=============================
function removeMOTD {
   local PREVFN="$FN" && FN="removeMOTD()"
   if [ -f /etc/motd ]; then
      printf "\n\n================= Removing MOTD ==============\n\n"
      _run "rm /etc/motd"
   fi
   FN="$PREVFN"
}

#===============================
#  Add Flatpak Package Manager
#===============================
function addFlatpak {
   local PREVFN="$FN" && FN="addFlatpak()"
   VAL=$(apk list -I "flatpak" 2>/dev/null | grep -c "flatpak")
   if [[ $VAL == 0 ]]; then
      _AskYN "Add Flatpak to System [Y/n]" "Y"
      if [ $REPLY == "Y" ]; then
         printf "\n\n================= Installing Flatpak Package Manager ==============\n\n"
         _run "apk add flatpak"
         _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
      fi
   fi
   FN="$PREVFN"
}

#==================================
# Downloading the required scripts
#==================================
function addScripts {
   local PREVFN="$FN" && FN="addScripts()"
   if [[ ! -d /$HDIR/scripts ]]; then
      _AskYN "Download Scripts [Y/n]" "Y"
      if [ $REPLY == "Y" ]; then
         printf "\n\n================= Downloading scripts to /$HDIR/scripts/ ==============\n\n"
         _run "mkdir $HDIR/scripts/"
         _run "cd $HDIR/scripts"

         sURL="https://tinyurl.com/sys-src"
         _run "wget -q $sURL"
         if [[ ! -f sys-src ]]; then
            printf "\n\n********** Cannot find $URL *******\n\n\n";
            exit 1
         fi

         if [[ -f sys-src ]]; then _run "unzip -o -q sys-src"; fi
         _run "rm -f sys-src"
         _run "chown -R $USR:$USR $HDIR/scripts"
         _run "chmod +x $HDIR/scripts/*.sh"
      fi
   fi
   FN="$PREVFN"
}


#==================================
# Main Processing
#==================================
title
setupRepo
updateSystem
addUsers
updateTerminal
removeMOTD
addFlatpak
addScripts

_AskYN "Reboot Now [Y/n]" "Y"
if [ "$REPLY" == "Y" ]; then reboot; fi
