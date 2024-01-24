#!/bin/bash

# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then
   printf "\n\n*************** Please run as root ***************\n\n\n"
   exit 1
fi

HDIR="/home/${SUDO_USER}"
LOG="${HDIR}/update.log"
ValidOS="DEBIAN,ELEMENTARY,UBUNTU,SPARKY,LINUXMINT,ALPINE"

#=======================================
# Get OS Name
#=======================================
if [[ -f /etc/os-release ]]; then
   # On Linux systems
   source /etc/os-release >>$LOG 2>&1
   OS=$( echo $ID )
else
   # On systems other than Linux (e.g. Mac or FreeBSD)
   OS=$( uname )
fi

# Operating system must be one of the valid ones
if [[ ${ValidOS^^} != *${OS^^}* ]]; then
   printf "\n\n********** [${OS^^}] Is An Invalid OS.  Should be a Debian or Ubuntu Distro *******\n\n\n";
   exit 1
fi

#=======================================
# Initialize Variables
#=======================================
TASK=""
REPLY=""
DSK="777"
STP="777"
LAY="777"

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

PS1="\[\033[0;31m\]\342\224\214\342\224\200\[\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "

case ${OS^^} in
        'ALPINE') ADDList+=("gnome-software-plugin-apk" );
                  ;;
    'ELEMENTARY') ADDList+=("software-properties-common");
                  APPList=("=== ELEMENTARY Specific Tools ===||" "Pantheon System Tweaks|pantheon-tweaks|Y");
                  ;;
esac

ADDList+=("fileroller" "gnome-software-plugin-flatpak" "numlockx" "p7zip-rar" "p7zip-full" "simple-scan")
DELList=("advert-block-antix" "aisleriot" "appcenter" "aspell" "asunder" "bash-config" "calamares"  
         "celluloid"  "clementine" "conky*" "drawing" "evolution-data-server" "exaile" "featherpad" 
         "five-or-more" "foliate" "four-in-a-row" "gmtp" "gnome-2048" "gnome-chess" "gnome-contacts"
         "gnome-games" "gnome-klotski" "gnome-mahjongg" "gnome-mines" "gnome-music" "gnome-nibbles" "gnome-robots" 
		 "gnome-sound-recorder" "gnome-software-plug-snap" "gnome-sudoku" "gnome-taquin" "gnome-tetravex" 
		 "gnome-text-editor" "gnome-video-effects" "gnome-weather" "gsmartcontrol" "hexchat" "hexedit" "hitori" 
		 "hp-fab" "hypnotix" "imagemagick*" "info" "io.elementary.code" "io.elementary.feedback" "io.elementary.mail" 
		 "io.elementary.music" "io.elementary.onboarding" "io.elementary.screenshot" "io.elementary.tasks" 
		 "io.elementary.videos" "lbreakout2" "libreoffice*" "liferea" "lightsoff" "luckybackup*" "magnus" "maya-calendar" 
		 "mc" "mc-data" "mx-conky" "mx-conky-data" "mx-docs" "mx-faq" "mx-manual" "mx-remaster" "mx-remastercc" 
		 "mx-tour" "mx-viewer" "mx-welcome" "mx-welcome-data" "onboard*" "openvpn" "pantheon-photos" "parcellite" 
		 "pdfarranger" "peg-e" "pidgin" "pix" "pulseaudio-module-bluetooth" "redshift" "rhythmbox*" "riseup-vpn"
		 "radiostation" "qpdfview*" "quadrapassel" "shotwell" "snapd" "sparky-aptus-upgrade-*" "sparky-about"
		 "sparky-welcome*" "stawberry" "swell-foop" "switchboard-plug-parental-controls" "tali"  "transmission*"
		 "uget" "vokoscreen-ng" "warpinator" "xfburn" "xfce4-notes" "xterm" "yad" "zutty")

APPList+=("=== Choose Browser(s) ===||"
			"Chromium Browser|chromium|Y"
			"FireFox Browser|firefox|N"
			"Falkon Browser|falkon|N"
			"Brave Browser|@FLT-BRAVE|N"
			"Vivaldi Browser|@FLT-VIV|N"
			"=== Choose Office Tools ===||"
			"Abiword Word Processor|abiword|Y"
			"Mousepad Notepad Application|mousepad|y"
			"NotepadQQ Editor|@FLT-NOTEPAD|Y"
			"Notepad Next Editor|@FLT-NEXT|Y"
			"gEdit Graphical Editor|gedit|N"
			"Simple Note|@DEB-NOTE|N"
			"Geary Email Client|geary|N"
			"Mailspring Email Client|@FLT-MAIL|N"
            "Bluemail Email Client|@FLT-BLUE|N"
			"Thunderbird Email Client|thunderbird|N"
			"Gnome Calendar|gnome-calendar|N"
			"Gnome Calculator|gnome-calculator|Y"
			"gNumeric Spreadsheet|gnumeric|Y"
			"OnlyOffice Suite|@FLT-ONLY|Y"
			"Libre Office|libreoffice|N"
            "=== Choose Development Tools ===||"
			"Rust Programming Lanuage|@DEB-RUST|N"
            "VSCodium IDE|@FLT-CODE|N"
            "=== Choose System Tools ===||"
            "Clam Anti Virus|clamav clamtk|N"
            "Clam Anti Virus GUI|@FLT-CLAM|N"
            "Disk Utility|gnome-disk-utility|Y"
			"Flameshot Screenshot Utility|@FLT-FLAME|N"
			"FlatSeal Flatpak Management|@FLT-SEAL|Y"
			"Gnome Software Manager|gnome-software|Y"
			"gParted Disk Partioning|gparted|Y"
			"LX Terminal|lxterminal|Y"
			"Neofetch|neofetch|Y"
			"Putty SSH Utility|putty|N"
			"=== Choose Emulation Tools ===||"
			"Bottles Windows Emulation|@FLT-BOTTLES|N"
			"WINE|winehq-stable|N"
			"Play On Linux|@FLT-PLAY|N"
			"=== Choose Virtualization Tools ===||"
			"DistroBox|distrobox|N"
			"Gnome Boxes|gnome-boxes|N"
			"Vir-Manager|virt-manager|N"			
			"=== Choose Optional Applications ===||"
			"Calibre eBook Manager|@FLT-BOOK|N"
			"Cheese Camera Utility|cheese|N"
			"Ristretto Image Viewer|ristretto|Y"
			"gThumb Image Viewer|gthumb|N"
			"Kodi Media Center|kodi|N"
			"Spotify Client|@FLT-SPOT|N"
			"VLC Media Player|vlc browser-plugin-vlc|Y"
			"Zoom Video Conferencing Client|@FLT-ZOOM|N")

if [ ${OS}^^} != "ALPINE" ]; then
APPList+=("=== Debian/Ubuntu Only Packages ===||"
          "Etcher|@DEB-ETCH|Y"
		  "Stacer|stacer|Y"
		  "Synaptic Package Manager|synaptic|N"
		  "Timeshift System Snapshot|timeshift|Y"
		  "Lucky Backup|luckybackup|N"
		  "uLauncher|@DEB-ULAUN|N"
          "Penguins Eggs|@DEB-EGGS|N")
fi

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
function _Ask(){
  if  [[ ${2} != "" ]]; then
    printf "${LGREEN}${1} ${YELLOW}[${2}]: ${RESTORE}"
    read REPLY
    if [[ ${REPLY} == "" ]] ; then REPLY="${2}" ; fi
  else
    printf "${LGREEN}${1}: ${RESTORE}"
    read REPLY
  fi
  REPLY=${REPLY^^}
}

function _AskYN(){
  local __flg="N"
  while [[ ${__flg} == "N" ]]
  do
    printf "${LGREEN}${1}? ${YELLOW}[${2}]: ${RESTORE}"
    read -n 1 REPLY
    if [[ ${REPLY} == "" ]] ; then REPLY="$2" ; else echo " "; fi

    case ${REPLY^^} in
      [Y]* ) __flg="Y";;
      [N]* ) __flg="Y";;
      [R]* ) __flg="Y";;
      * ) printf "${RED}ERROR - Invalid Option Entered [Y/N]${RESTORE}\n\n"; __flg="N";;
    esac
  done
  REPLY=${REPLY^^}
}

function _AskPass(){
  local __ret="UNKNOWN"
  local __ret2=""

  while [[ ${__ret} != ${__ret2} ]]
  do
    printf "${LCYAN}${1}: $RESTORE}"
    read -s __ret
    printf "\n${LCYAN}${1}: ${RESTORE}"
    read -s __ret2
    printf "\n"
    if [[ ${__ret^^} != ${__ret2^^} ]]; then
      printf "${RED}ERROR - Passwords do not match${RESTORE}\n\n"
    fi
  done
  REPLY=${__ret^^}
}

function _chooser() {
   if [ ${#APPList[@]} -gt 0 ]; then
     for i in {0..999}; do
        if (( i == ${#APPList[@]} )); then break; fi
        IFS='|' read -ra arr <<< "${APPList[i]}"
        if [ ${#arr[@]} -gt 0 ]; then
          if [[ "${arr[0]}" =~ ^"===" ]]; then
		     printf "\n${LPURPLE}${arr[0]}${RESTORE}\n"
          else
		     if (( $(_exists "${arr[1]}") == 0 )); then
                _AskYN "Install ${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
	         else
                _AskYN "Install $LRED${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
             fi
             _PKG_List ${REPLY^^} ${arr[1]}
	      fi
        fi
     done
   fi
}

function _default_apps {
   if [ ${#APPList[@]} -gt 0 ]; then
     _task-begin "Selecting Default Applications"
     for i in {0..999}; do
        if (( i == ${#APPList[@]} )); then break; fi
        IFS='|' read -ra arr <<< "${APPList[i]}"
        if [ ${#arr[@]} -gt 0 ]; then
          if [[ "${arr[0]}" =~ ^"===" ]]; then
		     _log-msg "${arr[0]}\n"
          else
		     if [[ ${arr[2]^^} == "Y" ]]; then _PKG_List "Y" ${arr[1]}; fi
	      fi
        fi
     done
	 _task-end
   fi
 }


#========================================================
#    Package Functions
#========================================================
function _exists() {
  local VAL0
  if [[ ${OS^^} != "ALPINE" ]]; then
     VAL=$(apt list --installed ${1} 2>/dev/null | grep -c "${1/\*/}")
  else
     VAL=$(apk list -I ${1} 2>/dev/null | grep -c "${1}")
  fi
  if (( ${VAL} == 0 )); then VAL=$(flatpak list | grep -ic "${1}"); fi
  printf "%u" ${VAL}
}

function _PKG_List() {
  local _Ans=${1^^}
  local _Pkg=${2}

  case ${_Ans^^} in
     Y) ADDList+=(${_Pkg}) ;;
     R) if [ ${_Pkg^^} == "CLAMAV" ]; then _Pkg="clam*"; fi
	    if [ ${_Pkg^^} == "LIBREOFFICE" ]; then _Pkg="libreoffice*"; fi
        if [ ${_Pkg^^} == "WINEHQ-STABLE" ]; then _Pkg="wine*"; fi
        if [ ${_Pkg^^} == "WINE" ]; then _Pkg="wine*"; fi
        if [ ${_Pkg^^} == "firefox" ]; then _Pkg="firefox*"; fi
        DELList+=(${_Pkg})
       ;;
  esac
}

function _add_pkg() {
  if (( $(_exists $1) == 0 )); then
     _task-begin "Installing ${1^^}"
     if [[ ${OS^^} != "ALPINE" ]]; then
        _run "apt install -y $1"
     else
        _run "apk add --upgrade $1"
     fi
     _task-end
  else
     _task-begin "${LRED}${1^^} Exists...Skipping"
     _task-end
  fi
}

function _add_by_list() {
  local _Pkgs=${*}
  if [ ${#_Pkgs} -gt 0 ]; then
    for _pkg in ${_Pkgs[@]}; do
	   if [[ ${_pkg:0:1} == "@" ]]; then
	      _add_special ${_pkg}
	   else
	      _add_pkg ${_pkg}
	   fi
    done
  fi
}

function _del_pkg() {
  if (( $(_exists $1) > 0 )); then
    _task-begin "Removing ${1^^}"
    if [[ ${OS^^} != "ALPINE" ]]; then
       _run "apt purge -y $1"
    else
       _run "apk del $1"
    fi
    _task-end
  fi
}

function _del_by_list() {
  local _Pkgs=${*}
  if [ ${#_Pkgs} -gt 0 ]; then
    for _pkg in ${_Pkgs[@]}; do
	   if [[ ${_pkg:0:1} == "@" ]]; then
	      _del_special ${_pkg}
	   else
	      _del_pkg ${_pkg}
	   fi
    done
  fi
}

function _add_flatpak {
  if [ $(flatpak list | grep -c ${2}) -eq 0 ]; then
    _task-begin "Installing Flatpak ${1^^}"
    _run "flatpak install flathub -y --noninteractive --reinstall ${2}"
	_task-end
 fi
}

function _del_flatpak {
  if [ $(flatpak list | grep -c ${2}) -gt 0 ]; then
    _task-begin "Removing Flatpak ${1^^}"
    _run "flatpak uninstall -y --noninteractive --force-remove --delete-data ${2}"
	_task-end
  fi
}

function _add_special() {
  local _key=${1:0:4}
  local _pkg=${1}
  
  case ${_key^^} in
     @DEB) case ${_pkg^^} in
	           @DEB-NOTE) _add_note;;
               @DEB-GOOGLE) _add_chrome;;
               @DEB-ULAUN) _add_ulauncher;;
               @DEB-ETCH) _add_etcher;;
               @DEB-EGGS) _add_eggs;;
               @DEB-RUST) _add_rust;;
		   esac
	       ;;
     @FLT) case ${_pkg^^} in
               @FLT-SEAL) _add_flatpak "FlatSeal" "com.github.tchx84.Flatseal";;
               @FLT-BRAVE) _add_flatpak "Brave Browser" "com.brave.Browser";;
               @FLT-ZOOM) _add_flatpak "Zoom Meeting" "us.zoom.Zoom";;
               @FLT-SEAL) _add_flatpak "Vivaldi Browser" "com.vivaldi.Vivaldi";;
               @FLT-ONLY) _add_flatpak "OnlyOffice" "org.onlyoffice.desktopeditors";;
               @FLT-CODE) _add_flatpak "VSCodium" "com.vscodium.codium";;
               @FLT-FLAME) _add_flatpak "Flameshot" "org.flameshot.Flameshot";;
               @FLT-CLAM) _add_flatpak "ClamTK" "com.github.davem.Clamtk";;
               @FLT-NOTEPAD) _add_flatpak "Notepadqq" "com.notepadqq.Notepadqq";;
               @FLT-NEXT) _add_flatpak "Notepad Next" "com.github.dail8859.NotepadNext";;
               @FLT-PLAY) _add_flatpak "Play On Linux" "com.playonlinux.PlayOnLinux4";;
               @FLT-BOOK) _add_flatpak "Calibre" "com.calibre_ebook.calibre";;
               @FLT-SPOT) _add_flatpak "Spotify" "com.spotify.Client";;
               @FLT-MAIL) _add_flatpak "Mailspring" "com.getmailspring.Mailspring";;
               @FLT-BLUE) _add_flatpak "Bluemail" "net.blix.Bluemail";;
		   esac
           ;;
  esac
}

function _del_special() {
  local _key=${1:0:4}
  local _pkg=${1}
  
  case ${_key^^} in
     @DEB) case ${_pkg^^} in
               @DEB-NOTE) _del_pkg "simplenote";;
               @DEB-GOOGLE) _del_pkg "google-chrome";;
               @DEB-ULAUN) _del_pkg "ulauncher";;
               @DEB-ETCH) _del_pkg "balena-etcher";;
               @DEB-EGGS) _del_pkg "eggs";;
               @DEB-RUST) _del_pkg "rust*";;
		   esac
	       ;;
     @FLT) case ${_pkg^^} in
               @FLT-SEAL) _del_flatpak "FlatSeal" "com.github.tchx84.Flatseal";;
               @FLT-BRAVE) _del_flatpak "Brave Browser" "com.brave.Browser";;
               @FLT-ZOOM) _del_flatpak "Zoom Meeting" "us.zoom.Zoom";;
               @FLT-SEAL) _del_flatpak "Vivaldi Browser" "com.vivaldi.Vivaldi";;
               @FLT-ONLY) _del_flatpak "OnlyOffice" "org.onlyoffice.desktopeditors";;
               @FLT-CODE) _del_flatpak "VSCodium" "com.vscodium.codium";;
               @FLT-FLAME) _del_flatpak "Flameshot" "org.flameshot.Flameshot";;
               @FLT-CLAM) _del_flatpak "ClamTK" "com.github.davem.Clamtk";;
               @FLT-NOTEPAD) _del_flatpak "Notepadqq" "com.notepadqq.Notepadqq";;
               @FLT-NEXT) _del_flatpak "Notepad Next" "com.github.dail8859.NotepadNext";;
               @FLT-PLAY) _del_flatpak "Play On Linux" "com.playonlinux.PlayOnLinux4";;
               @FLT-BOOK) _del_flatpak "Calibre" "com.calibre_ebook.calibre";;
               @FLT-SPOT) _del_flatpak "Spotify" "com.spotify.Client";;
               @FLT-MAIL) _del_flatpak "Mailspring" "com.getmailspring.Mailspring";;
               @FLT-BLUE) _del_flatpak "Bluemail" "net.blix.Bluemail";;
		   esac
	       ;;
  esac
}

function _add_chrome {
  local _URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  local CMD="install -y"
  
  _task-begin "Installing/Updating Google Chrome Browser"
  _run "rm -f ./google-chrome-stable_current_amd64.deb"
  _run "wget -q ${_URL}"
  if (( $( _exists "google-chrome" ) > 0 )); then CMD="reinstall -y"; fi
  _run "apt ${CMD} ./google-chrome-stable_current_amd64.deb"
  _run "rm -f ./google-chrome-stable_current_amd64.deb"
  _task-end
}

function _add_note {
  local CMD="install -y"
  local _REL=$(curl -sL https://api.github.com/repos/Automattic/simplenote-electron/releases/latest | jq -r ".tag_name")
  local _RELN=${_REL//M}
  local _URL="https://github.com/Automattic/simplenote-electron/releases/download/${_REL}/Simplenote-linux-${_RELN}-amd64.deb"

  _task-begin "Installing/Updating SimpleNote"
  _run "rm -f ./Simplenote-linux-${_RELN}-amd64.deb"
  _run "wget -q $_URL"
  if (( $( _exists "Simplenote-linux" ) > 0 )); then CMD="reinstall -y"; fi
  _run "apt ${CMD} ./Simplenote-linux-${_RELN}-amd64.deb"
  _run "rm -f ./Simplenote-linux-${_RELN}-amd64.deb"
  _task-end
}

function _add_rust {
  _task-begin "Installing/Updating Rust Development Environment"
  _task-end
}

function _add_etcher {
  local CMD="install -y"
  local _REL=$(curl -sL https://api.github.com/repos/balena-io/etcher/releases/latest | jq -r ".tag_name")
  local _RELN=${_REL//v}
  local _URL=" https://github.com/balena-io/etcher/releases/download/${_REL}/balena-etcher_${_RELN}_amd64.deb"

  _task-begin "Installing/Updating Balena Etcher"
  _run "rm -f ./balena-etcher_${_RELN}_amd64.deb"
  _run "wget -q ${_URL}"
  if (( $( _exists "balena-etcher" ) > 0 )); then CMD="reinstall -y"; fi
  _run "apt ${CMD} ./balena-etcher_${_RELN}_amd64.deb"
  _run "rm -f ./balena-etcher_${_RELN}_amd64.deb"
  _task-end
}

function _add_ulauncher {
  local CMD="install -y"
  local _REL=$(curl -sL https://api.github.com/repos/Ulauncher/Ulauncher/releases/latest | jq -r ".tag_name")
  local _RELN=${_REL//v}
  local _URL="https://github.com/Ulauncher/Ulauncher/releases/download/${_REL}/ulauncher_${_RELN}_all.deb"

  _task-begin "Installing/Updating Ulauncher"
  _run "rm -f ./ulauncher_${_RELN}_all.deb"
  _run "wget -q ${_URL}"
  if (( $( _exists "ulauncher" ) > 0 )); then CMD="reinstall -y"; fi
  _run "apt ${CMD} ./ulauncher_${_RELN}_all.deb"
  _run " rm -f ./ulauncher_${_RELN}_all.deb"
  _task-end
}

function _add_eggs {
   local CMD="install -y"
   local MyURL=$( curl -sl https://api.github.com/repos/pieroproietti/penguins-eggs/releases | grep -m 1 'browser_download_url' | sed -e 's/"//g' -e 's/ //g' -e 's/browser_download_url://' )
   local MyFILE=$( basename ${MyURL} )

  if [[ ! -z ${MyFILE} ]]; then
     _task-begin "Installing/Updating Penguins Eggs"
     _run "rm -f ./${MyFILE}"
     _run "wget -q ${MyURL}"
     if (( $( _exists "eggs" ) > 0 )); then CMD="reinstall -y"; fi
     _run "apt ${CMD} ./${MyFILE}"
     _run "rm -f ./${MyFILE}"
     _task-end
  fi
}

#========================================================
#    Processing Functions
#========================================================
function _parm_out {
    if [[ -f ${HDIR}/param.dat ]]; then rm -f ${HDIR}/param.dat; fi
    echo "DESKTOP=${DSK}" > ${HDIR}/param.dat
    echo "LAYOUT=${LAY}" >> ${HDIR}/param.dat
    _run "chown $SUDO_USER:$SUDO_USER ${HDIR}/param.dat"
}

function _parm_in {
   if [[ -f ${HDIR}/param.dat ]]; then
      grep "${1}" ${HDIR}/param.dat | cut -d'=' -f2
   fi
}

function _setValue {
   local KEY="$1"
   local VALUE="$2"
   if [ ${VALUE:0:1} == "'" ]; then
      _run "sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="$ADDR" dconf write ${KEY} \"${VALUE}\""
   else
      _run "sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="$ADDR" dconf write ${KEY} ${VALUE}"
   fi
}

function _getValue {
   local KEY="$1"
   local RET=$(sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="$ADDR" dconf read ${KEY})
   printf "${RET}"
}

function _install_nerdfonts {
   if [ ! -f ${HDIR}/.local/share/fonts/.setup ]; then
      if [ ! -d ${HDIR}/.local/share/fonts ]; then _run "mkdir -p ${HDIR}/.local/share/fonts"; fi
      if [ ! -d ${HDIR}/tmp ]; then _run "mkdir ${HDIR}/tmp"; fi
	  printf "\n${LPURPLE}=== Installing Nerd Fonts ===${RESTORE}\n"
      _run "cd ${HDIR}/tmp"
	  #local FONTList=("CascadiaCode" "DejaVuSansMono" "FiraCode" "Go-Mono" "Hack" "Inconsolata" "Iosevka" "JetBrainsMono"
      #                "LiberationMono" "Mononoki" "Noto" "RobotoMono" "SourceCodePro" "Terminus" "UbuntuMono" )
	  local FONTList=("CascadiaCode" "Inconsolata" "JetBrainsMono" "Terminus" )
      RET=$(curl -sL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r ".tag_name")
      for font in ${FONTList[@]}
      do
         URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${RET}/${font}.zip"
         _run "wget -q $URL"
         if [ -f $font.zip ]; then
		    _task-begin "Installing Font - $font"
            _run "unzip -o -q $font.zip -d ${HDIR}/.local/share/fonts/$font/"
	        _run "rm $font.zip"
			_task-end
         fi
     done
     _run "fc-cache"
     if [ -d ${HDIR}/tmp ]; then _run "rm -rf ${HDIR}/tmp"; fi
     _run "touch ${HDIR}/.local/share/fonts/.setup"
   fi
}

function _del_language {
  local PList=("hunspell-de-de-frami" "hunspell-de-at-frami" "hunspell-de-ch-frami"
               "hunspell-en-au" "hunspell-en-gb" "hunspell-en-za" "hunspell-es" "hunspell-fr-classical"
               "hunspell-fr" "hunspell-it" "hunspell-pt-br" "hunspell-pt-pt" "hunspell-ru" "hunspell-en-au")
  _del_by_list ${PList[*]}

  #=========== REMOVE Unused OS Language Packs ======================
  PList=("language-pack-bg" "language-pack-ca" "language-pack-cs" "language-pack-da"
         "language-pack-de" "language-pack-es" "language-pack-fr" "language-pack-hu"
         "anguage-pack-id" "language-pack-it" "language-pack-ja" "language-pack-ko"
         "language-pack-nb" "language-pack-nl" "language-pack-pl" "language-pack-pt"
         "language-pack-ru" "language-pack-sv" "language-pack-th" "language-pack-tr"
         "language-pack-uk" "language-pack-vi" "language-pack-zh-hans" "language-pack-zh-hant")
  _del_by_list ${PList[*]}

  #=========== REMOVE Unused GNOME Language Packs ======================
  PList=("language-pack-gnome-bg" "language-pack-gnome-ca" "language-pack-gnome-cs" "language-pack-gnome-da"
         "language-pack-gnome-de" "language-pack-gnome-es" "language-pack-gnome-fr" "language-pack-gnome-hu"
         "language-pack-gnome-id" "language-pack-gnome-it" "language-pack-gnome-ja" "language-pack-gnome-ko"
         "language-pack-gnome-nb" "language-pack-gnome-nl" "language-pack-gnome-pl" "language-pack-gnome-pt"
         "language-pack-gnome-ru" "language-pack-gnome-sv" "language-pack-gnome-th" "language-pack-gnome-tr"
         "language-pack-gnome-uk" "language-pack-gnome-vi" "language-pack-gnome-zh-hans" "language-pack-gnome-zh-hant")
  _del_by_list ${PList[*]}

  #=========== REMOVE Unused Language Packs ======================
  PList=("wbrazilian" "wbritish" "wbulgarian" "wcatalan" "wdanish" "wdutch" "wfrench" "wngerman" "wnorwegian"
         "wogerman" "wpolish" "wportuguese" "wspanish" "wswedish" "wswiss" "wukrainian")
  _del_by_list ${PList[*]}
}

function _setup_environment {
  printf "\n\n${LPURPLE}=== Updating OS Environment ===${RESTORE}\n"
  
  if [[ ${OS^^} != "ALPINE" ]]; then
     #============ ZRAM Tools Setup ===================
     if [ -f /etc/default/zramswap ]; then
        _task-begin "Update ZRAM Swap Configuration"
        _run "echo -e 'ALGO=zstd' | tee -a /etc/default/zramswap"
        _run "echo -e 'PERCENT=35' | tee -a /etc/default/zramswap"
        _task-end
     fi
     
     #================ Disable Root Account ===========
     _task-begin "Disable Root Account"
     _run "sed 's#root:/root:/bin/ash#root:/root:/sbin/nologin' /etc/passwd"
     _task-end
     
     #================ Change Shell to Bash ===========
     _task-begin "Change Shell to BASH"
     _run "sed 's#/bin/ash#/bin/bash#' /etc/passwd"
     _task-end
  fi

  #============ Setup Swappiness ===================
  _task-begin "Update Swap File Swappiness"
  _SWP=$(cat /etc/sysctl.conf | grep 'vm.swappiness' | cut -d "=" -f2)
  if [ -z ${_SWP} ]; then
    _run "echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf"
  else
    if [ ! ${_SWP} == "10" ]; then
      _run "sed -i 's/vm.swappiness=${_SWP}/vm.swappiness=10/g' /etc/sysctl.conf"
    fi
  fi
  _task-end
}

function _install_xfce {
  #============================ Install XFCE Desktop ============================================
  printf "\n\n${LPURPLE}=== Install XFCE Desktop  ===${RESTORE}\n\n"
  if (( $(_exists "xfce4") == 0 )); then
     printf "   ${LGREEN}=== Installing XFCE Desktop ===${RESTORE}\n"
     local PList=("")
     if [[ ${OS^^} != "ALPINE" ]]; then
        PList=("xorg" "xfce4" "xfce4-clipman" "xfce4-clipman-plugin" "xfce4-whiskermenu-plugin"
               "lightdm" "lightdm-gtk-greeter-settings" "lxterminal" "thunar" 
		       "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman" "volumeicon-alsa")
        _add_by_list ${PList[*]}
        _run "systemctl enable lightdm"
     else
        PList=("xfce4-clipman" "xfce4-clipman-plugin" "xfce4-whiskermenu-plugin" "lightdm"
               "lightdm-gtk-greeter-settings" "lxterminal" "thunar" "thunar-archive-plugin"
               "thunar-media-tags-plugin" "thunar-volman" "volumeicon-alsa")
        _task-begin "Installing XFCE Desktop Components" 
        _run "setup-desktop xfce"
        _task-end
        _add_by_list ${PList[*]}
        _run "rc-update add lightdm"
     fi
  else
     printf "   ${LRED}XFCE Desktop Exists..Skipping${RESTORE}\n"
  fi
}

function _install_budgie {
  #============================ Install Budgie Desktop ============================================
  printf "\n\n${LPURPLE}=== Install Budgie Desktop  ===${RESTORE}\n"
  if (( $(_exists "budgie-desktop") == 0 )); then
     printf "   ${LGREEN}=== Installing Budgie Desktop ===${RESTORE}\n"
     local PList=("xorg" "budgie-desktop" "budgie-indicator-applet" "gnome-control-center"
                  "lightdm" "lightdm-gtk-greeter-settings" "plank" "dialog" "lxterminal"
		          "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman-plugin" "volumeicon-alsa")
     _add_by_list ${PList[*]}
     _run "systemctl enable lightdm"
  else
     printf "   ${LRED}Budgie Desktop Exists..Skipping${RESTORE}\n"  
  fi
}

function _install_cinnamon {
  #============================ Install Cinnamon Desktop ============================================
  printf "\n\n${LPURPLE}=== Install Cinnamon Desktop  ===${RESTORE}\n"
  if (( $(_exists "cinnamon-core") == 0 )); then
     printf "   ${LGREEN}=== Installing Budgie Desktop ===${RESTORE}\n"
     local PList=("cinnamon-desktop-environment" "gnome-control-center"
	              "lightdm" "lightdm-gtk-greeter-settings")
     _add_by_list ${PList[*]}
     _run "systemctl enable lightdm"
  else
     printf "   ${LRED}Cinnamon Desktop Exists..Skipping${RESTORE}\n"  
  fi
}

function _get_setup_file {
   _task-begin "Download Customization File"
   if [ ! -d ${HDIR}/sys-setup ]; then
      _run "cd ${HDIR}"
      _run "mkdir ${HDIR}/sys-setup"
   fi

   #Download file
   if [ ! -f ${HDIR}/sys-setup/sys.zip ]; then
     _run "cd ${HDIR}/sys-setup"
     _run "wget -q https://tinyurl.com/base-setup"
     if [ -f ${HDIR}/sys-setup/base-setup ]; then
       _run "mv -f base-setup sys.zip"
       _run "unzip -o -q sys.zip"
     fi
     _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/sys-setup"
     _run "cd ${HDIR}"
   fi
   _task-end
}

function _customize_user_environment {
   _task-begin "Setup User Environment"
   #Backgrounds
   if [ ! -f /usr/share/backgrounds/.setup ]; then
      _run "mv -f ${HDIR}/sys-setup/backgrounds/* /usr/share/backgrounds"
      _run "touch /usr/share/backgrounds/.setup"
   fi

   #Start Icons
   if [ ! -d /usr/share/icons/start ]; then _run "mkdir -p /usr/share/icons/start"; fi
   if [ ! -f /usr/share/icons/start/.setup ]; then
      _run "mv -f ${HDIR}/sys-setup/start/* /usr/share/icons/start/"
      _run "touch /usr/share/icons/start/.setup"
   fi

   #User Files
   if [ ! -f ${HDIR}/.hushlogin ]; then
      _run "mv -f ${HDIR}/sys-setup/.bashrc ${HDIR}"
      _run "mv -f ${HDIR}/sys-setup/.bash_aliases ${HDIR}"
      _run "mv -f ${HDIR}/sys-setup/.hushlogin ${HDIR}"
	  if [ ${SUDO_USER^^} == "MARTIN" ]; then _run "mv -f ${HDIR}/sys-setup/bookmarks.html ${HDIR}"; fi
   fi
   _task-end

   #Download Script File
   _task-begin "Install Script Directory"
   if [ -d ${HDIR}/Scripts ]; then _run "rm -rf ${HDIR}/Scripts/"; fi
   _run "mkdir -p ${HDIR}/Scripts/"
   _run "cd ${HDIR}/Scripts"
   _run "wget -q https://tinyurl.com/scr-dir"
   if [ -f ${HDIR}/Scripts/scr-dir ]; then
      _run "mv -f scr-dir script.zip"
      _run "unzip -o -q script.zip"
      _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/Scripts/"
   fi
   _run "cd ${HDIR}"
   _task-end   
}

function _customize_icons {
   if [ -f ${HDIR}/sys-setup/sys.zip ]; then
      _task-begin "Install Icons"
      case ${LAY^^} in
         1|3) if [ ! -d /usr/share/icons/'Boston cardboard' ]; then
			     _run "mv -f ${HDIR}/sys-setup/icons/Boston-Cardboard.tar.xz /usr/share/icons/"
			     _run "cd /usr/share/icons/"
		         _run "tar -xf Boston-Cardboard.tar.xz"
				 _run "rm -f Boston-Cardboard.tar.xz"
                 _run "gtk-update-icon-cache /usr/share/icons/Boston-Cardboard"
		      fi
			  _run "apt install -y gnome-dust-icon-theme"
 	          ;;
         2|4) if [ ! -d /usr/share/icons/Boston ]; then
		   		 _run "mv -f ${HDIR}/sys-setup/icons/Boston.tar.xz /usr/share/icons"
				 _run "cd /usr/share/icons/"
		         _run "tar -xf Boston.tar.xz"
				 _run "rm -f Boston.tar.xz"
                 _run "gtk-update-icon-cache /usr/share/icons/Boston"
		      fi 
              if [ ! -d /usr/share/icons/Flatery-Sky ]; then
		   		 _run "mv -f ${HDIR}/sys-setup/icons/Flatery-Sky.tar.gz /usr/share/icons"
				 _run "cd /usr/share/icons/"
		         _run "tar -xf Flatery-Sky.tar.gz"
				 _run "rm -f Fatery-Sky.tar.gz"
                 _run "gtk-update-icon-cache /usr/share/icons/Flatery-Sky"
		      fi 
			  ;;
      esac
	  _run "cd ${HDIR}"
	  _task-end
   fi
}

function _customize_themes {
   if [ -f ${HDIR}/sys-setup/sys.zip ]; then
      _task-begin "Install Themes"
	  case ${LAY} in
        1|3) if [ ! -d /usr/share/themes/Orchis-Yellow-Dark ]; then
                _run "cd /usr/share/themes/"
		        _run "wget -q https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Yellow.tar.xz"
				_run "tar -xf Orchis-Yellow.tar.xz"
				_run "rm -f Orchis-Yellow.tar.xz"
				_run "rm -rf Orchis-Yellow-Compact"
				_run "rm -rf Orchis-Yellow-Dark-Compact"
				_run "rm -rf Orchis-Yellow-Light*"
				_run "rm -rf Orchis-Yellow"
             fi
             if [ ! -d /usr/share/themes/Orchis-Teal-Dark ]; then
                _run "cd /usr/share/themes/"
		        _run "wget -q https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Teal.tar.xz"
			    _run "tar -xf Orchis-Teal.tar.xz"
				_run "rm -f Orchis-Teal.tar.xz"
				_run "rm -rf Orchis-Teal-Compact"
				_run "rm -rf Orchis-Teal-Dark-Compact"
				_run "rm -rf Orchis-Teal-Light*"
				_run "rm -rf Orchis-Teal"
             fi
             if [ ! -d /usr/share/themes/Skeuos-Yellow-Dark ]; then
                _run "cd /usr/share/themes"
			    _run "mv -f ${HDIR}/sys-setup/themes/Skeuos-Yellow.tar.xz /usr/share/themes"
				_run "cd /usr/share/themes/"
		        _run "tar -xf Skeuos-Yellow.tar.xz"
				_run "rm -f Skeuos-Yellow.tar.xz"
				_run "rm -rf Skeuos-Yellow-Light-*"
				_run "rm -rf Skeuos-Yellow-Dark-*"
             fi
			 _run "apt install -y gnome-dust-icon-theme"
			 _run "apt install -y tango-icon-theme"
 	         ;;
        2|4) if [ ! -d /usr/share/themes/Orchis-Dark ]; then
                _run "cd /usr/share/themes/"
		        _run "wget -q https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis.tar.xz"
		        _run "tar -xf Orchis.tar.xz"
				_run "rm -f Orchis.tar.xz"
				_run "rm -rf Orchis-Compact"
				_run "rm -rf Orchis-Dark-Compact"
				_run "rm -rf Orchis-Light*"
				_run "rm -rf Orchis"
             fi
             if [ ! -d /usr/share/themes/Skeuos-Blue-Dark ]; then
                _run "cd /usr/share/themes"
			    _run "mv -f ${HDIR}/sys-setup/themes/Skeuos-Blue.tar.xz /usr/share/themes"
				_run "cd /usr/share/themes/"
		        _run "tar -xf Skeuos-Blue.tar.xz"
				_run "rm -f Skeuos-Blue.tar.xz"
				_run "rm -rf Skeuos-Blue-Light-*"
				_run "rm -rf Orchis-Blue-Dark-F*"
				_run "rm -rf Orchis-Blue-Dark-G*"
				_run "rm -rf Orchis-Blue-Dark-X*"
             fi
			 _run "apt install -y gnome-icon-theme"
			 _run "apt install -y tango-icon-theme"
			 ;;
      esac
	  _run "cd ${HDIR}"
	  _task-end
   fi
}

function _customize_lightdm {
   if [ -f ${HDIR}/sys-setup/sys.zip ]; then
      if [ ! -f /etc/lightdm/.setup ]; then
         _task-begin "Install LightDM Configuration"	  
         DSK=$(_parm_in "DESKTOP")
         LAY=$(_parm_in "LAYOUT")
         case ${OS^^} in
            'LINUXMINT') DSK=3; LAY=3 ;;
               'SPARKY') DSK=1; LAY=1 ;;
           'PEPPERMINT') DSK=1; LAY=1 ;;
               'ALPINE') DSK=1; LAY=1 ;;
         esac  
         
         _run "cd ${HDIR}/sys-setup/lightdm"
		 # === Setup the LIGHTDM.CONF File ===
         local _FILE=/etc/lightdm/lightdm.conf
         if [ -f ${_FILE} ]; then _run "mv -f ${_FILE} ${_FILE}.bak"; fi
         local PRT="[LightDM]\n#\n[Seat:*]\ngreeter-hide-users=false\n#\n[XDMCPServer]\n#\n[VNCServer]\n#\n"
         printf "${PRT}" | tee ${_FILE} >/dev/null

		 # === Setup the LIGHTDM-GTK-GREETER.CONF File ===
         _FILE=/etc/lightdm/lightdm-gtk-greeter.conf
         if [ -f ${_FILE} ]; then _run "mv -f ${_FILE} ${_FILE}.bak"; fi
         PRT="[greeter]\n"
	     case ${LAY} in
            1|3) PRT="${PRT}background=/usr/share/backgrounds/iB38gbGjiAxVdT2h.jpg\n"
                 PRT="${PRT}theme-name=Orchis-Teal-Dark\n"
                 PRT="${PRT}icon-theme-name = Tango\n"
                 PRT="${PRT}postition='66%%,center 55%%,center'\n"
                 ;;
            2|4) PRT="${PRT}background=/usr/share/backgrounds/8pplzWJvxVoxqrCE.jpg\n"
                 PRT="${PRT}theme-name=Orchis-Dark\n"
                 PRT="${PRT}icon-theme-name=Tango\n"   
                 PRT="${PRT}postition='80%%,center 55%%,center'\n"
 	             ;;
         esac
         PRT="${PRT}user-background=false\n"
         PRT="${PRT}default-user-image=/usr/share/icons/pirate.jpg\n"
         PRT="${PRT}font-name=SauceCodePro Nerd Font 12\n"
         PRT="${PRT}show-clock=true\n"
         PRT="${PRT}clock-format='%%a %%d %%b %%I:%%M %%p'\n"
         printf "${PRT}" | tee ${_FILE} >/dev/null
	     _run "touch /etc/lightdm/.setup"
	     _run "cd ${HDIR}"
         printf "${OVERWRITE}"
		 _task-end
      fi
   fi
}

function _customize_grub {
   if [ ! -f /boot/grub/.setup ]; then
      if [ ! -d ${HDIR}/sys-setup ]; then _run "mkdir -p ${HDIR}/sys-setup"; fi
	  _task-begin "Install Grub Background"
      _run "cd ${HDIR}/sys-setup/"
	  if [ -d ${HDIR}/sys-setup/grub2-themes ]; then _run "rm -rf ${HDIR}/sys-setup/grub2-themes"; fi
	  _run "git clone https://github.com/vinceliuice/grub2-themes"
	  if [ -d ${HDIR}/sys-setup/grub2-themes ]; then
         _run "cd ${HDIR}/sys-setup/grub2-themes"
	     _run "${HDIR}/sys-setup/grub2-themes/install.sh -b -t vimix"
	     _run "touch /boot/grub/.setup"
      fi
	  _run "cd ${HDIR}"
      _task-end	  
   fi
}

function _customize_lxterminal {
   if (( $(_exists "lxterminal") > 0 )); then
      if [ ! -f ${HDIR}/.config/lxterminal/.setup ]; then
	     _task-begin "Install LXTerminal Setup"
         if [ ! -d ${HDIR}/.config/lxterminal/ ]; then _run "mkdir -p ${HDIR}/.config/lxterminal"; fi
         _run "cd ${HDIR}/sys-setup/applications/lxterminal"
         _run "mv -f * ${HDIR}/.config/lxterminal/"
         _run "touch ${HDIR}/.config/lxterminal/.setup"
         _run "cd ${HDIR}"
         
         #fontname=Monospace 14
         #bgcolor=rgb(0,0,0)
         #fgcolor=rgb(170,170,170)
        _task-end		 
      fi
   fi
}

function _customize_plank {
   if (( $(_exists "plank") > 0 )); then
      if [ -d ${HDIR}/sys-setup/plank ]; then
         if [ ! -f /usr/share/plank/themes/.setup ]; then
		    _task-begin "Install Plank Themes & Setup Files"
	        _run "cd ${HDIR}/sys-setup/plank/themes"
	        _run "mv -f * /usr/share/plank/themes"
	        if [ ! -d ${HDIR}/.config/plank/dock1/launchers/ ]; then _run "mkdir -p ${HDIR}/.config/plank/dock1/launchers"; fi
	        _run "cd ${HDIR}/sys-setup/plank/dock1/launchers/"
	        _run "mv -f * ${HDIR}/.config/plank/dock1/launchers/"
	        _run "sudo -u $SUDO_USER dconf load /net/launchpad/plank/docks/ < ${HDIR}/sys-setup/plank/docks.ini"
	        _run "touch /usr/share/plank/themes/.setup"
	        _run "cd ${HDIR}"
			_task-end
	     fi
      fi
   fi
}

function _customize_autostart {
   if [ ! -d ${HDIR}/.config/autostart/ ]; then _run "mkdir -p ${HDIR}/.config/autostart/"; fi
   if [ -d ${HDIR}/sys-setup/autostart ]; then
      if [ ! -f ${HDIR}/.config/autostart/.setup ]; then
	     _task-begin "Setting Up Autostart Files"
         _run "cd ${HDIR}/sys-setup/autostart"
         if (( $(_exists "numlockx") > 0 )); then _run "mv -f numlockx.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_exists "plank") > 0 )); then _run "mv -f plank.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_exists "flameshot") > 0 )); then _run "mv -f org.flameshot.Flameshot.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_exists "ulauncher") > 0 )); then _run "mv -f ulauncher.desktop ${HDIR}/.config/autostart/"; fi
         _run "touch ${HDIR}/.config/autostart/.setup"
         _run "cd ${HDIR}"
		 _task-end
      fi
   fi
}

function _customize_shortcuts {
   _task-begin "Create Desktop Keyboard Shortcuts"
   _run "touch ${HDIR}/shortcut.dconf"
   printf "[custom0]\nbinding='<Primary><Alt>s'\ncommand='flameshot gui'\nname='flameshot gui'\n\n" > ${HDIR}/shortcut.dconf
   printf "[custom1]\nbinding='<Primary><Alt>b'\ncommand='balena-etcher'\nname='balena-etcher'\n\n" >> ${HDIR}/shortcut.dconf
   printf "[custom2]\nbinding='<Primary><Alt>n'\ncommand='numlockx off'\nname='NumlockX'\n\n" >> ${HDIR}/shortcut.dconf
   printf "[custom3]\ncommand='<Primary><Alt>m'\nname='chromium-browser https://gmail.com'\n\n" >> ${HDIR}/shortcut.dconf
   printf "[custom4]\ncommand=''\nname=''\n\n" >> ${HDIR}/shortcut.dconf
   printf "[custom5]\ncommand=''\nname=''\n\n" >> ${HDIR}/shortcut.dconf
   printf "[custom6]\ncommand=''\nname=''\n\n" >> ${HDIR}/shortcut.dconf
   _run "dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < ${HDIR}/shortcut.dconf"
   _run "rm -f ${HDIR}/shortcut.dconf"
   _task-end
}

function _customize_fstab {
   if [[ ${SUDO_USER^^} == "MARTIN" ]]; then
      _task-begin "Setup Network Shares"
      RET=$( cat /etc/fstab | grep -c "10.10.10.25" )
      if [ ${RET} == "0" ]; then
         echo ""  >> /etc/fstab
         echo "//10.10.10.25/documents  /media/documents  cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,iocharset=utf8 0 0" >> /etc/fstab
         echo "//10.10.10.25/utilities  /media/utilities  cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,iocharset=utf8 0 0" >> /etc/fstab
         echo "//10.10.10.25/multimedia /media/multimedia cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,iocharset=utf8 0 0" >> /etc/fstab
         echo "//10.10.10.25/backups    /media/backups    cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,iocharset=utf8 0 0" >> /etc/fstab
         echo "//10.10.10.25/private    /media/private    cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,iocharset=utf8 0 0" >> /etc/fstab
      fi
     _task-end
      
      # Setup Network Credentials
      _run "printf '\n'"
      _Ask "Enter Network Username"
      local UNAME=${REPLY}
      _AskPass "Enter Network Password"
      local PASS=${REPLY}
      _run "rm -f ${HDIR}/.smbcredentials"
      _run "touch ${HDIR}/.smbcredentials"
      _run "printf 'username=$UNAME\npassword=$PASS\n' | tee -a ${HDIR}/.smbcredentials"
      _run "chmod 600 ${HDIR}/.smbcredentials"
      _run "printf '\n'"
   fi
}

function _customize_budgie {
   if (( $(_exists "budgie-desktop") > 0 )); then
      if [ ! -f /usr/share/backgrounds/budgie/.setup ]; then
         if [ -d ${HDIR}/sys-setup/budgie ]; then
			local _STYLE=""
            local _THEME=""
            local _ICON=""

			# ====== Yellow Backgrounds ======
			# vyYvUseebgNgzzGQ.jpg   # Yellow Misty Lake
			# eGna2qBdawpRZpuq.jpg   # Yellow Tree
			# auUagbqqV2gbGi8w.jpg   # Yellow Toronto

            # ====== Blue Backgrounds ======
			# 8pplzWJvxVoxqrCE.jpg   # Volcano Lake
			# oC8iorz2BlyAeEQi.jpg   # Blue Dock
			# Cv0ZEeqOw7vMz1ez.jpg   # Blue Toronto            
            case ${LAY^^} in
              1) _THEME="Skeuos-Yellow-Dark"
                 _ICON="gnome-dust"
                 _STYLE="budgie_top_yellow.dconf"
                 _BACK="eGna2qBdawpRZpuq.jpg"
                 ;;
              2) _THEME="Orchis-Dark"
                 _ICON="Boston"
                 _STYLE="budgie_top_blue.dconf" 
                 _BACK="oC8iorz2BlyAeEQi.jpg"
                 ;;
              3) _THEME="Skeuos-Yellow-Dark"
                 _ICON="gnome-dust"
                 _STYLE="budgie_bottom_yellow.dconf" 
                 _BACK="eGna2qBdawpRZpuq.jpg"
                 ;;
              4) _THEME="Orchis-Dark"
                 _ICON="Boston"
                 _STYLE="budgie_bottom_blue.dconf"                 
                 _BACK="oC8iorz2BlyAeEQi.jpg"
                 ;;
            esac

            # Install Custom Icons & Themes
	        _customize_icons
		    _customize_themes

            _task-begin "Customize Budgie Desktop"
            _run "sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="$ADDR" dconf load / < ${HDIR}/sys-setup/budgie/${_STYLE}"
            _task-end

            _task-begin "Set Power Settings"
            _setValue "/org/gnome/settings-daemon/plugins/power/idle-dim" "true"
            _setValue "/org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout" "1200"
            _setValue "/org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout" "1200"
            _task-end

            _task-begin "Set Theme & Icons for Desktop"
            _setValue "/org/gnome/desktop/interface/cursor-theme" "'Adwaita'"
            _setValue "/org/gnome/desktop/interface/gtk-theme" "'${_THEME}'"
            _setValue "/org/gnome/desktop/interface/icon-theme" "'${_ICON}'"
            _setValue "/org/gnome/desktop/interface/document-font-name" "'Sans 11'"
            _setValue "/org/gnome/desktop/interface/font-name" "'Sans 11'"
            _setValue "/org/gnome/desktop/interface/monospace-font-name" "'Monospace 11'"
            _task-end

            _task-begin "Set Desktop Background"
	        _run "rm /usr/share/backgrounds/budgie/default.jpg"
	        _run "cp -f /usr/share/backgrounds/${_BACK} /usr/share/backgrounds/budgie/default.jpg"
            _task-end
            
            _run "touch /usr/share/backgrounds/budgie/.setup"
         fi
      fi
   fi
}

function _customize_xfce {
   if (( $(_exists "xfce4") > 0 )); then
      if [ -d ${HDIR}/.config/xfce4 ]; then
         if [ ! -f ${HDIR}/.config/xfce4/.setup ]; then
		    if [ -d ${HDIR}/sys-setup/xfce4 ]; then
			   local _STYLE=""
			   local _TYPE=""
               local _MENU=""
               local VAL1=""
               local VAL2=""
               local TMP=""
	           local PList=("xfce4-clipman" "xfce4-clipman-plugin" "xfce4-whiskermenu-plugin"
                            "lightdm" "lightdm-gtk-greeter-settings" "lxterminal" "thunar"
			                "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman")
			   _add_by_list ${PList[*]}

			   _task-begin "Clear Existing XFCE Configuration"
               _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.config/xfce4/"
	           _run "rm -rf ${HDIR}/.config/xfce4/*"
               _task-end

			   # ====== Yellow Backgrounds ======
			   # vyYvUseebgNgzzGQ.jpg   # Yellow Misty Lake
			   # eGna2qBdawpRZpuq.jpg   # Yellow Tree
			   # auUagbqqV2gbGi8w.jpg   # Yellow Toronto
			
			   # ====== Blue Backgrounds ======
			   # 8pplzWJvxVoxqrCE.jpg   # Volcano Lake
			   # oC8iorz2BlyAeEQi.jpg   # Blue Dock
			   # Cv0ZEeqOw7vMz1ez.jpg   # Blue Toronto   
               case ${LAY^^} in
                  1) _STYLE="xfce_top_yellow.zip" 
                     _TYPE="Top"
                     _MENU="menu_13.png"
                     ;;
                  2) _STYLE="xfce_top_blue.zip" 
                     _TYPE="Top"
                     _MENU="menu_05.png"
                     ;;
                  3) _STYLE="xfce_bottom_yellow.zip" 
                     _TYPE="Bottom"
                     _MENU="menu_13.png"
                     ;;
                  4) _STYLE="xfce_bottom_blue.zip" 
                     _TYPE="Bottom"
                     _MENU="menu_05.png"
                     ;;
               esac

               # Install Custom Icons & Themes
	           _customize_icons
		       _customize_themes

			   _task-begin "Download XFCE ${_TYPE} Menu Configuration"
               _run "cd ${HDIR}/.config/xfce4/"
	           _run "rm -rf ${HDIR}/.config/xfce4/*"
               _run "mv -f ${HDIR}/sys-setup/xfce4/${_STYLE} ${HDIR}/.config/xfce4/"
               _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.config/xfce4/"
			   _run "unzip -o -q ${_STYLE}"
               _run "rm -f ${HDIR}/.config/xfce4/${_STYLE}"
               _run "cd ${HDIR}"
			   _task-end

                  
			   # Change the Menu Icon
			   _task-begin "Change Whiskermenu Icon"
               _run "cd ${HDIR}/.config/xfce4/"
               VAL1=$(grep -rl 'button-icon=' | grep -v 'show-button') >/dev/null 2>&1
			   for file in ${VAL1}; do
                  if [ -f "$file" ]; then
		             VAL2=$(grep -h 'button-icon=' ${file} | grep -v 'show-button' | cut -d'=' -f2) >/dev/null 2>&1
                     TMP="sed -i 's#${VAL2}#/usr/share/icons/start/${_MENU}#g' ${file}"
                     _log-msg "Running ${TMP}"
			         _run "${TMP}"
                  fi
               done
			   _task-end
               
               _run "cd ${HDIR}"
               _run "touch ${HDIR}/.config/xfce4/.setup"
	        fi
         fi
      fi
   fi
}

function _customize_cinnamon {
   if (( $(_exists "cinnamon") > 0 )); then
      if [ ! -f ${HDIR}/.config/cinnamon/.setup ]; then
         if [ -d ${HDIR}/sys-setup/cinnamon ]; then
			# === Yellow Backgrounds ===
			# vyYvUseebgNgzzGQ.jpg  # Yellow Misty Lake
			# eGna2qBdawpRZpuq.jpg  # Yellow Tree
			# auUagbqqV2gbGi8w.jpg  # Yellow Toronto
			
			# === Blue Backgrounds ===
			# 8pplzWJvxVoxqrCE.jpg  # Volcano Lake
			# oC8iorz2BlyAeEQi.jpg  # Blue Dock
			# Cv0ZEeqOw7vMz1ez.jpg  # Blue Toronto
            
			local COLOR=""
            local BACK=""
            local THEME=""
            local ICON=""
            local DIR=""
            
            case ${LAY^^} in
              #  ================= Yellow Theme ===================
              1) COLOR="YELLOW"
                 BACK="eGna2qBdawpRZpuq.jpg"
                 THEME="Skeuos-Yellow-Dark"
                 ICON="gnome-dust"
                 MENU="menu_13.png"
	             ;;
              # ================ Blue Theme ====================
              2) COLOR="BLUE"
                 BACK="oC8iorz2BlyAeEQi.jpg"
                 THEME="Orchis-Dark"
                 ICON="Boston"
                 MENU="menu_05.png"
	             ;;
            esac

			_customize_icons
		    _customize_themes

			#_task-begin "Install $COLOR Cinnamon Desktop"
            #_run "sudo -u $SUDO_USER dconf load / < ${HDIR}/sys-setup/cinnamon/cinnamon.dconf"
            #_task-end
            
            _task-begin "Set Desktop Background Folders"
			DIR="${HDIR}/.config/cinnamon/backgrounds/"
            if [[ ! -d ${DIR} ]]; then _run "mkdir -p $DIR"; fi
			if [[ -f ${DIR}/user-folders.lst ]]; then _run "rm -f ${DIR}/user-folders.lst"; fi
            _run "echo '/home/${SUDO_USER}/Pictures' > ${_DIR}/user-folders.lst"
            _run "echo '/user/share/backgrounds' >> ${_DIR}/user-folders.lst"
            _task-end
			
            _task-begin "Set Desktop Theme & Icon"
            _setValue "/org/cinnamon/theme/name" "'$THEME'"
            _setValue "/org/cinnamon/desktop/interface/gtk-theme" "'$THEME'"
            _setValue "/org/cinnamon/desktop/interface/cursor-theme" "'$CURSOR'"
            _setValue "/org/cinnamon/desktop/interface/icon-theme" "'$ICON'"
            _task-end
            
            _task-begin "Set Desktop Effects"
            _setValue "/org/cinnamon/desktop-effects" "false"
            _setValue "/org/cinnamon/desktop/interface/clock-show-date" "false"
            _setValue "/org/cinnamon/desklet-decorations" "0"
            _setValue "/org/cinnamon/startup-animation" "false"
            _task-end
            
            _task-begin "Set Background Image"
            _setValue "/org/cinnamon/desktop/background/picture-options" "'zoom'"
            _setValue "/org/cinnamon/desktop/background/picture-uri" "'file:///usr/share/backgrounds/$BACK'"
            _task-end
      
            _task-begin "Set Menu Icon"
			CDIR="${HDIR}/.config/cinnamon/spices/menu@cinnamon.org"
			local PASS1=$(jq '.["menu-custom"] |= (.value = true)' ${CDIR}/0.json)
            local PASS2=$(echo $PASS1 | jq '.["menu-icon"] |= (.value = "/usr/share/icons/start/==MENU==")')
            local PASS3=$(echo $PASS2 | jq '.["menu-label"] |= (.value = "")')
            if [[ ! -z $PASS3 ]]; then
			   if [[ -f $CDIR/0.json ]]; then _run "rm -f $CDIR/0.json"; fi
               printf "${PASS3/==MENU==/$MENU}" >${CDIR}/0.json
            fi
            _task-end
            
            _run "touch ${HDIR}/.config/cinnamon/.setup"		 
         fi
      fi
   fi
}

function _process_step_1 {
   printf "\n  ${YELLOW}Step 1 - Install Desktop Environment${RESTORE}\n\n"
   if [[ ! -f ${LOG} ]]; then _run "rm -f ${LOG}"; fi
   _run "touch ${LOG}"
   _run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"
  
   #=============================
   # Install Desktop Environment
   #=============================
   while [[ ${DSK^^} != "99" ]]
   do
     _desktop_menu
	 _layout_menu
     case ${DSK^^} in
         1) _install_xfce; break ;;
         2) _install_budgie; break ;;
         3) _install_cinnamon; break;;
        99) break ;;
     esac
   done

   #==================================
   # Remove non required applications
   #==================================
   local PList=("cheese" "firefox" "firefox-esr" "libreoffice*" "mousepad" "synaptic" "thunderbird")
   printf "\n${LPURPLE}=== Remove Unrequired Packages ===${RESTORE}\n"
   _del_by_list ${DELList[*]}
   _del_by_list ${PList[*]}
   if [[ ${OS^^} != "ALPINE" ]]; then _run "apt autoremove -y"; fi

   #==================================
   # Restarting System
   #==================================
   printf "\n\n${LPURPLE}=== Restarting System - End of Step 1 ===${RESTORE}\n"
   _AskYN "OK to Reboot Now (y/n)" "Y"
   if [ ${REPLY^^} = "Y" ]; then reboot; fi
}

function _process_step_2 {
  printf "\n  ${YELLOW}Step 2 - Update System Configuration${RESTORE}\n\n"
  if [[ ! -f ${LOG} ]]; then _run "rm -f ${LOG}"; fi
  _run "touch ${LOG}"
  _run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"
  
  # === Get Desktop Parameters ===
  _task-begin "Get Desktop Parameter File"
  DSK=$(_parm_in "DESKTOP")
  LAY=$(_parm_in "LAYOUT")
  _task-end

  #===============================
  # Upgrade Linux Reposistories
  #===============================
  _task-begin "Updating Linux Reposistory Permissions"
  if [[ ! -f /etc/apt/apt.conf.d/10sandbox ]]; then touch /etc/apt/apt.conf.d/10sandbox; fi
  _run "echo 'APT::Sandbox::User \"root\"; >> /etc/apt/apt.conf.d/10sandbox'"
  _run "apt update"
  _task-end

  if [[ ${OS^^} == "ALPINE" ]]; then 
     #================================
     # Update Alpine Terminal Profile
     #================================
     _task-begin "Update Alpine Terminal Profile"
     RET=$( cat /etc/profile | grep -c 'PS1="\[\033}' )
     if [ ${RET} == 0 ]; then
        echo "PS1='${PS1}'" >> /etc/profile
	    echo "export PS1" >> /etc/profile
     fi
     _task-end
     
     #=============================
     # Remove Alpine MOTD
     #=============================
     _task-begin "Removing MOTD"
     if [ -f /etc/motd ]; then _run "rm /etc/motd"; fi
     _task-end	 
  fi
  
  #===============================
  # Install required system files
  #===============================
  printf "\n${LPURPLE}=== Install Required System Files ===${RESTORE}\n"
  local PList=("7zip" "acpi" "acpid" "alsa-utils" "apt-transport-https" "avahi-utils" "bash"
               "bash-completion" "bluez" "blueman" "cifs-utils" "cups" "curl" "dconf-cli"
			   "dbus-x11" "git" "gvfs" "gvfs-backends" "jq" "neofetch" "nano" "pipewire"
               "pipewire-alsa" "pipewire-audio" "pipewire-pulse" "libspa-0.2-bluetooth"
               "preload" "sed" "sudo" "udisks2" "unzip" "wget" "zram-tools")
  if [[ ${OS^^} == "ALPINE" ]]; then PList+=("avahi" "dconf" "gvfs-fuse" "gvfs-smb" "gvfs-mtp" "gvfs-nfs" "pipewire-spa-bluez"); fi      
  _add_by_list ${PList[*]}

  #===============================
  # Install required system repos
  #===============================
  _task-begin "Install System Repos"
  if [[ "ELEMENTARY UBUNTU" == *${OS^^}* ]]; then
     local RList=("ppa:philip.scott/pantheon-tweaks" "ppa:linrunner/tlp")
     _add_repo_by_list ${RList[*]}
     _run "apt update"	 
  fi
  _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
  printf "${OVERWRITE}"
  _task-end

  #===============================
  # Create Network Mount Points
  #===============================
  printf "\n${LPURPLE}=== Setup System Files ===${RESTORE}\n"
  _task-begin "Create Network Mount Points"
  if [ ! -d /media/documents ]; then _run "mkdir /media/documents"; fi
  if [ ! -d /media/utilities ]; then _run "mkdir /media/utilities"; fi
  if [ ! -d /media/multimedia ]; then _run "mkdir /media/multimedia"; fi
  if [ ! -d /media/backups ]; then _run "mkdir /media/backups"; fi
  if [ ! -d /media/private ]; then _run "mkdir /media/private"; fi
  _task-end

  #=============================
  # Change SSH Config File
  #=============================
  _task-begin "Updating SSH Configuration"
  if [ -f /etc/ssh/sshd_config ]; then
	 sed -i "s/#Port 22/Port 9922/" /etc/ssh/sshd_config >/dev/null 2>&1
  fi
  _task-end

  #===============================
  # Create User Directories
  #===============================
  _task-begin "Create User Directories"
  if [ ! -d ${HDIR}/Documents ]; then _run "mkdir ${HDIR}/Documents"; fi
  if [ ! -d ${HDIR}/Downloads ]; then _run "mkdir ${HDIR}/Downloads"; fi
  if [ ! -d ${HDIR}/Pictures ]; then _run "mkdir ${HDIR}/Pictures"; fi
  _task-end

  #==================================
  # Remove non required applications
  #==================================
  printf "\n${LPURPLE}=== Remove Unrequired Packages ===${RESTORE}\n"
  _del_by_list ${DELList[*]}

  #==================================
  # Remove Language Files
  #==================================
  printf "\n\n${LPURPLE}=== Removing Language Packs ===${RESTORE}\n"
  _del_language

  #==================================
  # Setup OS Environment
  #==================================
  _setup_environment

  #==================================
  # Install Nerd Fonts
  #==================================
  _install_nerdfonts

  #=============================
  # Install Pipewire on Alpine
  #=============================
  if [[ ${OS^^} == "ALPINE" ]]; then 
     if (( $(_exists "pipewire") == 0 )); then
        printf "\n${LPURPLE}=== Install Pipewire ===${RESTORE}\n"
        _task-begin "Set Pipewire User Groups"
        _run "addgroup ${SUDO_USER} audio"
        _run "addgroup ${SUDO_USER} video"
	    _task-end
     fi
  fi
  
  #==================================
  # Starting Services
  #==================================
  printf "\n${LPURPLE}=== Starting Services ===${RESTORE}\n"
  _task-begin "Starting Services"
  if [[ ${OS^^} == "ALPINE" ]]; then
     _run "rc-update add acpid"
     _run "rc-update add avahi-daemon"
     _run "rc-update add cupsd"
     _run "rc-update add bluetooth"
  else
     _run "systemctl enable acpid"
     _run "systemctl enable avahi-daemon"
     _run "systemctl enable cups"
     _run "systemctl enable bluetooth"
  fi
  _task-end
  printf "\n\n${LPURPLE}=== End of Step 2 ===${RESTORE}\n\n"
}

function _process_step_3 {
   printf "\n  ${YELLOW}Step 3 - Install Desktop Applications${RESTORE}\n\n"
   # === Get Desktop Parameters ===
   _task-begin "Get Desktop Parameter File"
   DSK=$(_parm_in "DESKTOP")
   LAY=$(_parm_in "LAYOUT")
   _task-end
   
   if [[ ! -f ${LOG} ]]; then _run "rm -f ${LOG}"; fi
   _run "touch ${LOG}"
   _run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"
   printf "\n\n"   
   
   #==================================
   # Choose Packages to Install
   #==================================
   _AskYN "Install Default Apps Only:" "Y"
   printf "\n"
   if [ ${REPLY^^} == "Y" ]; then 
      _default_apps
   else
      printf "\n\n"
      _chooser
   fi

   #==================================
   # Install required applications
   #==================================
   printf "\n\n${LPURPLE}=== Installing Required Packages ===${RESTORE}\n"
   _add_by_list ${ADDList[*]}

   #==================================
   # Remove non required applications
   #==================================
   printf "\n${LPURPLE}=== Remove Unrequired Packages ===${RESTORE}\n"
   _del_by_list ${DELList[*]}
   
   printf "\n\n${LPURPLE}=== End of Step 3 ===${RESTORE}\n\n"
}

function _process_step_4 {
   printf "\n  ${YELLOW}Step 4 - Install Desktop Customizations${RESTORE}\n\n"
   # === Delete any pervious logs and setup new one ===
   if [[ ! -f ${LOG} ]]; then _run "rm -f ${LOG}"; fi
   _run "touch ${LOG}"
   _run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"
  
   # === Get Desktop Parameters ===
   _task-begin "Get Desktop Parameter File"
   DSK=$(_parm_in "DESKTOP")
   LAY=$(_parm_in "LAYOUT")
   case ${OS^^} in
     'LINUXMINT') DSK=3; LAY=3 ;;
        'SPARKY') DSK=1; LAY=1 ;;
    'PEPPERMINT') DSK=1; LAY=1 ;;
   esac  
   _task-end

   MYUID=$(grep $SUDO_USER /etc/passwd | cut -f3 -d':')
   ADDR="unix:path=/run/user/$MYUID/bus"

   # === Get Setup File ===
   _get_setup_file
   
   # === Seup User ===
   _customize_user_environment
   
   # === Customize Desktop Environment ===
   printf "\n${LPURPLE}=== Customize Desktop Environment ===${RESTORE}\n"
   case ${DSK^^} in
     1) if (( $(_exists "xfce4") > 0 )); then _customize_xfce; fi ;;
     2) if (( $(_exists "budgie-desktop") > 0 )); then _customize_budgie; fi ;;
     3) if (( $(_exists "cinnamon") > 0 )); then _customize_cinnamon; fi ;;
   esac

   # === Customize LIGHTDM settings ===
   _customize_lightdm

   # === Customize GRUB Settings ===
   _customize_grub

   # === Customize LXTerminal Setup ===
   _customize_lxterminal

   # === Customize Plank Setup ===
   _customize_plank

   # === Setup Autostart Files ===
   _customize_autostart

   #  === Setup FSTAB file ===
   _customize_fstab

   # === Create Desktop Shortcuts ===
   _customize_shortcuts

   # === Set Permissions on Directories ===
   _task-begin "Setting Up Directory Permissions"
   _run "cd ${HDIR}"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} /usr/share/backgrounds"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} /usr/share/icons"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} /usr/share/themes"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} /usr/local/include"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.local"
   _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.config"
   _task-end

   # === Cleanup ===
   _task-begin "Remove Temporary Files"
   if [[ -d ${HDIR}/sys-setup ]]; then _run "rm -rf ${HDIR}/sys-setup"; fi
   if [[ -f ${HDIR}/param.dat ]]; then _run "rm -rf ${HDIR}/param.dat"; fi
   printf "$OVERWRITE"
   _task-end
   
   # === Restarting System ===
   printf "\n\n${LPURPLE}=== Restarting System - End of Step 4 ===${RESTORE}\n"
   _AskYN "OK to Reboot Now (y/n)" "Y"
   if [ ${REPLY^^} = "Y" ]; then reboot; fi
}


#=======================================
# Title & Menu
#=======================================
function _title() {
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
   printf "\n\t\t   ${YELLOW}${OS^^} System Setup        ${LPURPLE}Ver 1.97\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
}

function _main_menu() {
   local ValidOPT="1,2,3,4,99"
   printf "\n\n${LPURPLE}       ${OS^^} Desktop Setup\n"
   printf "  ${LGREEN}+-------------------------------------+\n"
   printf "  |                                     |\n"
   printf "  |   1) Install Desktop Environment    |\n"
   printf "  |   2) Update System Configuration    |\n"
   printf "  |   3) Install Applications           |\n"
   printf "  |   4) Customize System & Desktop     |\n"
   printf "  |  ---------------------------------  |\n"
   printf "  |  99) Quit                           |\n"
   printf "  |                                     |\n"
   printf "  +-------------------------------------+${RESTORE}\n\n\n\n"
   while [[ ${ValidOPT} != *${STP}* ]]
   do
      _Ask "${OVERWRITE}Choose the step to run (1-4 or 99)" "1" && STP=$REPLY
   done
   printf "\n\n"
}

function _desktop_menu {
   #=============================
   # Choose Desktop Environment
   #=============================
   local ValidDSK="1,99"
   local MyChoices="1 or 99"
   printf "  ${LPURPLE}      DESKTOP ENVIRONMENT\n"
   printf "  ${LGREEN}+--------------------------------------+\n"
   printf "  |                                        |\n"
   printf "  |   1) XFCE Desktop Environment          |\n"
   if [[ ${OS^^} != "ALPINE" ]]; then 
      printf "  |   2) Budgie Desktop Environment        |\n"
      printf "  |   3) Cinnamon Desktop Environment      |\n"
      ValidDSK="1,2,3,99"
      MyChoices="1-3 or 99"
   fi
   printf "  |                                        |\n"
   printf "  |  99) NO Desktop                        |\n"
   printf "  |                                        |\n"
   printf "  +----------------------------------------+${RESTORE}\n\n\n"
   while [[ ${ValidDSK} != *${DSK}* ]]
   do
      _Ask " ${OVERWRITE}Choose the Desktop Environment (${MyChoices})" "1" && DSK=${REPLY}
   done
   printf "\n\n"
 }

function _layout_menu {
   #=============================
   # Choose Desktop Layout
   #=============================
   local ValidLAY="1,2,3,4"
   local MyChoices="1-4"
   printf "  ${LPURPLE}      DESKTOP LAYOUT\n"
   printf "  ${LGREEN}+--------------------------------------+\n"
   printf "  |                                      |\n"
   case ${DSK^^} in
      [12]) printf "  |  1) Top Menu Bar - Yellow Theme      |\n"
            printf "  |  2) Top Menu Bar - Blue Theme        |\n"
            printf "  |  3) Bottom Menu Bar - Yellow Theme   |\n"
            printf "  |  4) Bottom Menu Bar - Blue Theme     |\n"
            ValidLAY="1,2,3,4"
			MyChoices="1-4"
	        ;;
         3) printf "  |  1) Bottom Menu Bar - Yellow Theme   |\n"
            printf "  |  2) Bottom Menu Bar - Blue Theme     |\n"
            ValidLAY="1,2"
			MyChoices"1-2"
		    ;;
   esac
   printf "  |                                      |\n"
   printf "  +--------------------------------------+${RESTORE}\n\n\n"
   while [[ ${ValidLAY} != *${LAY}* ]]
   do
      _Ask " ${OVERWRITE}Choose the Desktop Layout (${MyChoices})" "1" && LAY=${REPLY}
   done
   _parm_out
}


#=======================================
# Main Code - Start
#=======================================
_title
if [[ -f ${LOG} ]]; then _run "rm -f ${LOG}"; fi
_run "touch ${LOG}"
_run "chown ${SUDO_USER}:${SUDO_USER} ${LOG}"

# === Install Prerequisites ===
if [[ ! -f ${HDIR}/param.dat ]]; then
   printf "\n  ${YELLOW}Install Prerequisites${RESTORE}\n\n"
   _task-begin "Updating Linux System"
   if [[ ${OS^^} != "ALPINE" ]]; then 
     _run "apt update"
     _run "apt full-upgrade -y"
     _run "apt autoremove -y"
   else
     _run "apk update"
     _run "apk upgrade"
   fi  
   _task-end
fi

# === Upgrade Linux Packages ===
while [[ ${STP^^} != "99" ]]
do
   _main_menu
   case ${STP^^} in
      1) _process_step_1 ;;
      2) _process_step_2 ;;
      3) _process_step_3 ;;
      4) _process_step_4 ;;
     99) break ;;
   esac
   STP="777"
done
