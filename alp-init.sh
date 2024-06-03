#!/bin/ash

USR="martin"
if [[ ! -z $1 ]]; then USR=$1; fi

#=============================
# Setup Alpine Repositories
#=============================
RET=$( cat /etc/apk/repositories | grep -c 'uwaterloo.ca/alpine/edge/community' )
if [ ${RET} == 0 ]; then
    mv /etc/apk/repositories /etc/apk/repositories.bak
    touch /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/main' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/latest-stable/community' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/main' >> /etc/apk/repositories
    echo 'http://mirror.csclub.uwaterloo.ca/alpine/edge/community' >> /etc/apk/repositories
    echo '#http://mirror.csclub.uwaterloo.ca/alpine/edge/testing' >> /etc/apk/repositories
fi

#=============================
#  Setup SUDO for Users
#=============================
apk update
apk upgrade
apk add sudo bash bash-completion nano wget
if [ ! -f /etc/sudoers.d/wheel ]; then
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
fi

#=============================
#  Add User to Wheel Group
#=============================
if [ $(id ${USR} 2>/dev/null | grep -c '(${USR})') = 1 ]; then
    if [ $(id -nG ${USR} 2>/dev/null | grep -c 'wheel') = 1 ]; then  adduser ${USR} wheel; fi
fi

printf "OK to Reboot Now (y/n) [Y] "
read ANS
if [ -z $ANS ]; then ANS="Y"; fi
if [ $ANS == "Y" ]; then reboot; fi
