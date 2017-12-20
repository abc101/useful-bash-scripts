#!/bin/bash
# get manufacture mac address
man="$(ifconfig $1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"

#select
if [ "$2"="new" ]; then
  openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' | xagrs sudo ifconfig "$1" ether
else
  sudo ifconfig "$1" ether "$man"
