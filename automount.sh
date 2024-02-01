#!/bin/bash

source /home/martin/.smbcredentials
if [[ ! -z ${password} ]]; then echo "$password" | sudo -s mount -a; fi