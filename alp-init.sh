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
TASK=""
LOG="$PWD/alpine.log"
TMP="$PWD/alpine.tmp"
PROG=()
FN="main()"
RET=""
VER="1.10"
PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "

if [[ -n $1 ]]; then USR="$1"; fi
HDIR="/home/$USR"


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
   printf "\n\n\t\t   ${YELLOW} Alpine Initial Setup          ${LPURPLE}Version: $VER\n${RESTORE}"
   printf "\t\t\t\t\t      ${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
   FN="${PREVFN}"
}

#========================================================
#    Task Functions
#========================================================
function _task-begin() {
   TASK=$1
   printf "${LCYAN}    [ ]  ${TASK} \n${LRED}"
}

function _task-end() {
   printf "${OVERWRITE}${LGREEN}    [✓]  ${LGREEN}${TASK}${RESTORE}\n"
   TASK=""
}

function _run() {
    local _cmd="$1 1>/dev/null 2>${TMP} || errHandler $1"
    eval ${_cmd}
}

#========================================================
#    Package Functions
#========================================================
function _add_pkg() {
  local FLG=""
  local PREVFN="$FN" && FN="_add_pkg()"

  _task-begin "Installing Package $1"
  if [[ ! $(apk list -I "$1" 2>/dev/null | grep -c "$1") ]]; then
    _run "apk add $1" ;;
    _task-end 
  else
     TASK="Application $1 already installed"
     printf "$OVERWRITE $LGREEN   [x] $RED $TASK $RESTORE\n"
     TASK=""
  fi
  FN="$PREVFN"
}

function _add_by_list() {
  local PREVFN="$FN" && FN="_add_by_list()"
  local Pkgs=${*}
  if [ ${#Pkgs[@]} -gt 0 ]; then
    for Pkg in ${Pkgs[@]}; do
      _add_pkg "$Pkg"
    done
  fi
  FN="$PREVFN"  
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
   local data=""
   local timr=0
   local src=""

   printf "\n\n$LPURPLE================= Setting Up APK Repositories ==============$RESTORE\n\n"
   _AskYN "Find Fastest Repository [Y/N]" "Y"
   if [[ "$REPLY" == "Y" ]]; then
      printf "\n"
      #Get list of Mirrors
      REPO=$(wget -qO- https://mirrors.alpinelinux.org/mirrors.txt)

      #Remove mirrors that are known not to respond
      REPO=$(echo -e "$REPO" | grep -v "mirror.lzu.edu.cn")
      REPO=$(echo -e "$REPO" | grep -v "mirror.leitecastro.com")
      REPO=$(echo -e "$REPO" | grep -v "mirror.serverion.com")
      REPO=$(echo -e "$REPO" | grep -v "repo.jing.rocks")
      REPO=$(echo -e "$REPO" | grep -v "mirror.siwoo.org")
      REPO=$(echo -e "$REPO" | grep -v "mirror.saddle.network")
      REPO=$(echo -e "$REPO" | grep -v ".edu.cn")
      REPO=$(echo -e "$REPO" | grep -v ".edu.tw")
      REPO=$(echo -e "$REPO" | grep -v ".edu.au")
      REPO=$(echo -e "$REPO" | grep -v ".garr.it")
      REPO=$(echo -e "$REPO" | grep -v ".com.kh")
      REPO=$(echo -e "$REPO" | grep -v ".ac.jp")
      REPO=$(echo -e "$REPO" | grep -v ".ungleich.ch")
      REPO=$(echo -e "$REPO" | grep -v ".co.kr")

      #Test the mirrors in the list
      for src in $REPO; do
         timr=$(time -f "%e" wget -q $src/MIRRORS.txt -O /dev/null 2>&1)
         echo "$timr - $src"
         data="$data$timr $src\n"
      done

      #Sort and find the fastest link
      REPO=""
      REPO=$( echo -e "$data" | sort | sed -r '/^\s*$/d' | head -n 1 )
      src=$(echo $REPO | cut -F1)
      REPO=$(echo $REPO | cut -F2)
      printf "\n$LGREEN Setting up Repo:$LYELLOW $src $REPO $RESTORE\n\n"

      #Update the repos that Alpine uses
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
   echo "End of Repo...."
}

#=============================
#  Update the system
#=============================
function updateSystem {
   local PREVFN="$FN" && FN="updateSystem()"
   printf "\n\n$LPURPLE================= Updating ALPINE System ==============$RESTORE\n\n"
   _run "apk update && apk upgrade"
   PROG=("sudo" "bash" "bash-completion" "nano" "wget" "unzip")
   _add_by_list ${PROG[*]}
   echo "End of $FN" && read
   FN="$PREVFN"
}

#=============================
#  Setup SUDO for Users
#=============================
function addUsers {
   local PREVFN="$FN" && FN="addUsers()"
   if [[ ! $(id "$USR" 2>/dev/null | grep -c "($USR)") ]]; then
      printf "\n\n$LPURPLE================= Adding $USR to System ==============$RESTORE\n\n"
      adduser "$USR"

      # Add WHEEL file
      if [ ! -f /etc/sudoers.d/wheel ]; then
         printf "\n\n$LPURPLE================= Adding Wheel Group ==============$RESTORE\n\n"
         echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
      fi

      printf "\n\n$LPURPLE================= Adding $USR to Wheel Group ==============$RESTORE\n\n"
      if [[ ! $(id -nG "$USR" 2>/dev/null | grep -c 'wheel') ]]; then adduser "$USR" wheel; fi
   fi
   echo "End of $FN" && read
   FN="$PREVFN"
}

#=============================
# Update Terminal Profile
#=============================
function updateTerminal {
   local PREVFN="$FN" && FN="updateTerminal()"
   RET=$( cat /etc/profile | grep -c 'PS1="\[\033}' )
   if [ ${RET} == 0 ]; then
      printf "\n\n$LPURPLE================= Updating Terminal Profile for $USR ==============$RESTORE\n\n"
      echo "PS1=/"$PS1/"" >> /etc/profile
      echo "export PS1" >> /etc/profile
   fi
   echo "End of $FN" && read
   FN="$PREVFN"
}

#=============================
# Remove MOTD
#=============================
function removeMOTD {
   local PREVFN="$FN" && FN="removeMOTD()"
   if [ -f /etc/motd ]; then
      printf "\n\n$LPURPLE================= Removing MOTD ==============$RESTORE\n\n"
      _run "rm /etc/motd"
   fi
   echo "End of $FN" && read
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
         printf "\n\n$LPURPLE================= Installing Flatpak Package Manager ==============$RESTORE\n\n"
         _run "apk add flatpak"
         _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
      fi
   fi
   echo "End of $FN" && read
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
         printf "\n\n$LPURPLE================= Downloading scripts to /$HDIR/scripts/ ==============$RESTORE\n\n"
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
   echo "End of $FN" && read
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
