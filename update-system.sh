#!/bin/bash

# script must be run as root
if [[ $(id -u) -ne 0 ]] ; then
   printf "\n\n*************** Please run as root ***************\n\n\n"
   exit 1
fi

HDIR="/home/${SUDO_USER}"
LOG="${HDIR}/update.log"
ValidOS="DEBIAN,ALPINE,ARCH,FEDORA"

#=======================================
# Get OS Name
#=======================================
if [[ -f /etc/os-release ]]; then
   # On Linux systems
   source /etc/os-release >>$LOG 2>&1
   REALOS=$( echo $ID )
else
   # On systems other than Linux (e.g. Mac or FreeBSD)
   REALOS=$( uname )
fi
  
OS="UNKNOWN"
case ${REALOS^^} in
    DEBIAN)      OS="DEBIAN" ;;
    ELEMENTARY)  OS="DEBIAN" ;;
    BUNSENLABS)  OS="DEBIAN" ;;
    LINUXMINT)   OS="DEBIAN" ;;
    SPARKY)      OS="DEBIAN" ;;
    UBUNTU)      OS="DEBIAN" ;;
    LBUNTU)      OS="DEBIAN" ;;
    XBUNTU)      OS="DEBIAN" ;;
    ZORIN)       OS="DEBIAN" ;;
    ALPINE)      OS="ALPINE" ;;
    FEDORA)      OS="FEDORA" ;;
    ARCH)        OS="ARCH" ;;
    BLENDOS)     OS="ARCH" ;;
    CATCHYOS)    OS="ARCH" ;;
    ENDEAVOUROS) OS="ARCH" ;;
esac  


# Operating system must be one of the valid ones
if [[ ${ValidOS^^} != *${OS^^}* ]]; then
   printf "\n\n********** [${REALOS^^}] Is An Invalid OS. *******\n\n\n";
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
ADDList=("")
APPList=("")
DELList=("")

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

DELList=("advert-block-antix" "aisleriot" "appcenter" "aptitude" "aspell" "asunder" "bash-config" 
         "bunsen-docs" "bunsen-exit" "bunsen-fortune" "bunsen-images" "bunsen-numix-icon-theme" "bunsen-themes" 
         "bunsen-thunar" "bunsen-welcome" "caca-utils" "calamares" "cheese" "chntpw" "colordiff" "celluloid"  "clementine"
         "conky*" "dash" "diffutils" "dirmngr" "drawing" "eject" "enchant" "evince" "evolution-data-server" "exaile" "exfalso"
         "featherpad" "feh" "filezilla" "firefox" "firefox-esr" "five-or-more" "foliate" "fortune-mod" "four-in-a-row" "ftp" "geany" "gdebi" 
         "gddrescue" "gigolo" "gnome-2048" "gnome-chess" "gnome-contacts" "gnome-games" "gnome-klotski"
         "gnome-mahjongg" "gnome-mines" "gnome-music" "gnome-nibbles" "gnome-robots" "gnome-sound-recorder"
         "gnome-software-plug-snap" "gnome-sudoku" "gnome-taquin" "gnome-tetravex" "gnome-text-editor" "gnome-video-effects"
         "gnome-weather" "gnupg" "gsfonts" "gsimplecalc" "gsmartcontrol" "hexchat" "hexedit" "hitori" "hp-fab" "hypnotix"
         "imagemagick*" "info" "io.elementary.code" "io.elementary.feedback" "io.elementary.mail" "io.elementary.music"
         "io.elementary.onboarding" "io.elementary.screenshot" "io.elementary.tasks" "io.elementary.videos" "jgmenu"
         "lame" "lbreakout2" "libreoffice*" "liferea" "lightsoff" "lpsolve" "luckybackup*" "lynx" "magnus"
         "material-solarized-suruplusplus-icon-theme" "maya-calendar" "mc" "mc-data" "minisat" "mousepad" "mx-conky" "mx-conky-data"
         "mx-docs" "mx-faq" "mx-manual" "mx-remaster" "mx-remastercc" "mx-tour" "mx-viewer" "mx-welcome" "mx-welcome-data"
         "onboard*" "openbox" "openvpn" "pantheon-photos" "parcellite" "parole" "pdfarranger" "peg-e" "pidgin" "pix"
         "pulseaudio-module-bluetooth" "quodlibet" "redshift" "rhythmbox*" "riseup-vpn" "radiostation" "qpdfview*" "quadrapassel"
         "scrot" "shotwell" "snapd" "sparky-aptus-upgrade-*" "sparky-about" "sparky-welcome*" "speedtest" "stawberry"
         "swell-foop" "switchboard-plug-parental-controls" "synaptic" "thunderbird" "tali"  "tint2" "tnftp" "toilet" "toilet-fonts" "transmission*"
		 "uget" "vokoscreen-ng" "warpinator" "whiptail" "xcape" "xfburn" "xfce4-notes" "xfce4-terminal" "xterm" "yad" "yelp"
         "yelp-xls" "zutty")

APPList+=("=== Choose Browser(s) ===||"
          "Brave Browser|@FLT-BRAVE|N" 
          "Chromium Browser|@FLT-CHROME|N" 
		  "Falkon Browser|@FLT-FALKON|Y"
          "Firefox Browser|@FLT-FIREFOX|N"
          "Floorp Browser|@FLT-FLOORP|N"
          "Google Chrome Browser|@FLT-GOOGLE|N"
          "LibreWolf Browser|@FLT-WOLF|N"
          "UnGoogled Chromium Browser|@FLT-UNGOOGLE|Y"
		  "Vivaldi Browser|@FLT-VIVALDI|N"
          "Waterfox Browser|@FLT-WATER|Y"
          
		  "=== Choose Office Tools ===||"
		  "Abiword Word Processor|@NIX-abiword|Y"
          "Bluemail Email Client|@FLT-BLUE|Y"
          "Geary Email Client|@NIX-gnome.geary|N"
          "gEdit Graphical Editor|gedit|N"
          "Gnome Calendar|@NIX-gnome.gnome-calendar|N"
		  "Gnome Calculator|@NIX-gnome.gnome-calculator|Y"
		  "gNumeric Spreadsheet|@NIX-gnumeric|Y"
          "Libre Office|@NIX-libreoffice|N"
          "Mailspring Email Client|@NIX-mailspring|Y"
		  "Mousepad Notepad|@NIX-xfce.mousepad|Y"
		  "NotepadQQ Editor|@FLT-NOTEPAD|Y"
		  "Notepad Next Editor|@FLT-NEXT|N"
		  "OnlyOffice Suite|@FLT-ONLY|Y"
          "Simple Scan|@NIX-gnome.simple-scan|Y"
		  "Standard Notes|@NIX-standardnotes|N"
		  "Thunderbird Email Client|@NIX-thunderbird|Y"
		  "WPS Office|@FLT-WPS|N"
          
		  "=== Choose Social Media Tools ===||"
          "Choqok Twitter Client|@FLT-TWIT|N"
          "Caprine - Facebook Client|@FLT-FACE|N"
          "FreeTube - YouTube Client|@FLT-TUBE|N"
          
		  "=== Choose Video Conferencing Tools ===||"
          "Skype Video Conferencing|@FLT-SKYPE|N"
          "Teams Video Conferencing|@FLT-TEAMS|N"
          "WhatsApp Conferencing|@FLT-WHAT|N"
          "Zoom Video Conferencing|@FLT-ZOOM|N"
          
          "=== Choose Development Tools ===||"
		  "Rust Programming Lanuage|@NIX-rustc|N"
          "VSCodium IDE|@FLT-CODE|N"
          "VSCode IDE|@FLT-VSCODE|N"
          
          "=== Choose System Tools ===||"
          "BleachBit Utility|@NIX-bleachbit|Y"
          "Clam Anti Virus|@NIX-clamav|N"
          "Clam Anti Virus GUI|@NIX-clamtk|N"
          "Disk Utility|@NIX-gnome.gnome-disk-utility|Y"
		  "Fastfetch|@NIX-fastfetch|Y"
		  "Flameshot Screenshot Utility|@NIX-flameshot|Y"
          "GIT Utility|git|Y"
		  "Gnome Software Manager|@NIX-gnome.gnome-software|Y"
		  "gParted Disk Partioning|gparted|Y"
          "HTOP Process Viewer|htop|Y"
		  "Lucky Backup|@NIX-luckybackup|N"
		  "Neofetch|@NIX-neofetch|N"
          "Numlockx|numlockx|Y"
          "Pika Backup|@FLT-PIKA|N"
		  "Putty SSH Utility|@NIX-putty|N"
          "Stacer|@NIX-stacer|Y"
          "Timeshift System Snapshot|@NIX-timeshift|N"
          "uLauncher|@NIX-ulauncher|Y"
          "Warehouse|@FLT-WARE|Y"
          "Flatsweep|@FLT-SWEEP|Y"
          "Impress USB Writer|@FLT-IMPRESS|Y"
          
		  "=== Choose Emulation Tools ===||"
		  "Bottles Windows Emulation|@NIX-bottles|Y"
          "Play On Linux|@FLT-PLAY|N"
		  "WayDroid - Android Emulator|@NIX-waydroid|N"
          "WINE|@NIX-wine|N"
          "WINE|@NIX-wine64|N"
          "Wine Tricks|@NIX-winetricks|N"
          
		  "=== Choose Virtualization Tools ===||"
		  "DistroBox|@NIX-distrobox|N"
		  "Gnome Boxes|@NIX-gnome.gnome-boxes|N"
		  "Virtualization Manager|virt-manager|N"
          
		  "=== Choose Optional Applications ===||"
		  "Calibre eBook Manager|@FLT-BOOK|N"
		  "Cheese Camera Utility|cheese|N"
		  "gThumb Image Viewer|gthumb|N"
          "Kodi Media Center|@FLT-KODI|N"
          "MPV Media Player|@FLT-MPV|N"
          "Ristretto Image Viewer|@NIX-xfce.ristretto|Y"
		  "Spotify Client|@FLT-SPOT|N"
          "Strawberry Music Player|@FLT-MUSIC|N"
		  "VLC Media Player|@NIX-vlc|Y")                                            

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

function _log-msg() {
   printf "     ${1}\n" >> ${LOG}
}


#========================================================
#    Input Functions
#========================================================
function _Ask(){
  if  [[ ${2} != "" ]]; then
    printf "${LCYAN}${1} ${YELLOW}[${2}]: ${RESTORE}"
    read REPLY
    if [[ ${REPLY} == "" ]] ; then REPLY="${2}" ; fi
  else
    printf "${LCYAN}${1}: ${RESTORE}"
    read REPLY
  fi
  REPLY=${REPLY}
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
  local PASS="UNKNOWN"
  local PASS2=""

  while [[ ${PASS} != ${PASS2} ]]
  do
    printf "${LCYAN}${1}: ${RESTORE}"
    read -s PASS
    printf "\n${LCYAN}${1} (Repeat): ${RESTORE}"
    read -s PASS2
    printf "\n"
    if [[ ${PASS} != ${PASS2} ]]; then
      printf "${RED}ERROR - Passwords do not match${RESTORE}\n\n"
    fi
  done
  REPLY=${PASS}
}

function _chooser() {
   if [ ${#APPList[@]} -gt 0 ]; then
     for i in {0..999}; do
        if (( i == ${#APPList[@]} )); then break; fi
        IFS='|' read -ra arr <<< "${APPList[i]}"
        if [ ${#arr[@]} -gt 0 ]; then
          local KEY=${arr[0]:1:3}
          case ${KEY^^} in
             NIX) if (( $(_IsNix "${arr[1]}") == 0 )); then
                     _AskYN "Install ${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
	              else
                     _AskYN "Install $LRED${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
                  fi
                  _PKG_List 
                  ;;
               *) if (( $(_Exists "${arr[1]}") == 0 )); then
                     _AskYN "Install ${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
	              else
                     _AskYN "Install $LRED${arr[0]}${LGREEN} (y/n/r)" ${arr[2]^^}
                  fi
                  _PKG_List ${REPLY^^} ${arr[1]}
                  ;;
          esac
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
function _Exists() {
  local VAL=0
  VAL=$(_IsNative "$1")
  
  if (( $(_IsNative "flatpak") > 0 )); then
     if (( ${VAL} == 0 )); then VAL=$(flatpak list | grep -ic "${1}"); fi
  fi
  
  if [[ -f /nix/var/nix/profiles/default/bin/nix-env ]]; then
     if (( ${VAL} == 0 )); then VAL=$(_IsNix "$1"); fi
  fi
  printf "%u" ${VAL}
}

function _IsNative() {
  local VAL=0
  case ${OS^^} in
     'ALPINE') VAL=$(apk list -I ${1} 2>/dev/null | grep -c "${1}") ;;
     'DEBIAN') VAL=$(apt list --installed ${1} 2>/dev/null | grep -c "${1/\*/}") ;;
     'ARCH')   VAL=$(yay -Ss ${1} 2>/dev/null | grep -c "/${1,,} ") ;;
     'FEDORA') ;;
  esac
  printf "%u" ${VAL}
}

function _IsNix() {
  local VAL=0
  VAL=$(nix-env --query ${1} 2>/dev/null | grep -c "${1}")
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

function _add_native_pkg() {
  if (( $(_IsNative $1) == 0 )); then
    _task-begin "Installing Package ${1^^}"  
    case ${OS^^} in
        'ALPINE') _run "apk add $1" ;;
        'DEBIAN') _run "apt-get install -y $1" ;;
        'ARCH')   _run "yay -Syu --noconfirm $1" ;;
        'FEDORA') _run "dnf install $1" ;;
    esac
    _task-end
  else
    _task-begin "${LRED}${1^^} Exists....Skipping"  
    _task-end  
  fi
}

function _add_nix_pkg() {
  if (( $(_IsNix $1) == 0 )); then
    _task-begin "Installing Nix Package ${1^^}"
	_run "nix-env -iA nixpkgs.$1"
    _task-end
  else
    _task-begin "${LRED}${1^^} Exists....Skipping"  
    _task-end  
  fi
}

function _add_by_list() {
  local Pkgs=${*}
  if [ ${#Pkgs[@]} -gt 0 ]; then
    for Pkg in ${Pkgs[@]}; do
	   if [[ ${Pkg:0:1} == "@" ]]; then
          _add_special ${Pkg}
	   else
	      _add_native_pkg ${Pkg}
	   fi
    done
  fi
}

function _add_native_by_list() {
  local Pkgs=${*}
  if [ ${#Pkgs[@]} -gt 0 ]; then
    for Pkg in ${Pkgs[@]}; do
	   if [[ ${Pkg:0:1} == "@" ]]; then
          _add_special ${Pkg}
	   else
	      _add_native_pkg ${Pkg}
	   fi
    done
  fi
}

function _add_nix_by_list() {
  local Pkgs=${*}
  if [ ${#Pkgs[@]} -gt 0 ]; then
    for Pkg in ${Pkgs[@]}; do
       _add_nix_pkg ${Pkg}
    done
  fi
}

function _del_pkg() {
  if (( $(_IsNative $1) > 0 )); then
     _task-begin "Removing ${1^^} from ${OS^^}"
     case ${OS^^} in
        'ALPINE') _run "apk del $1" ;;
        'DEBIAN') _run "apt-get purge -y $1" ;;
        'ARCH')   _run "yay -Runs --noconfirm $1" ;;
        'FEDORA') _run "dnf remove $1" ;;
     esac
     _task-end
  else
     if (( $(_IsNix $1) > 0 )); then
        _task-begin "Removing ${1^^} from NIX Packages"  
        _run "nix-env --uninstall nixpkgs.$1"
        _task-end
     else
       _task-begin "${LRED}${1^^} Does NOT Exists....Skipping"  
       _task-end          
     fi
  fi
}

function _del_by_list() {
  local Pkgs=${*}
  if [ ${#Pkgs[@]} -gt 0 ]; then
    for Pkg in ${Pkgs[@]}; do
	   if [[ ${Pkg:0:1} == "@" ]]; then
	      _del_special ${Pkg}
	   else
	      _del_pkg ${Pkg}
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
  local KEY=${1:1:3}
  local PKG=${1:1:15}
  
  _log-msg "Adding Special - Key=${KEY}, Pkg=${PKG}"
  case ${KEY^^} in
     NIX) PKG=${1:5:25}
          _add_nix_pkg $PKG
          ;;
     FLT) case ${PKG^^} in
               FLT-BRAVE) _add_flatpak "Brave Browser" "com.brave.Browser" ;;
               FLT-CHROME) _add_flatpak "Chromium Browser" "org.chromium.Chromium" ;;
               FLT-FALKON) _add_flatpak "Falkon Browser" "org.kde.falkon" ;;
               FLT-FIREFOX) _add_flatpak "Firefox Browser" "org.mozilla.firefox" ;;
               FLT-FLOORP) _add_flatpak "Floorp Browser" "one.ablaze.floorp" ;;
               FLT-GOOGLE) _add_flatpak "Google Browser" "com.google.Chrome" ;;
               FLT-UNGOOGLE) _add_flatpak "UnGoogled Chromium Browser" "io.github.ungoogled_software.ungoogled_chromium" ;;
               FLT-VIVALDI) _add_flatpak "Vivaldi Browser" "com.vivaldi.Vivaldi" ;;
               FLT-WATER) _add_flatpak "Waterfox Browser" "net.waterfox.waterfox" ;;
               FLT-WOLF) _add_flatpak "Librewolf Browser" "io.gitlab.librewolf-community" ;;
               
               FLT-BLUE) _add_flatpak "Bluemail Email Client" "net.blix.BlueMail" ;;
               FLT-MAIL) _add_flatpak "Mailspring" "com.getmailspring.Mailspring" ;;
               FLT-ONLY) _add_flatpak "Only Office" "org.onlyoffice.desktopeditors" ;;
               FLT-WPS) _add_flatpak "WPS Office" "com.wps.Office" ;;
               FLT-NOTEPAD) _add_flatpak "Notepadqq" "com.notepadqq.Notepadqq" ;;
               FLT-NEXT) _add_flatpak "Notepad Next" "com.github.dail8859.NotepadNext" ;;
               
               FLT-BOOK) _add_flatpak "Calibre" "com.calibre_ebook.calibre" ;;
               FLT-MUSIC) _add_flatpak "Strawberry Music Player" "org.strawberrymusicplayer.strawberry" ;;
               FLT-SPOT) _add_flatpak "Spotify" "com.spotify.Client" ;;
               FLT-TWIT) _add_flatpak "Choqok Twitter Client" "org.kde.choqok" ;;
               FLT-FACE) _add_flatpak "Caprine Facebook Client" "com.sindresorhus.Caprine" ;;
               FLT-TUBE) _add_flatpak "FreeTube" "io.freetubeapp.FreeTube" ;;
               FLT-SKYPE) _add_flatpak "Skype Conferencing" "com.skype.Client" ;;
               FLT-TEAMS) _add_flatpak "Teams Conferencing" "com.github.IsmaelMartinez.teams_for_linux" ;;
               FLT-WHAT) _add_flatpak "WhatsApp" "com.github.eneshecan.WhatsAppForLinux" ;;
               FLT-ZOOM) _add_flatpak "Zoom Meeting" "us.zoom.Zoom";;
               FLT-KODI) _add_flatpak "Kodi Media Center" "tv.kodi.Kodi" ;;
               FLT-MPV) _add_flatpak "MPV" "io.mpv.Mpv" ;;
                              
               FLT-WARE) _add_flatpak "Warehouse" "io.github.flattool.Warehouse" ;;
               FLT-SWEEP) _add_flatpak "FlatSweep Flatpak Maintenance" "io.github.giantpinkrobots.flatsweep" ;;
               FLT-IMPRESS) _add_flatpak "Impression USB Writer" "io.gitlab.adhami3310.Impression" ;;
               FLT-PLAY) _add_flatpak "Play On Linux" "com.playonlinux.PlayOnLinux4" ;;
               FLT-BLEACH) _add_flatpak "BleachBit Utility" "org.bleachbit.BleachBit" ;;
               FLT-CODE) _add_flatpak "VSCodium" "com.vscodium.codium" ;;
               FLT-VSCODE) _add_flatpak "VSCodium" "com.visualstudio.code" ;;
               FLT-FLAME) _add_flatpak "Flameshot" "org.flameshot.Flameshot" ;;
               FLT-CLAM) _add_flatpak "ClamTK" "com.github.davem.Clamtk" ;;
               FLT-PIKA) _add_flatpak "Pika Backup" "org.gnome.World.PikaBackup" ;;
		   esac
           ;;
  esac
}

function _del_special() {
  local KEY=${1:1:3}
  local PKG=${1:1:15}
  
  _log-msg "Deleting Special - Key=${KEY}, Pkg=${PKG}"
  case ${KEY^^} in
     NIX) 
          ;;
     FLT) case ${PKG^^} in
               FLT-BRAVE) _del_flatpak "Brave Browser" "com.brave.Browser" ;;
               FLT-CHROME) _del_flatpak "Chromium Browser" "org.chromium.Chromium" ;;
               FLT-FALKON) _del_flatpak "Falkon Browser" "org.kde.falkon" ;;
               FLT-FIREFOX) _del_flatpak "Firefox Browser" "org.mozilla.firefox" ;;
               FLT-FLOORP) _del_flatpak "Floorp Browser" "one.ablaze.floorp" ;;
               FLT-GOOGLE) _del_flatpak "Google Browser" "com.google.Chrome" ;;
               FLT-UNGOOGLE) _del_flatpak "UnGoogled Chromium Browser" "io.github.ungoogled_software.ungoogled_chromium" ;;
               FLT-VIVALDI) _del_flatpak "Vivaldi Browser" "com.vivaldi.Vivaldi" ;;
               FLT-WATER) _del_flatpak "Waterfox Browser" "net.waterfox.waterfox" ;;
               FLT-WOLF) _del_flatpak "Librewolf Browser" "io.gitlab.librewolf-community" ;;
               
               FLT-BLUE) _del_flatpak "Bluemail Email Client" "net.blix.BlueMail" ;;
               FLT-MAIL) _del_flatpak "Mailspring" "com.getmailspring.Mailspring" ;;
               FLT-ONLY) _del_flatpak "Only Office" "org.onlyoffice.desktopeditors" ;;
               FLT-WPS) _del_flatpak "WPS Office" "com.wps.Office" ;;
               FLT-NOTEPAD) _del_flatpak "Notepadqq" "com.notepadqq.Notepadqq" ;;
               FLT-NEXT) _del_flatpak "Notepad Next" "com.github.dail8859.NotepadNext" ;;
               
               FLT-BOOK) _del_flatpak "Calibre" "com.calibre_ebook.calibre" ;;
               FLT-MUSIC) _del_flatpak "Strawberry Music Player" "org.strawberrymusicplayer.strawberry" ;;
               FLT-SPOT) _del_flatpak "Spotify" "com.spotify.Client" ;;
               FLT-TWIT) _del_flatpak "Choqok Twitter Client" "org.kde.choqok" ;;
               FLT-FACE) _del_flatpak "Caprine Facebook Client" "com.sindresorhus.Caprine" ;;
               FLT-TUBE) _del_flatpak "FreeTube" "io.freetubeapp.FreeTube" ;;
               FLT-SKYPE) _del_flatpak "Skype Conferencing" "com.skype.Client" ;;
               FLT-TEAMS) _del_flatpak "Teams Conferencing" "com.github.IsmaelMartinez.teams_for_linux" ;;
               FLT-WHAT) _del_flatpak "WhatsApp" "com.github.eneshecan.WhatsAppForLinux" ;;
               FLT-ZOOM) _del_flatpak "Zoom Meeting" "us.zoom.Zoom";;
               FLT-KODI) _del_flatpak "Kodi Media Center" "tv.kodi.Kodi" ;;
               FLT-MPV) _del_flatpak "MPV" "io.mpv.Mpv" ;;
                              
               FLT-WARE) _del_flatpak "Warehouse" "io.github.flattool.Warehouse" ;;
               FLT-SWEEP) _del_flatpak "FlatSweep Flatpak Maintenance" "io.github.giantpinkrobots.flatsweep" ;;
               FLT-IMPRESS) _del_flatpak "Impression USB Writer" "io.github.adham3310.Impression" ;;
               FLT-PLAY) _del_flatpak "Play On Linux" "com.playonlinux.PlayOnLinux4" ;;
               FLT-BLEACH) _del_flatpak "BleachBit Utility" "org.bleachbit.BleachBit" ;;
               FLT-CODE) _del_flatpak "VSCodium" "com.vscodium.codium" ;;
               FLT-VSCODE) _del_flatpak "VSCodium" "com.visualstudio.code" ;;
               FLT-FLAME) _del_flatpak "Flameshot" "org.flameshot.Flameshot" ;;
               FLT-CLAM) _del_flatpak "ClamTK" "com.github.davem.Clamtk" ;;
               FLT-PIKA) _del_flatpak "Pika Backup" "org.gnome.World.PikaBackup" ;;
		   esac
           ;;
  esac
}


#========================================================
#    Processing Functions
#========================================================
function _parm_out {
    if [[ -f ${HDIR}/param.dat ]]; then rm -f ${HDIR}/param.dat; fi
    if [[ -z $DSK ]]; then
       case ${OS^^} in
          'LINUXMINT') DSK="CINNAMON" ;;
                    *) DSK="XFCE" ;;
       esac
    fi
    if [[ -z $LAY ]]; then
       case ${OS^^} in
          'LINUXMINT') LAY="BOTTOMYELLOW" ;;
                    *) LAY="TOPYELLOW" ;;
       esac
    fi
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
      _run "sudo -u ${1,,} DBUS_SESSION_BUS_ADDRESS=\"$ADDR\" dconf write ${KEY} \"${VALUE}\""
   else
      _run "sudo -u ${1,,} DBUS_SESSION_BUS_ADDRESS=\"$ADDR\" dconf write ${KEY} ${VALUE}"
   fi
}

function _getValue {
   local KEY="$1"
   local RET=$(sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="$ADDR" dconf read ${KEY})
   printf "${RET}"
}

function _valExists() {
   local RET=0
   local VAL=""
   if [[ ! -z $1 ]]; then VAL=$(_getXValue $1 $2); fi
   if [[ ! -z $VAL ]]; then RET=1; fi
   printf "$RET"
}

function _getXValue() {
   local RET=""
   if [[ ! -z $1 ]]; then 
      if [[ ! -z $2 ]]; then RET=$(xfconf-query -c $1 -p "$2" >/dev/null 2>&1); fi
   fi
   printf "$RET"
}

function _setXValue() {
   if [[ ! -z $1 ]]; then 
      if [[ ! -z $2 ]]; then 
         if [[ ! -z $3 ]]; then
            if [[ $(_valExists "$1" "$2") == "1" ]]; then
               if [[ ${3} == *" "* ]]; then
                  _run "xfconf-query -c $1 -p $2 -s '$3'"
               else
                  _run "xfconf-query -c $1 -p $2 -s $3"
               fi
            else
               TYP=$4
               if [[ -z $TYP ]]; then TYP="string"; fi
               if [[ ${3} == *" "* ]]; then
                  _run "xfconf-query -c $1 -p $2 -n -t ${TYP,,} -s '$3'"
               else
                  _run "xfconf-query -c $1 -p $2 -n -t ${TYP,,} -s $3"
               fi
            fi
         fi
      fi
   fi      
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
  case ${OS^^} in
     'ALPINE') # Disable Root Login
               _task-begin "Disable Root Login"
               RET=$( grep -c 'root:/sbin/nologin' /etc/passwd)
               if [ ${RET} == 0 ]; then
                 _run "sed -i s'#root:/bin/ash#root:/sbin/nologin#' /etc/passwd"
               fi
               _task-end

               # Update Alpine Terminal Profile
               _task-begin "Update Alpine Terminal Profile"
               RET=$( cat /etc/profile | grep -c 'PS1="\[\033}' )
               if [ ${RET} == 0 ]; then
                 _run "printf \"PS1='${PS1}'\nexport PS1\" | tee -a /etc/profile"
               fi
               printf "${OVERWRITE}${OVERWRITE}"
               _task-end

               # Remove Alpine MOTD
               _task-begin "Removing MOTD"
               if [ -f /etc/motd ]; then _run "rm /etc/motd"; fi
               _task-end

               #================ Change Shell to Bash ===========
               if [[ $(grep -c '/bin/ash' /etc/passwd) == 0 ]]; then
                 _task-begin "Change Shell to BASH"
                 _run "sed 's#/bin/ash#/bin/bash#' /etc/passwd"
                 _task-end
               fi
               
               # Install Pipewire on Alpine
               if (( $(_Exists "pipewire") == 0 )); then
                 printf "\n${LPURPLE}=== Install Pipewire ===${RESTORE}\n"
                 _task-begin "Set Pipewire User Groups"
                 _run "addgroup ${SUDO_USER} audio"
                 _run "addgroup ${SUDO_USER} video"
	             _task-end
               fi
               _run "addgroup ${SUDO_USER} plugdev"         
               _run "setup-devd udev"
               ;;
     'DEBIAN') #============ ZRAM Tools Setup ===================
               if [ -f /etc/default/zramswap ]; then
                 _task-begin "Update ZRAM Swap Configuration"
                 _run "echo -e 'ALGO=zstd' | tee -a /etc/default/zramswap"
                 _run "echo -e 'PERCENT=35' | tee -a /etc/default/zramswap"
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
               ;;
     'ARCH')   ;;
     'FEDORA') ;;
  esac
}

function _install_Desktop {
  local PROG=("")
  
  #============================ Install Desktop ============================================
  printf "\n\n${LPURPLE}=== Installing $DSK Desktop Environment  ===${RESTORE}\n\n"
  if [ ! -f /usr/share/.desktop ]; then
     case ${OS^^} in
       'ALPINE') _task-begin "Installing ${DSK^^} Desktop Components" 
                 _run "setup-desktop ${DSK,,}"
                 _task-end
                 PROG=("lightdm" "lxterminal" "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" 
                       "thunar-volman" "volumeicon-alsa" "networkmanager" "network-manager-applet")
                 _add_by_list ${PROG[*]}
                 _run "rc-update add lightdm"
                 ;;
       'DEBIAN') PROG=("xorg" "gnome-control-center" "lightdm" "dialog" "lxterminal" "thunar" 
	                   "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman-plugin" 
					   "volumeicon-alsa")
	             case ${DSK^^} in
                    'BUDGIE') PROG=("budgie-desktop" "budgie-indicator-applet" "plank") ;;
                           *) _task-begin "Installing ${DSK^^} Desktop"
                              _run "apt-get install -y task-${DSK,,}-desktop"
                              _task-end
                              ;; 
                 esac
				 _add_by_list ${PROG[*]}
				 _run "systemctl enable lightdm"
                 ;;
       'ARCH')   PROG=("xorg" "xorg-server" "gnome-control-center" "lightdm" "lightdm-gtk-greeter" 
	                   "dialog" "lxterminal" "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" 
					   "thunar-volman-plugin" "volumeicon-alsa")
	             case ${DSK^^} in
                    'BUDGIE') PROG+=("budgie-desktop" "budgie-indicator-applet" "plank") ;;
                      'XFCE') PROG+=("xfce4" "xfce4-goodies") ;;
                  'CINNAMON') PROG+=("cinnamon") ;;
                 esac
				 _add_by_list ${PROG[*]}
				 _run "systemctl enable lightdm"
				 _run "systemctl enable NetworkManager"
                 ;;
       'FEDORA') ;;
     esac
     _run "touch /usr/share/.desktop"
  else
     printf "   ${LRED}A Desktop Exists..Skipping${RESTORE}\n"     
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
     _run "wget -q https://tinyurl.com/sys-base4"
     if [ -f ${HDIR}/sys-setup/sys-base4 ]; then
       _run "mv -f sys-base4 sys.zip"
       _run "unzip -o -q sys.zip"
     fi
     _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/sys-setup"
     _run "cd ${HDIR}"
   fi
   _task-end
}

function _customize_user_environment {
   #Backgrounds
   if [ ! -f /usr/share/backgrounds/.setup ]; then
      _task-begin "Install Desktop Backgrounds"
      _run "mv -f ${HDIR}/sys-setup/backgrounds/* /usr/share/backgrounds"
      _run "touch /usr/share/backgrounds/.setup"
      _task-end
   fi

   #Start Icons
   if [ ! -d /usr/share/icons/start ]; then _run "mkdir -p /usr/share/icons/start"; fi
   if [ ! -f /usr/share/icons/start/.setup ]; then
      _task-begin "Install Start Menu Icons"
      _run "mv -f ${HDIR}/sys-setup/start/* /usr/share/icons/start/"
      _run "touch /usr/share/icons/start/.setup"
      _task-end
   fi

   #Avatars
   _log-msg "Starting to add avatars"
   #if [ ! -d /usr/share/icons/avatars ]; then _run "mkdir -p /usr/share/icons/avatars"; fi
   if [ ! -f /usr/share/icons/avatars/.setup ]; then
      _task-begin "Install Login Avatars"
      #_run "mv -f ${HDIR}/sys-setup/avatars/*.jpg /usr/share/icons/avatars/"
      _run "touch /usr/share/icons/avatars/.setup"
      _task-end
   fi

   #User Files
   if [ ! -f ${HDIR}/.hushlogin ]; then
      _task-begin "Install Bash Setup Files"
      _run "mv -f ${HDIR}/sys-setup/.bashrc ${HDIR}"
      _run "mv -f ${HDIR}/sys-setup/.bash_aliases ${HDIR}"
      _run "mv -f ${HDIR}/sys-setup/.hushlogin ${HDIR}"
	  if [ ${SUDO_USER^^} == "MARTIN" ]; then _run "mv -f ${HDIR}/sys-setup/bookmarks.html ${HDIR}"; fi
      _task-end
   fi

   #Download Script File
   if [[ ${SUDO_USER^^} == "MARTIN" ]]; then
      _task-begin "Install Script Directory"
      if [ -d ${HDIR}/Scripts ]; then _run "rm -rf ${HDIR}/Scripts/"; fi
      _run "mkdir -p ${HDIR}/Scripts/"
      _run "cd ${HDIR}/Scripts"
      _run "wget -q https://tinyurl.com/sys-src"
      if [ -f ${HDIR}/Scripts/sys-src ]; then
         _run "mv -f sys-src script.zip"
         _run "unzip -o -q script.zip"
         _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/Scripts/"
         _run "chmod -R +x ${HDIR}/Scripts/*"
      fi
      _run "cd ${HDIR}"
      _task-end
   fi
}

function _customize_icons {
   if [ -f ${HDIR}/sys-setup/sys.zip ]; then
      _task-begin "Install Icons"
      if [ ! -d /usr/share/icons ]; then _run "mkdir -p /usr/share/icons"; fi
      
      #https://github.com/thecheis/Boston-Icons
      #https://github.com/cbrnix/Flatery
      #https://github.com/fabianalexisinostroza/Kuyen-icons
      
      _log-msg "Parameters Desktop=$DSK, Layout=$LAY"
      case ${LAY^^} in
        'TOPYELLOW'|'BOTTOMYELLOW') 
              if [ ! -d /usr/share/icons/'Boston cardboard' ]; then
			     _run "mv -f ${HDIR}/sys-setup/icons/Boston-Cardboard.tar.xz /usr/share/icons/"
			     _run "cd /usr/share/icons/"
		         _run "tar -xf Boston-Cardboard.tar.xz"
				 _run "rm -f Boston-Cardboard.tar.xz"
                 _run "gtk-update-icon-cache /usr/share/icons/'Boston cardboard'"
		      fi
              if [ ! -d /usr/share/icons/Windows\ Vista ]; then
			     _run "mv -f ${HDIR}/sys-setup/icons/Windows\ Vista.tar.xz /usr/share/icons/"
			     _run "cd /usr/share/icons/"
		         _run "tar -xf Windows\ Vista.tar.xz"
				 _run "rm -f Windows\ Vista.tar.xz"
                 _run "gtk-update-icon-cache /usr/share/icons/Windows\ Vista"
		      fi
              if [ ! -d /usr/share/icons/buuf-nestort ]; then
			     _run "mv -f ${HDIR}/sys-setup/icons/buuf-nestort.tar.gz /usr/share/icons/"
			     _run "cd /usr/share/icons/"
		         _run "tar -xf buuf-nestort.tar.gz"
				 _run "rm -f buuf-nestort.tar.gz"
                 _run "gtk-update-icon-cache /usr/share/icons/buuf-nestort"
		      fi
			  if [[ ${OS^^} == "ALPINE" ]]; then
                 _run "apk add gnome-dust-icon-theme tango-icon-theme"
              else
                 _run "apt-get install -y gnome-dust-icon-theme tango-icon-theme"
              fi
 	          ;;
         'TOPBLUE'|'BOTTOMBLUE') 
              if [ ! -d /usr/share/icons/Flatery-Sky ]; then
		   		 _run "mv -f ${HDIR}/sys-setup/icons/Flatery-Sky.tar.gz /usr/share/icons"
				 _run "cd /usr/share/icons/"
		         _run "tar -xf Flatery-Sky.tar.gz"
				 _run "rm -f Flatery-Sky.tar.gz"
                 _run "gtk-update-icon-cache /usr/share/icons/Flatery-Sky"
                 _run "gtk-update-icon-cache /usr/share/icons/Flatery-Sky-Dark"
		      fi 
              if [ ! -d /usr/share/icons/kuyen-icons ]; then
		   		 _run "mv -f ${HDIR}/sys-setup/icons/kuyen-icons.tar.xz /usr/share/icons"
				 _run "cd /usr/share/icons/"
		         _run "tar -xf kuyen-icons.tar.xz"
				 _run "rm -f kuyen-icons.tar.xz"
                 _run "gtk-update-icon-cache /usr/share/icons/kuyen-icons"
		      fi
			  case ${OS^^} in
                'ALPINE') _run "apk add gnome-brave-icon-theme tango-icon-theme" ;;
                'DEBIAN') _run "apt-get install -y gnome-icon-theme gnome-brave-icon-theme tango-icon-theme" ;;
                  'ARCH') _run "apt-get install -y gnome-icon-theme gnome-brave-icon-theme tango-icon-theme" ;;
                'FEDORA') _run "apt-get install -y gnome-icon-theme gnome-brave-icon-theme tango-icon-theme" ;;
              esac
              ;;
      esac
      _run "cd ${HDIR}"
	  _task-end
   fi
}

function _customize_themes {
   if [ -f ${HDIR}/sys-setup/sys.zip ]; then
      _task-begin "Install Themes"
      if [ ! -d /usr/share/themes ]; then _run "mkdir -p /usr/share/themes"; fi

      #https://github.com/daniruiz/skeuos-gtk.git
      #https://github.com/daniruiz/skeuos-gtk/tree/master/themes/Skeuos-Blue-Dark
      #https://github.com/daniruiz/skeuos-gtk/tree/master/themes/Skeuos-Yellow-Dark

      _log-msg "Parameters Desktop=$DSK, Layout=$LAY"
	  case ${LAY} in
        'TOPYELLOW'|'BOTTOMYELLOW') 
             if [ ! -d /usr/share/themes/Orchis-Yellow-Dark ]; then
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
				_run "rm -rf Skeuos-Yellow-Light*"
				_run "rm -rf Skeuos-Yellow-Dark-*"
             fi
 	         ;;
        'TOPBLUE'|'BOTTOMBLUE') 
             if [ ! -d /usr/share/themes/Orchis-Dark ]; then
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
				_run "rm -rf Skeuos-Blue-Light*"
				_run "rm -rf Skeuos-Blue-Dark-F*"
				_run "rm -rf Skeuos-Blue-Dark-G*"
				_run "rm -rf Skeuos-Blue-Dark-X*"
             fi
             if [ ! -d /usr/share/themes/Fluent-Dark ]; then
                _run "cd /usr/share/themes"
			    _run "mv -f ${HDIR}/sys-setup/themes/Fluent-Dark.tar.xz /usr/share/themes"
				_run "cd /usr/share/themes/"
		        _run "tar -xf Fluent-Dark.tar.xz"
				_run "rm -f Fluent-Dark.tar.xz"
             fi
             if [ ! -d /usr/share/themes/Goldy-Dark-GTK ]; then
                _run "cd /usr/share/themes"
			    _run "mv -f ${HDIR}/sys-setup/themes/Goldy-Dark-GTK.tar.gz /usr/share/themes"
				_run "cd /usr/share/themes/"
		        _run "tar -xf Goldy-Dark-GTK.tar.gz"
				_run "rm -f Goldy-Dark-GTK.tar.gz"
             fi
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
         _log-msg "Parameters Desktop=$DSK, Layout=$LAY"

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
            'TOPYELLOW'|'BOTTOMYELLOW') 
                 PRT="${PRT}background=/usr/share/backgrounds/iB38gbGjiAxVdT2h.jpg\n"
                 PRT="${PRT}theme-name=Orchis-Teal-Dark\n"
                 PRT="${PRT}icon-theme-name = Tango\n"
                 PRT="${PRT}postition=66%%,center 55%%,center\n"
                 #PRT="${PRT}default-user-image=/usr/share/icons/avatars/yellow_02.jpg\n"                 
                 ;;
            'TOPBLUE'|'BOTTOMBLUE') 
                 PRT="${PRT}background=/usr/share/backgrounds/8pplzWJvxVoxqrCE.jpg\n"
                 PRT="${PRT}theme-name=Orchis-Dark\n"
                 PRT="${PRT}icon-theme-name=Tango\n"   
                 PRT="${PRT}postition=80%%,center 55%%,center\n"
                 #PRT="${PRT}default-user-image=/usr/share/icons/avatars/blue_04.jpg\n"
 	             ;;
         esac
         PRT="${PRT}user-background=false\n"
         PRT="${PRT}font-name=SauceCodePro Nerd Font 12\n"
         PRT="${PRT}show-clock=false\n"
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
      printf "$OVERWRITE"
      _task-end 
   fi
}

function _customize_lxterminal {
   if (( $(_Exists "lxterminal") > 0 )); then
      if [ ! -f ${HDIR}/.config/lxterminal/.setup ]; then
	     _task-begin "Install LXTerminal Setup"
         if [ ! -d ${HDIR}/.config/lxterminal/ ]; then _run "mkdir -p ${HDIR}/.config/lxterminal"; fi
         _run "cd ${HDIR}/sys-setup/applications/lxterminal"
         _run "mv -f * ${HDIR}/.config/lxterminal/"
         _run "touch ${HDIR}/.config/lxterminal/.setup"
         _run "cd ${HDIR}"
        _task-end		 
      fi
   fi
}

function _customize_plank {
   if (( $(_Exists "plank") > 0 )); then
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
         if (( $(_Exists "numlockx") > 0 )); then _run "mv -f numlockx.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_Exists "plank") > 0 )); then _run "mv -f plank.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_Exists "flameshot") > 0 )); then _run "mv -f org.flameshot.Flameshot.desktop ${HDIR}/.config/autostart/"; fi
         if (( $(_Exists "ulauncher") > 0 )); then _run "mv -f ulauncher.desktop ${HDIR}/.config/autostart/"; fi
         if [[ ${SUDO_USER^^} == "MARTIN" ]]; then _run "mv -f automount.desktop ${HDIR}/.config/autostart/"; fi
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
         _run "echo ''  | tee -a /etc/fstab"
         _run "echo '//10.10.10.25/documents  /media/documents  cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,_netdev,iocharset=utf8 0 0' | tee -a /etc/fstab"
         _run "echo '//10.10.10.25/utilities  /media/utilities  cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,_netdev,iocharset=utf8 0 0' | tee -a /etc/fstab"
         _run "echo '//10.10.10.25/multimedia /media/multimedia cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,_netdev,iocharset=utf8 0 0' | tee -a /etc/fstab"
         _run "echo '//10.10.10.25/backups    /media/backups    cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,_netdev,iocharset=utf8 0 0' | tee -a /etc/fstab"
         _run "echo '//10.10.10.25/private    /media/private    cifs credentials=/home/$SUDO_USER/.smbcredentials,noperm,_netdev,iocharset=utf8 0 0' | tee -a /etc/fstab"
      fi
     _task-end
      
      # Setup Network Credentials
      printf "\n\n"
      _Ask "Enter Network Username"
      local UNAME=${REPLY}
      _AskPass "Enter Network Password"
      local PASS=${REPLY}
      printf "\n\n"

      _run "rm -f ${HDIR}/.smbcredentials"
      _run "touch ${HDIR}/.smbcredentials"
      _run "printf 'username=$UNAME\npassword=$PASS\n' | tee -a ${HDIR}/.smbcredentials"
      _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.smbcredentials"
      _run "chmod 600 ${HDIR}/.smbcredentials"
      printf "\n"
   fi
}

function _customize_budgie {
   if (( $(_Exists "budgie-desktop") > 0 )); then
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
              'TOPYELLOW') 
                 _THEME="Skeuos-Yellow-Dark"
                 _ICON="gnome-dust"
                 _STYLE="budgie_top_yellow.dconf"
                 _BACK="eGna2qBdawpRZpuq.jpg"
                 ;;
              'TOPBLUE') 
                 _THEME="Orchis-Dark"
                 _ICON="Boston"
                 _STYLE="budgie_top_blue.dconf" 
                 _BACK="oC8iorz2BlyAeEQi.jpg"
                 ;;
              'BOTTOMYELLOW') _THEME="Skeuos-Yellow-Dark"
                 _ICON="gnome-dust"
                 _STYLE="budgie_bottom_yellow.dconf" 
                 _BACK="eGna2qBdawpRZpuq.jpg"
                 ;;
              'BOTTOMBLUE') 
                 _THEME="Orchis-Dark"
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
   if (( $(_Exists "xfce4") > 0 )); then
      if [ -d ${HDIR}/.config/xfce4 ]; then
         if [ ! -f ${HDIR}/.config/xfce4/.setup ]; then
		    if [ -d ${HDIR}/sys-setup/xfce4 ]; then
			   local STYLE=""
			   local TYPE=""
               local BACK=""
               local MENU=""
	           local PList=("xfce4-clipman-plugin" "xfce4-whiskermenu-plugin" "lxterminal"
                            "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-volman"
                            "networkmanager" "network-manager-applet")
			   _add_by_list ${PList[*]}

			   _task-begin "Clear Existing XFCE Configuration"
               _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.config/xfce4/"
	           _run "rm -rf ${HDIR}/.config/xfce4/*"
	           if [ -d ${HDIR}/.config/xfce4/xfconf/ ]; then _run "rm -rf ${HDIR}/.config/xfce4/*"; fi
	           if [ -d ${HDIR}/.config/xfce4/xfconf/ ]; then _run "rm -rf ${HDIR}/.config/xfce4/*"; fi
	           if [ -d ${HDIR}/.config/xfce4/xfconf/ ]; then _run "rm -rf ${HDIR}/.config/xfce4/*"; fi
	           if [ -d ${HDIR}/.config/xfce4/xfconf/ ]; then _run "rm -rf ${HDIR}/.config/xfce4/*"; fi
               _task-end

			   # === Yellow Backgrounds ===
			   # vyYvUseebgNgzzGQ.jpg  # Yellow Misty Lake
			   # eGna2qBdawpRZpuq.jpg  # Yellow Tree
			   # auUagbqqV2gbGi8w.jpg  # Yellow Toronto
			
			   # === Blue Backgrounds ===
			   # 8pplzWJvxVoxqrCE.jpg  # Volcano Lake
			   # oC8iorz2BlyAeEQi.jpg  # Blue Dock
			   # Cv0ZEeqOw7vMz1ez.jpg  # Blue Toronto
               
               #== Yellow Icon Sets ===
               # gnome-dust
               # Windows Vista
               # Boston cardboard
               # buuf-nestort
               # Tango
               
               #== Blue Icon Sets ===
               # Flatery-Sky
               # kuyen-icons
               # gnome-brave
               # Tango
               
               #== Yellow Theme Sets ===
               # Skeuos-Yellow-Dark
               # Orchis-Yellow-Dark
               
               #== Blue Theme Sets ===
               # Fluent-Dark
               # Skeuos-Blue-Dark
               # Goldy-Dark-GTK
               # Orchis-Dark
               
               case ${LAY^^} in
                  'TOPYELLOW') 
                     STYLE="xfce_top_yellow.zip"
                     TYPE="Top"
                     ICON="gnome-dust"
                     THEME="Skeuos-Yellow-Dark"
                     BACK="/usr/share/backgrounds/eGna2qBdawpRZpuq.jpg"
                     MENU="menu_13.png"
                     ;;
                  'TOPBLUE') 
                     STYLE="xfce_top_blue.zip"
                     TYPE="Top"
                     ICON="Tango"
                     THEME="Goldy-Dark-GTK"
                     BACK="/usr/share/backgrounds/oC8iorz2BlyAeEQi.jpg"
                     MENU="menu_05.png"
                     ;;
                  'BOTTOMYELLOW') 
                     STYLE="xfce_bottom_yellow.zip"
                     TYPE="Bottom"
                     ICON="gnome-dust"
                     THEME="Skeuos-Yellow-Dark"
                     BACK="/usr/share/backgrounds/eGna2qBdawpRZpuq.jpg"
                     MENU="menu_13.png"
                     ;;
                  'BOTTOMBLUE') 
                     STYLE="xfce_bottom_blue.zip"
                     TYPE="Bottom"
                     ICON="Tango"
                     THEME="Goldy-Dark-GTK"
                     BACK="/usr/share/backgrounds/oC8iorz2BlyAeEQi.jpg"
                     MENU="menu_05.png"
                     ;;
               esac

               # Install Custom Icons & Themes
	           _customize_icons
		       _customize_themes

			   _task-begin "Download XFCE ${TYPE} Default Configuration"
               _run "rm -rf ${HDIR}/.config/xfce4/*"
               _run "rm -rf ${HDIR}/.config/xfce4/*"
               _run "rm -rf ${HDIR}/.config/xfce4/*"
               _run "cd ${HDIR}/.config/xfce4/"
               _run "mv -f ${HDIR}/sys-setup/xfce4/${STYLE} ${HDIR}/.config/xfce4/"
               _run "chown -R ${SUDO_USER}:${SUDO_USER} ${HDIR}/.config/xfce4/"
			   _run "unzip -o -q ${STYLE}"
               _run "rm -f ${HDIR}/.config/xfce4/${STYLE}"
               _run "cd ${HDIR}"
			   _task-end

               _task-begin "Set Desktop Background"
               MON=("monitor0" "monitor1" "monitorVGA-1" "monitorLVDS1" "monitorLVDS-1"
                    "monitorHDMI1" "monitorHDMI2" "monitorHDMI-0" "monitorHDMI-1" "monitorHDMI-2"
                    "monitorDVI-I-1" "monitorDVI-D-0" "monitorDVI-D-1" "monitorDP-1"
                    "monitorVirtual-1" "monitorVirtual-2" "monitorVirtual1" "monitorVirtual2")
               WORK=("workspace0" "workspace1" "workspace2" "workspace3")
               for myMon in "${MON[@]}"
               do
                 for myWork in "${WORK[@]}"
                 do
                    _setXValue "xfce4-desktop" "/backdrop/screen0/$myMon/$myWork/color-style" "0" "int"
                    _setXValue "xfce4-desktop" "/backdrop/screen0/$myMon/$myWork/image-style" "5" "int"
                    _setXValue "xfce4-desktop" "/backdrop/screen0/$myMon/$myWork/image-path" ""
                    _setXValue "xfce4-desktop" "/backdrop/screen0/$myMon/$myWork/last-image" "$BACK"
                 done
               done
               _task-end
                
               # General Settings 
               _task-begin "Set Default Fonts, Icons, and Themes"
               _setXValue "xsettings" "/Gtk/FontName" "Sans 10"
               _setXValue "xsettings" "/Gtk/MonospaceFontName" "Monospace 10"
               _setXValue "xsettings" "/Gtk/ToolbarIconSize" "3" "int"
               _setXValue "xsettings" "/Gtk/ToolbarStyle" "icons"
               _setXValue "xsettings" "/Net/IconThemeName" "$ICON"
               _setXValue "xsettings" "/Net/ThemeName" "$THEME"
               _setXValue "xsettings" "/Xfce/SyncThemes" "true" "bool"
               _task-end
                
               # Hide Suspend, Hibernate, and Hybrid Sleep from the logout dialog:
               _task-begin "Set Shutdown/Power Settings"
               _setXValue "xfce4-session" "/shutdown/ShowSuspend" "false" "bool"
               _setXValue "xfce4-session" "/shutdown/ShowHibernate" "false" "bool"
               _setXValue "xfce4-session" "/shutdown/ShowHybridSleep" "false" "bool"
               _task-end
                               
               #Desktop Setup
               _task-begin "Set Desktop Settings"
               _setXValue "xfce4-desktop" "/backdrop/desktop-icons/file-icons/show-filesystem" "false" "bool"
               _setXValue "xfce4-desktop" "/backdrop/desktop-icons/file-icons/show-home" "false" "bool"
               _setXValue "xfce4-desktop" "/backdrop/desktop-icons/file-icons/show-removable" "false" "bool"
               _setXValue "xfce4-desktop" "/backdrop/desktop-icons/file-icons/show-trash" "true" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/file-icons/show-filesystem" "false" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/file-icons/show-home" "false" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/file-icons/show-removable" "false" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/file-icons/show-trash" "true" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/primary" "true" "bool"
               _setXValue "xfce4-desktop" "/desktop-icons/style" "1" "int"
               _task-end
               
               _task-begin "Set Whiskermenu Icon"
               FILE="${HDIR}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
               _run "sed -i 's/menu_13.png/$MENU/g' $FILE"
               _run "cd ${HDIR}/.config/xfce4/"
               local SRCH=$(grep -rl 'button-icon=' . | grep -v 'show-button') >/dev/null 2>&1
               _log-msg "Looking For: $SRCH"
			   for myFILE in ${SRCH}; do
                 _log-msg "Processing: ${myFILE}"
                 if [ -f ${myFILE} ]; then
                    _log-msg "Replacing menu_13.png with ${MENU} in ${myFILE}"
		            _run "sed -i 's#menu_13.png#${MENU}#g' ${myFILE}"
                 fi
               done
               _task-end
               
               printf "\n"
               _run "cd ${HDIR}"
               _run "touch ${HDIR}/.config/xfce4/.setup"
	        fi
         fi
      fi
   fi
}

function _customize_cinnamon {
   if (( $(_Exists "cinnamon") > 0 )); then
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
              'BOTTOMYELLOW')
                 COLOR="YELLOW"
                 BACK="eGna2qBdawpRZpuq.jpg"
                 THEME="Skeuos-Yellow-Dark"
                 ICON="gnome-dust"
                 MENU="menu_13.png"
	             ;;
              # ================ Blue Theme ====================
              'BOTTOMBLUE') 
                 COLOR="BLUE"
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

function _prereqs {
   MYUID=$(grep $SUDO_USER /etc/passwd | cut -f3 -d':')
   ADDR="unix:path=/run/user/$MYUID/bus"
   local NIXPATH="nix/profiles"
   
   if [[ ${PATH^^} != *${NIXPATH^^}* ]]; then
      _log-msg "Adding NIX path to PATH variable"
      PATH="/home/$SUDO_USER/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
   fi
   
   if [[ ! -f ${HDIR}/param.dat ]]; then
      printf "\n  ${YELLOW}Install Prerequisites${RESTORE}\n\n"
      case ${OS^^} in
        'ALPINE') _task-begin "Updating Linux System"
                  _run "apk update"
                  _run "apk upgrade"
				  _task-end
				  if (( $(_Exists "flatpak") == 0 )); then
				    _task-begin "Installing Flatpak & Git"
                    _run "apk add flatpak git"
                    _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
                    _task-end
                  fi
                  if [[ ! -d /nix/store ]]; then
                     _task-begin "Installing NIX Package Manager"
                     _run "apk add sudo bash xz curl shadow"
                     _run "wget -q https://nixos.org/nix/install"
                     _run "sed -i s'#curl --fail -L#curl --fail -s -L#' install"
                     _run "sed -i s'#{ wget #{ wget -q #' install"
                     _run "sh install --daemon --yes"
                     _run "rm -f /etc/init.d/nix-daemon"
                     _run "touch /etc/init.d/nix-daemon"
                     echo '#!/sbin/openrc-run' >> /etc/init.d/nix-daemon
                     echo 'description="Nix multi-user support daemon"' >> /etc/init.d/nix-daemon
                     echo ' ' >> /etc/init.d/nix-daemon
                     echo 'command="/usr/sbin/nix-daemon"' >> /etc/init.d/nix-daemon
                     echo 'command_background="yes"' >> /etc/init.d/nix-daemon
                     echo 'pidfile="/run/$RC_SVCNAME.pid"' >> /etc/init.d/nix-daemon
                     _run "chmod a+rx /etc/init.d/nix-daemon"
                     _run "cp /root/.nix-profile/bin/nix-daemon /usr/sbin"
                     _run "rc-update add nix-daemon"
                     _run "rc-service nix-daemon start"
                     _run "adduser ${SUDO_USER} nixbld"
                     _run "rm -f install"
                     _task-end
                     printf "\n\n"
                     _AskYN "Must reboot to complete install of Nix Package Manager" "Y"
                     reboot
                     printf "\n\n"
                  fi
                  ;;
        'DEBIAN') _task-begin "Updating Linux System"
                  _run "apt-get update"
                  _run "apt-get full-upgrade -y"
                  _run "apt-get autoremove -y"
				  _task-end
				  if (( $(_Exists "flatpak") == 0 )); then
				     _task-begin "Installing Flatpak & Git"
                     _run "apt-get install -y flatpak git"
                     _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
                     _task-end
				  fi
                  if [[ ! -d /nix/store ]]; then
                     _task-begin "Installing NIX Package Manager"
                     _run "wget -q https://nixos.org/nix/install"
                     _run "sed -i s'#curl --fail -L#curl --fail -s -L#' install"
                     _run "sed -i s'#{ wget #{ wget -q #' install"
                     _run "sh install --daemon --yes"
					 _run "adduser ${SUDO_USER} nixbld"
					 _run "rm -f install"
                     _task-end
                     printf "\n\n"
                     _AskYN "Must reboot to complete install of Nix Package Manager" "Y"
                     reboot
                     printf "\n\n"
                  fi
                  ;;
          'ARCH') _task-begin "Updating Linux System"
                  _run "pacman -Syu --noconfirm --needed git base-devel"
				  if (( $(_Exists "yay") == 0 )); then
                     _run "git clone https://aur.archlinux.org/yay.git"
                     _run "cd yay && makepkg -si"
				  fi
				  if (( $(_Exists "flatpak") == 0 )); then
				     _task-begin "Installing Flatpak"
                     _run "yay -Syu --noconfirm flatpak"
                     _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
                     _task-end
				  fi
                  if [[ ! -d /nix/store ]]; then
                     _task-begin "Installing NIX Package Manager"
                     _run "wget -q https://nixos.org/nix/install"
                     _run "sed -i s'#curl --fail -L#curl --fail -s -L#' install"
                     _run "sed -i s'#{ wget #{ wget -q #' install"
                     _run "sh install --daemon --yes"
				     _run "adduser ${SUDO_USER} nixbld"
					 _run "rm -f install"
                     _task-end
                     printf "\n\n"
                     _AskYN "Must reboot to complete install of Nix Package Manager" "Y"
                     reboot
                     printf "\n\n"               
                  fi
                  ;;
        'FEDORA') _task-begin "Updating Linux System"
                  _run "dnf update"
                  _run "dnf upgrade --refresh"
                  _run "dnf autoremove"
                  _run "dnf install flatpak git"
				  if (( $(_Exists "flatpak") == 0 )); then
				     _task-begin "Installing Flatpak"
                     _run "flatpak remote-add --if-not-exists 'flathub' 'https://flathub.org/repo/flathub.flatpakrepo'"
                     _task-end
				  fi
                  if [[ ! -d /nix/store ]]; then
                     _task-begin "Installing NIX Package Manager"
                     _run "wget -q https://nixos.org/nix/install"
                     _run "sed -i s'#curl --fail -L#curl --fail -s -L#' install"
                     _run "sed -i s'#{ wget #{ wget -q #' install"
                     _run "sh install --daemon --yes"
				     _run "adduser ${SUDO_USER} nixbld"
					 _run "rm -f install"
                     printf "\n\n"
                     _AskYN "Must reboot to complete install of Nix Package Manager" "Y"
                     reboot
                     printf "\n\n"
                  fi
                  ;;
      esac
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
   _desktop_menu
   _layout_menu

   if [[ ${DSK^^} != "QUIT" ]]; then
       _install_Desktop
       
       #==================================
       # Remove non required applications
       #==================================
       local PROG=()
       printf "\n${LPURPLE}=== Remove Unrequired Packages ===${RESTORE}\n"
       _del_by_list ${DELList[*]}
       
       case ${OS^^} in
         'ALPINE') ;;
         'DEBIAN') _run "apt-get autoremove -y" ;;
           'ARCH') _run "pacman -Qtdq | pacman --noconfirm -Rns -" ;;
         'FEDORA') _run "dnf autoremove" ;;
       esac

       #==================================
       # Restarting System
       #==================================
       printf "\n\n${LPURPLE}=== Restarting System - End of Step 1 ===${RESTORE}\n"
       _AskYN "OK to Reboot Now (y/n)" "Y"
       if [ ${REPLY^^} = "Y" ]; then reboot; fi
   fi
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
  
   case ${OS^^} in
     'ALPINE') PList=("7zip" "acpi" "acpid" "alsa-utils" "apt-transport-https" "avahi-utils" "bash"
                      "bash-completion" "bluez" "blueman" "cifs-utils" "cups" "curl" "dconf-cli"
			          "dbus-x11" "fileroller" "git" "gvfs" "gvfs-backends" "jq" "nano" "pipewire" "pipewire-alsa"
                      "pipewire-audio" "pipewire-pulse" "rar" "libspa-0.2-bluetooth" "preload" "sed" "sudo"
                      "udisks2" "unzip" "wget" "zram-tools")
               ;;
     'DEBIAN') # Upgrade Linux Reposistories
               _task-begin "Updating Linux Reposistory Permissions"
               if [[ ! -f /etc/apt/apt.conf.d/10sandbox ]]; then touch /etc/apt/apt.conf.d/10sandbox; fi
               printf "APT::Sandbox::User \"root\";" | tee -a /etc/apt/apt.conf.d/10sandbox >>$LOG 2>&1
               _run "apt-get update"
               _task-end

               PList=("7zip" "acpi" "acpid" "alsa-utils" "avahi" "bash" "bash-completion" "bluez"
			          "blueman" "cifs-utils" "cups" "curl" "dconf" "dbus-x11" "file-roller" "git"
					  "gvfs" "gvfs-fuse" "gvfs-smb" "gvfs-mtp" "gvfs-nfs" "jq" "nano" "networkmanager"
					  "networkmanager-wifi" "networkmanager-bluetooth" "pipewire" "pipewire-spa-bluez"
					  "pipewire-alsa" "pipewire-pulse" "rar" "sed" "sudo" "udisks2" "unzip" "wget")
               ;;
       'ARCH') PList=("7zip" "acpi" "acpid" "alsa-utils" "avahi" "bash"
                      "bash-completion" "bluez" "blueman" "cifs-utils" "cups" "curl" "dconf"
			          "dbus-x11" "file-roller" "git" "gvfs" "gvfs-fuse" "gvfs-smb" "gvfs-mtp" "gvfs-nfs"
                      "jq" "nano" "networkmanager" "networkmanager-wifi" "networkmanager-bluetooth"
                      "pipewire" "pipewire-spa-bluez" "pipewire-alsa" "pipewire-pulse" "rar" "sed" "sudo"
                      "udisks2" "unzip" "wget")
               ;;
     'FEDORA') PList=("7zip" "acpi" "acpid" "alsa-utils" "avahi" "bash"
                      "bash-completion" "bluez" "blueman" "cifs-utils" "cups" "curl" "dconf"
			          "dbus-x11" "file-roller" "git" "gvfs" "gvfs-fuse" "gvfs-smb" "gvfs-mtp" "gvfs-nfs"
                      "jq" "nano" "networkmanager" "networkmanager-wifi" "networkmanager-bluetooth"
                      "pipewire" "pipewire-spa-bluez" "pipewire-alsa" "pipewire-pulse" "rar" "sed" "sudo"
                      "udisks2" "unzip" "wget")
               ;;
   esac

  #===============================
  # Install required system files
  #===============================
  printf "\n${LPURPLE}=== Install Required System Files ===${RESTORE}\n"
  _add_by_list ${PList[*]}

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
     local SSHKey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAiLjHqU7bHolOTinh2fnY0l6KKCqqkEGEv8WOCHAZNTLhrIYRyFlG2PLO9o+/kzSqtWW7ZWyRlAo4FIgu3DE64iNYFnKVfreiKCuD3t8AT8MXMORd+owcqfx7W/KqV3+ZDvA5x0K+4h6vvN1fLswL71fM70WkgQDhmvXz6Eu80KYYOxpyV9rFoH/EM2lLUawhNTsAeFak0FBAaIuTSLUAvoG9v0EbmEViga6JLoSuMllbeGvqQIr51qX1opnrylTN01c6CakeyCva8Hiqum7O1vchQyzW6B+t50TYcKTnQtFmxDujhW1ILB1wXPS1DskPaECZu0gXce8dsHUpyZ2sMu94FaqMhHbEgAZRepsPlNZfeHOxz/PhOlU5NG+oIXvWOKHWMvoHDEqDHnNbjzXZlakO+euyHqn8VfLxY2gJPQFopfI4t4Sr/JjDcWkKubyqN0aXtY1i+d+y9/osWG7OwFwtr41xmikWoVpUGBeOU2DVJlMGNS7BZUAwcyc79n5HpRkM81neJiCDTFFMzyYKh1dlGydxTNzGZHza4Fi/rHBOot1p3ipxrXXM0D/aEsZuriZwcpoK75Pc1DAH2T76QIXNSKfK45BWeXAlK0iXmgTONw6djPCKpKsqb6kEoU3dqLBJGNBlIg0gwKVMpAn8GLRjj6NzqjHni7kl3SXgOXM= rsa-key-20201229"
	 _run "sed -i 's/#Port 22/Port 9922/' /etc/ssh/sshd_config"
	 _run "sed -i 's/PermitRootLogin /#PermitRootLogin/' /etc/ssh/sshd_config" 
	 _run "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
     if [ ! -d ${HDIR}/.ssh ]; then _run "mkdir -p ${HDIR}/.ssh"; fi
     if [ ! -f ${HDIR}/.ssh/authorized_keys ]; then _run "touch ${HDIR}/.ssh/authorized_keys"; fi
     _run "echo ${SSHKey} > ${HDIR}/.ssh/authorized_keys"
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

  #==================================
  # Starting Services
  #==================================
  printf "\n${LPURPLE}=== Starting Services ===${RESTORE}\n"
  _task-begin "Starting Services"
  case ${OS^^} in
     'ALPINE') _run "rc-update add acpid"
               _run "rc-update add avahi-daemon"
               _run "rc-update add cupsd"
               _run "rc-update add bluetooth"
               _run "rc-service sshd restart"
               _run "rc-service networkmanager start"
               ;;
     'DEBIAN') _run "systemctl enable acpid"
               _run "systemctl enable avahi-daemon"
               _run "systemctl enable cups"
               _run "systemctl enable network-manager"
               _run "systemctl enable bluetooth" 
               ;;
       'ARCH')  
               ;;
     'FEDORA') 
               ;;
   esac
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
   _add_by_list ${ADDList[*]}=
   
   #====================================
   # Update NIX package symbolic links
   #====================================
   if [[ ${OS^^} == 'DEBIAN' ]]; then
      _task-begin "Setting NIX Package Symbolic Links"
      _run "ln -s /root/.nix-profile/share/applications/* /usr/share/applications/"
      _run "ln -s /root/.nix-profile/bin/* /usr/bin/"
      for NDIR in $(ls /root/.nix-profile/share/icons/hicolor); do
        _run "ln -s /root/.nix-profile/share/icons/hicolor/$NDIR/apps/* /usr/share/icons/hicolor/$NDIR/apps/"
     done
	 _run "gtk-update-icon-cache -f -t /usr/share/icons/hicolor/"
	 _task-end
   fi   
  
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
   _log-msg "Parameters After Read - Desktop=$DSK, Layout=$LAY"
   _task-end


   # === Get Setup File ===
   _get_setup_file
   
   # === Seup User ===
   _customize_user_environment

   # === Customize Desktop Environment ===
   printf "\n${LPURPLE}=== Customize Desktop Environment ===${RESTORE}\n\n"
   case ${DSK^^} in
         'XFCE') if (( $(_Exists "xfce4") > 0 )); then _customize_xfce; fi ;;
       'BUDGIE') if (( $(_Exists "budgie-desktop") > 0 )); then _customize_budgie; fi ;;
     'CINNAMON') if (( $(_Exists "cinnamon") > 0 )); then _customize_cinnamon; fi ;;
   esac

   # === Customize LIGHTDM settings ===
   if (( $(_Exists "lightdm") > 0 )); then _customize_lightdm; fi

   # === Customize GRUB Settings ===
   if [[ ${OS^^} != "ALPINE" ]]; then _customize_grub; fi

   # === Customize LXTerminal Setup ===
   _customize_lxterminal
 
   # === Customize Plank Setup ===
   if (( $(_Exists "plank") > 0 )); then _customize_plank; fi

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
   printf "\n\t\t   ${YELLOW}${OS^^} System Setup        ${LPURPLE}Ver 2.92\n${RESTORE}"
   printf "\t\t\t\t\t${YELLOW}by: ${LPURPLE}Martin Boni${RESTORE}\n"
}

function _main_menu() {
   local ValidOPT="1,2,3,4,99"
   printf "\n\n${LPURPLE}       ${OS^^} Desktop Setup\n"
   printf "  ${LGREEN}+-------------------------------------+\n"
   printf "  |                                     |\n"
   printf "  |   1) Install Desktop Environment    |\n"
   printf "  |   2) Install System Applications    |\n"
   printf "  |   3) Install Applications           |\n"
   printf "  |   4) Customize System & Desktop     |\n"
   printf "  |                                     |\n"
   printf "  |  ---------------------------------  |\n"
   printf "  |                                     |\n"
   printf "  |  99) QUIT Menu                      |\n"
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
   local ctr=0
   local ValidDSK=""
   local dskTop=("")
   
   case ${OS^^} in
     'ALPINE') dskTop=("XFCE" "PLASMA" "MATE" "GNOME" "SWAY") ;;
            *) dskTop=("XFCE" "BUDGIE" "CINNAMON" "LXQT" "PLASMA" "MATE" "GNOME") ;;
   esac
   
   printf "  ${LPURPLE}      DESKTOP ENVIRONMENT\n"
   printf "  ${LGREEN}+---------------------------------------+\n"
   printf "  |                                       |\n"
   if [ ${#dskTop[@]} -gt 0 ]; then
     for mnu in "${dskTop[@]}"; do
       ctr=$((++ctr))
       printf "  |   %i) %-30s   |\n" $ctr "$mnu Desktop Environment"
       ValidDSK="$ValidDSK$ctr,"
     done
   fi
   printf "  |                                       |\n"
   printf "  |  99) NO Desktop                       |\n"
   printf "  |                                       |\n"
   printf "  +---------------------------------------+${RESTORE}\n\n\n"

   while [[ ${ValidDSK} != *${DSK}* ]]
   do
      _Ask " ${OVERWRITE}Choose the Desktop Environment (1-$ctr or 99)" "1" && DSK=$REPLY
   done
   
   if [[ ${REPLY} == 99 ]]; then
     DSK="QUIT"
   else
     DSK="${dskTop[$REPLY - 1]^^}"
   fi
   printf "\n\n"
 }

function _layout_menu {
   #=============================
   # Choose Desktop Layout
   #=============================
   local Layout=("")
   local ValidLAY=""
   case ${DSK^^} in
        'XFCE') Layout=("TopYellow - Top Menu, Yellow Theme"
                        "TopBlue - Top Menu, Blue Theme"
                        "BottomYellow - Top Menu, Yellow Theme"
                        "BottomBlue - Top Menu, Blue Theme")
                ;;
      'BUDGIE') Layout=("TopYellow - Top Menu, Yellow Theme"
                        "TopBlue - Top Menu, Blue Theme"
                        "BottomYellow - Top Menu, Yellow Theme"
                        "BottomBlue - Top Menu, Blue Theme")
                ;;
    'CINNAMON') 
                ;;
        'LXQT') 
                ;;
        'MATE') 
                ;;
      'PLASMA') 
                ;;
       'GNOME') 
                ;;
        'SWAY') 
                ;;
   esac
   
   printf "  ${LPURPLE}      DESKTOP LAYOUT\n"
   printf "  ${LGREEN}+-------------------------------------------------+\n"
   printf "  |                                                 |\n"
   if [ ${#Layout[@]} -gt 0 ]; then
     for mnu in "${Layout[@]}"; do
       ctr=$((++ctr))
       printf "  |   %i) %-40s   |\n" $ctr "$mnu"
       ValidLAY="$ValidLAY$ctr,"
     done
   fi   
   printf "  |                                                 |\n"
   printf "  +-------------------------------------------------+${RESTORE}\n\n\n"
   
   while [[ ${ValidLAY} != *${LAY}* ]]
   do
      _Ask " ${OVERWRITE}Choose the Desktop Layout (${MyChoices})" "1" && LAY=${REPLY}
   done
   
   if [[ ${REPLY} == 99 ]]; then
     LAY="QUIT"
   else
     LAY=$(echo "${Layout[$REPLY - 1]^^}" | cut -d ' ' -f1)
   fi
   printf "\n\n"
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
_prereqs

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