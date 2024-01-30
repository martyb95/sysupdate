#!/bin/ash

# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then
   printf "\n\n*************** Please run as root ***************\n\n\n"
   exit 1
fi

USR="martin"
if [[ ! -z $1 ]]; then USR=$1; fi

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

HDIR="/home/${SUDO_USER}"
LOG="${HDIR}/update.log"
OPT="777"
REPLY=""

#========================================================
#    Task Functions
#========================================================
function run() {
    local CMD="$1 >>$LOG 2>&1"
    printf "\n==== $TASK:  $1 ====\n\n" >> $LOG
    eval ${CMD}
}

function taskBegin() {
   TASK=$1
   printf "\n\n============================= Start of $TASK =============================\n\n" >> ${LOG}
   printf "${LCYAN} [ ]  ${TASK} \n${LRED}"
}

function taskEnd() {
   printf "\n\n============================= End of $TASK =============================\n\n" >> ${LOG}
   printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}${RESTORE}\n"
   TASK=""
}

function logMsg() {
   printf "     ${1}\n" >> ${LOG}
}

function toUpper() {
   local ANS=$(echo "$1" | tr '[a-z]' '[A-Z]')
   printf "$ANS"
}

function toLower() {
   local ANS=$(echo "$1" | tr '[A-Z]' '[a-z]')
   printf "$ANS"
}


#========================================================
#    Input Functions
#========================================================
function Ask(){
  REPLY=""
  if  [[ ! -z ${2} ]]; then
    printf "${LCYAN}${1} ${YELLOW}[${2}]: ${RESTORE}"
    read REPLY
    if [[ -z ${REPLY} ]]; then REPLY="${2}" ; fi
  else
    printf "${LCYAN}${1}: ${RESTORE}"
    read REPLY
  fi
}

function AskYN(){
  REPLY=""
  while [[ -z ${REPLY} ]]
  do
    printf "${LGREEN}${1}? ${YELLOW}[${2}]: ${RESTORE}"
    read -n 1 REPLY
    if [[ -z ${REPLY} ]]; then REPLY="$2"; fi
    REPLY=$( toUpper $REPLY )

    if [[ "YNR" != *${REPLY}* ]]; then
       REPLY=""
       printf "\n${RED}ERROR - Invalid Option Entered [Y/N]${RESTORE}\n\n"
    fi
  done
}

#========================================================
#    Processing Functions
#========================================================
function getOS() {
   if [[ -f /etc/os-release ]]; then
      # On Linux systems
      source /etc/os-release >>$LOG 2>&1
      OS=$( echo $ID )
   else
      # On systems other than Linux (e.g. Mac or FreeBSD)
      OS=$( uname )
   fi
   OS=$( toUpper $OS )

   # Operating system must be one of the valid ones
   if [[ $OS != "ALPINE" ]]; then
      printf "\n\n********** [$OS] Is An Invalid OS.  Should be Alpine Linux *******\n\n\n";
      exit 1
   fi
}

function baseSetup() {
   #=============================
   # Setup Alpine Repositories
   #=============================
   taskBegin "Setup Alpine Repositories"
   RET=$( cat /etc/apk/repositories | grep -c 'uwaterloo.ca/alpine/edge/community' )
   if [ ${RET} == 0 ]; then
      run "mv /etc/apk/repositories /etc/apk/repositories.bak"
      run "touch /etc/apk/repositories"
      run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories"
      run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories"
      run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories"
      run "echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories"
      run "echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories"
   fi
   taskEnd

   #=============================
   #  Upgrade Linux System
   #=============================
   taskBegin "Upgrade Linux System"
   run "apk update"
   run "apk upgrade"
   run "apk add sudo bash bash-completion nano wget flatpak"
   taskEnd
   
   #=============================
   #  Setup SUDO for Users
   #=============================
   taskBegin "Setup SUDO for ${USR}"
   if [ ! -f /etc/sudoers.d/wheel ]; then
      run "echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel"
   fi
   taskEnd

   #=============================
   #  Add User to Wheel Group
   #=============================
   taskBegin "Add ${USR} to Wheel Group"
   if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') = 1 ]; then
      if [ $(id -nG ${USR} 2>/dev/null | grep -c 'wheel') = 1 ]; then  run "adduser ${USR} wheel"; fi
   fi
   taskEnd
}

function procDesktop() {
   baseSetup
}

function procServer() {
   baseSetup
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
██╗███╗   ██╗██╗████████╗██╗ █████╗ ██╗     ██╗███████╗███████╗
██║████╗  ██║██║╚══██╔══╝██║██╔══██╗██║     ██║╚══███╔╝██╔════╝
██║██╔██╗ ██║██║   ██║   ██║███████║██║     ██║  ███╔╝ █████╗
██║██║╚██╗██║██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══╝
██║██║ ╚████║██║   ██║   ██║██║  ██║███████╗██║███████╗███████╗
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝
"
   printf "\n\t\t   ${YELLOW}${OS} System Setup             ${LPURPLE}Ver 1.06\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}    by: ${LPURPLE}Martin Boni${RESTORE}\n"
}

function mainMenu() {
   local ValidOPT="1,2,99"
   printf "\n\n${LPURPLE}       ${OS} Desktop Setup\n"
   printf "  ${LGREEN}+--------------------------------+\n"
   printf "  |                                |\n"
   printf "  |   1) Initialize for Desktop    |\n"
   printf "  |   2) Initialize for Server     |\n"
   printf "  |  ----------------------------  |\n"
   printf "  |  99) Quit                      |\n"
   printf "  |                                |\n"
   printf "  +--------------------------------+${RESTORE}\n\n\n\n"
   while [[ ${ValidOPT} != *${OPT}* ]]
   do
      Ask "${OVERWRITE}Choose the step to run (1-4 or 99)" "1" && OPT=$REPLY
   done
   printf "\n\n"
}


#=======================================
# Main Code - Start
#=======================================
getOS
title
if [[ -f ${LOG} ]]; then run "rm -f ${LOG}"; fi
run "touch ${LOG}"
run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"

while [[ ${OPT} != "99" ]]
do
   mainMenu
   case ${OPT} in
      1) procDesktop ;;
      2) procServer ;;
     99) ;;
   esac
done

AskYN "OK to Reboot Now (y/n)" "Y" && OPT=$REPLY
if [ $OPT == "Y" ]; then reboot; fi
