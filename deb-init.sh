#!/bin/bash

#=========================================================
#      Color Codes
#=========================================================
RESTORE='\033[0m'
LYELLOW='\033[01;93m'
LPURPLE='\033[01;95m'
LGREEN='\033[01;92m'
LRED='\033[01;91m'
LCYAN='\033[01;96m'
OVERWRITE='\e[1A\e[K'
TASK=""
LOG=""

# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then
   printf "\n\n*************** Please run as root ***************\n\n\n"
   exit 1
fi

if [[ -z $LOG ]]; then LOG="./update.log"; fi

#========================================================
#    Task Functions
#========================================================
function _run() {
    local _cmd="$1 >>$LOG 2>&1"
    printf "\n==== $TASK:  $1 ====\n\n" >> $LOG
    eval ${_cmd}
}

function _task-begin() {
   TASK=$1
   printf "\n\n============================= Start of $TASK =============================\n\n" >> ${LOG}
   printf "${LCYAN}    [ ]  ${TASK} \n${LRED}"
}

function _task-end() {
   printf "\n\n============================= End of $TASK =============================\n\n" >> ${LOG}
   printf "${OVERWRITE}${LGREEN}    [✓]  ${LGREEN}${TASK}${RESTORE}\n"
   TASK=""
}


#========================================================
#    UPDATE Functions
#=========================================================
printf "\n\n${LPURPLE}============= Initializing System for System Update ==========${RESTORE}\n\n"

# Update the system
_task-begin "Updating Linux system files"
_run "apt-get update"
_run "apt-get upgrade -y"
_run "apt-get autoremove -y"
_run "apt-get --fix-broken install"
_task-end

# Install required software
_task-begin "Install required software"
_run "apt-get install -y wget unzip dmidecode nano sudo"
_run "apt-get --fix-broken install"
_task-end

USR="martin"
if [[ ! -z $1 ]]; then USR=$1; fi

_task-begin "Create user $USR"
# Create new user & add to sudoers
_run "adduser $USR"
_run "usermod -aG sudo $USR"
HDIR="/home/${USR}"
_task-end

#==================================
# Downloading the required scripts
#==================================
if [[ ! -d /$HDIR/scripts ]]; then
  _task-begin "Download Scripts for system update"
  _run "mkdir -p /$HDIR/scripts/"
  cd /$HDIR/scripts
  
  sURL="https://tinyurl.com/sys-src"
  _run "wget -q $sURL"
  if [[ ! -f sys-src ]]; then
     printf "\n\n********** Cannot find $URL *******\n\n\n";
     exit 1
  fi
  _task-end
  
  _task-begin "Unzip scripts to scripts directory"
  _run "mv sys-src scripts.zip"
  if [[ -f scripts.zip ]]; then _run "unzip -o -q scripts.zip"; fi
  _run "chown -R ${USR}:${USR} /$HDIR/scripts"
  _run "chmod +x /$HDIR/scripts/*.sh"
  _run "rm -f scripts.zip"
  _task-end
fi

printf "\n${LPURPLE}=============== End of Initialization ===============${RESTORE}\n\n"