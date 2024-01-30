#!/bin/bash


ValidOS='alpine'
#========================================================
#   Pre-start Application Checks
#========================================================
clear
# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then printf "\n\n${LRED}*************** Please run as root ***************${RESTORE}\n\n\n\n"; exit 1; fi

# get the os name and check if it is supported
__OS=$(grep '^ID=' /etc/os-release) && __OS=${__OS#*=}
if [[ "$ValidOS" != *${__OS}* ]]; then printf "\n  Unknown operating system ( ${__OS} ). Script cannot run.\n\n$(lsb_release -a)\n\n" ; exit 1 ; fi

HDIR="/home/${SUDO_USER}"
LOG="${HDIR}/${__OS}-setup.log"

function _install_scripts {
   if [ ! -d ${HDIR}/Scripts ]; then
     printf "\n Installing Required Script Dependencies\n"
     mkdir ${HDIR}/Scripts >> ${LOG} 2>&1
     chown -R $SUDO_USER:$SUDO_USER * >> ${LOG} 2>&1
     cd ${HDIR}/Scripts >> ${LOG} 2>&1
     wget -q  https://tinyurl.com/lin-script >> ${LOG} 2>&1
     if [ -f ${HDIR}/Scripts/lin-script ]; then
       apt install -y unzip >> ${LOG} 2>&1
       mv -f lin-script script.zip >> ${LOG} 2>&1
       unzip -o -q script.zip >> ${LOG} 2>&1
       chown -R $SUDO_USER:$SUDO_USER * >> ${LOG} 2>&1
       mv -f import/* /usr/local/include/ >> ${LOG} 2>&1
       rm -f script.zip >> ${LOG} 2>&1
     fi
     cd ${HDIR} >> ${LOG} 2>&1
   fi
}

_install_scripts
if (( $(echo $PATH | grep -c '/usr/local/include') == 0 )); then export PATH=/usr/local/include:$PATH; fi
source fn_general.sh
source fn_task.sh
source fn_apt_flatpak.sh
source fn_input.sh

#=======================================
# Initialize Variables
#=======================================
_DSK="777"
_STP="777"
TASK=""
Status="ok installed"
PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\]"

#=======================================
# Function Definitions
#=======================================
function  _title() {
	clear
	printf "\n${CYAN}
   █████╗ ██╗     ██████╗ ██╗███╗   ██╗███████╗
  ██╔══██╗██║     ██╔══██╗██║████╗  ██║██╔════╝
  ███████║██║     ██████╔╝██║██╔██╗ ██║█████╗  
  ██╔══██║██║     ██╔═══╝ ██║██║╚██╗██║██╔══╝  
  ██║  ██║███████╗██║     ██║██║ ╚████║███████╗
  ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝
    ███████╗███████╗████████╗██╗   ██╗██████╗    
    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗   
    ███████╗█████╗     ██║   ██║   ██║██████╔╝   
    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝    
    ███████║███████╗   ██║   ╚██████╔╝██║        
    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝        	
"
   printf "\n\t\t   ${YELLOW}${__OS^^} System Setup        ${LPURPLE}Ver 1.41\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
}

function  _menu() {
   printf "\n\n${LPURPLE}       ${__OS^^} Desktop Setup\n"
   printf "  ${LGREEN}+----------------------------------+\n"
   printf "  |                                  |\n"
   printf "  |   1) Initial Setup               |\n"
   printf "  |   2) Install Desktop             |\n"
   printf "  |   3) Install Applications        |\n"
   printf "  |   4) Setup Desktop               |\n"
   printf "  |  ------------------------------  |\n"
   printf "  |   5) Install/Reinstall Scripts   |\n"
   printf "  |   6) Update System & Apps        |\n"
   printf "  |  ------------------------------  |\n"
   printf "  |  99) Quit                        |\n"
   printf "  |                                  |\n"
   printf "  +----------------------------------+${RESTORE}\n\n\n"
   while [[ "12345699" != *${_STP}* ]]
   do
      _Ask "${OVERWRITE}Choose the step to run (1-4 or 99)" "1" && _STP=$REPLY
   done
   printf "\n\n"
}


#=======================================
# Main Code - Start
#=======================================
_init_lists
_set_pkg_mgr
_title

#=============================
# Choose Step to Run
#=============================
while [[ ${_STP^^} != "99" ]]
do
   _menu
   case ${_STP^^} in
      1) _process_step_1 ;;
      2) _process_step_2 ;;
      3) _process_step_3 ;;
      4) _process_step_4;;
      5) if [ -d ${HDIR}/Scripts ]; then _run "rm rf ${HDIR}/Scripts"; fi
	     _install_scripts;;
	  6) _upgrade_apps ;;
     99) break ;;
   esac
   _STP="777"
done

printf "\n\n\n${YELLOW}============= Updater Completed - Please REBOOT =============${RESTORE}\n\n"
_AskYN "OK to Reboot Now (y/n)" "Y" 
if [ ${REPLY^^} = "Y" ]; then reboot; fi