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

#=========================================================
#    Global Variables
#=========================================================
USR="martin"
LOG="update.log"
ITYPE="DESKTOP"   # can be either DESKTOP or SERVER
OPT="777"
ADDList=("")
DELList=("")

APPList=("=== System Tools ===||"
		 "Docker Engine|docker|N"
		 "Neofetch|neofetch|Y"
         "OpenSSH|openssh|Y"
		 "Uncomplicated Firewall|unf|N"
		 "Fail2Ban|fail2ban|N"
		 "Wireguard|wireguard|N"}
         )
         
         
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
   printf "${LCYAN} [ ]  ${TASK} \n${LRED}"
}

function _task-end() {
   printf "\n\n============================= End of $TASK =============================\n\n" >> ${LOG}
   printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}${RESTORE}\n"
   TASK=""
}

function _log-msg() {
   printf "     ${1}\n" >> ${LOG}
}


#========================================================
#    Input Functions
#========================================================
function Ask(){
  local REPLY=""
  if  [[ ${2} != "" ]]; then
    printf "${LGREEN}${1} ${YELLOW}[${2}]: ${RESTORE}"
    read REPLY
    if [[ ${REPLY} == "" ]] ; then REPLY="${2}" ; fi
  else
    printf "${LGREEN}${1}: ${RESTORE}"
    read REPLY
  fi
  printf "${REPLY^^}"
}

function AskYN(){
  local REPLY=""
  
  while [[ "Y,N" != *${REPLY}* ]]
  do
    printf "${LGREEN}${1}? ${YELLOW}[${2}]: ${RESTORE}"
    read -n 1 REPLY
    if [[ ${REPLY} == "" ]]; then REPLY="$2" ; else echo " "; fi
    if [[ "Y,N" != *${REPLY}* ]]; then
       printf "${RED}ERROR - Invalid Option Entered [Y/N]${RESTORE}\n\n"
    fi
  done
  printf "${REPLY^^}"
}


#========================================================
#    Package Functions
#========================================================
function pkgList() {
  case ${1^^} in
     Y) ADDList+=(${2}) ;;
     R) DELList+=(${2}) ;;
  esac
}

function choosePkgs() {
   if [ ${#APPList[@]} -gt 0 ]; then
     for i in {0..999}; do
        if (( i == ${#APPList[@]} )); then break; fi
        IFS='|' read -ra arr <<< "${APPList[i]}"
        if [ ${#arr[@]} -gt 0 ]; then
          if [[ "${arr[0]}" =~ ^"===" ]]; then
		     printf "\n${LPURPLE}${arr[0]}${RESTORE}\n"
          else
		     if (( $(_exists "${arr[1]}") == 0 )); then
                AskYN "Install ${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
	         else
                AskYN "Install $LRED${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
             fi
             pkgList ${REPLY^^} ${arr[1]}
	      fi
        fi
     done
   fi
}

function addPkg() {
  if (( $(_exists $1) == 0 )); then
     _task-begin "Installing ${1^^}"
     _run "apk add --upgrade $1"
     _task-end
  else
     _task-begin "${LRED}${1^^} Exists...Skipping"
     _task-end
  fi
}

function addByList() {
  local PKGS=${*}
  if [ ${#PKGS} -gt 0 ]; then
    for pkg in ${PKGS[@]}; do
	   addPkg ${pkg}
    done
  fi
}

function delPkg() {
  if (( $(_exists $1) > 0 )); then
    _task-begin "Removing ${1^^}"
    _run "apk del $1"
    _task-end
  fi
}

function delByList() {
  local PKGS=${*}
  if [ ${#PKGS} -gt 0 ]; then
    for pkg in ${PKGS[@]}; do
       delPkg ${_pkg}
    done
  fi
}


#=============================
# Process Functions
#=============================
function setRepos() {
   RET=$( cat /etc/apk/repositories | grep -c 'uwaterloo.ca/alpine/edge/community' )
   if [ ${RET} == 0 ]; then
      _task-begin "Updating Alpine Repositories"
      _run "mv /etc/apk/repositories /etc/apk/repositories.bak"
      _run "touch /etc/apk/repositories"
      _run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories"
      _run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories"
      _run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories"
      _run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories"
      _run "echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories"
      _task-end
   fi
}

function updateSys() {
   _task-begin "Updating Alpine Packages"
   _run "apk update"
   _run "apk upgrade"
   _task-end
}

function addPrograms() {
   local PList=("sudo" "bash" "bash-completion" "nano" "unzip" "wget")
   if [[ ${ITYPE^^} == "SERVER" ]]; then
     PList+=("neofetch")
   else
     PList=("flatpak")
   fi
   addByList ${PList[*]}
   if [ ${#APPList} -gt 0 ]; then addByList ${APPList[*]}; fi
   if [ ${#DELList} -gt 0 ]; then delByList ${DELList[*]}; fi
}

function addToAdmin() {
if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') = 1 ]; then
    if [ $(id -nG ${USR} 2>/dev/null | grep -c 'wheel') = 1 ]; then  adduser ${USR} wheel; fi
    if [ ! -f /etc/sudoers.d/wheel ]; then echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel; fi
fi
}

function initServer() {
   choosePkgs
   setRepos
   updateSys
   addToAdmin
   addPrograms
}

function initDesktop() {
   setRepos
   updateSys
   addToAdmin
   addPrograms
}


#=======================================
# Title & Menu
#=======================================
function title() {
   clear
   printf "\n${CYAN}
    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
        ███████╗███████╗████████╗██╗   ██╗██████╗
        ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
        ███████╗█████╗     ██║   ██║   ██║██████╔╝
        ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
        ███████║███████╗   ██║   ╚██████╔╝██║
        ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝
"
   printf "\n\t\t   ${YELLOW}Alpine System Initialization    ${LPURPLE}Ver 1.01\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
}

function mainMenu {
   printf "  ${LPURPLE}   Alpine Main Menu\n"
   printf "  ${LGREEN}+--------------------------------+\n"
   printf "  |                                |\n"
   printf "  |   1) Initialize a Server       |\n"
   printf "  |   2) Initialize a Desktop      |\n"
   printf "  |                                |\n"
   printf "  |  99) Quit                      |\n"
   printf "  |                                |\n"
   printf "  +--------------------------------+${RESTORE}\n\n\n"

   while [[ "1,2,99" != *${OPT}* ]]
   do
      OPT=$(Ask " ${OVERWRITE}Choose the Initialization (1,2 or 99)" "1")
   done
   printf "\n\n"
 }



#=============================
#  Start of Script
#=============================
title
if [[ ! -z $1 ]]; then USR=$1; fi

while [[ ${OPT} != "99" ]]
do
   mainMenu()
   case ${STP^^} in
      1) initServer ;;
      2) initDesktop ;;
     99) break ;;
   esac
   OPT="777"
done

if [ $(ASKYN "Do you wish to reboot now" "Y") == "Y" ]; then reboot; fi
