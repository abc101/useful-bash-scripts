#!/bin/bash

# Help menu
print_help() {
cat <<-HELP


This is used to update of drupal 8 core. Do not use drupal version UPGRADE.

 !!! DO NOT USE THIS AS SUDO or SU. !!!

When your drupal system is removed or copied, you are requested sudo priviliges.

You need to provide the following arguments:

  1) Path to your Drupal installation.
  2) Path to your new Drupal source.

Usage: (sudo) bash ${0##*/} --drupal_current=PATH --drupal_new=PATH
Example: (sudo) bash ${0##*/} --drupal_current=/var/www/drupal8.0.1 --drupal_new=/home/user/downloads/drupal8.0.1


HELP
exit 0
}

drupal_current=${1%/}
drupal_new=${2%/}

# Parse Command Line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --drupal_current=*)
        drupal_current="${1#*=}"
        ;;
    --drupal_new=*)c
    *)
      printf "\n"
      printf "**********************************************************\n"
      printf " Error: Invalid argument, run --help for valid arguments. *\n"
      printf "**********************************************************\n"
      printf "\n"
      exit 1
  esac
  shift
done

if [ -z "${drupal_current}" ] || [ ! -d "${drupal_current}/core" ] || [ ! -d "${drupal_current}/vendor" ]; then
  printf "\n"
  printf "******************************************************\n"
  printf "* Error: Please provide a valid current Drupal path. *\n"
  printf "******************************************************\n"
  print_help
  printf "\n"
  exit 1
fi

if [ -z "${drupal_new}" ] || [ ! -d "${drupal_new}/core" ] || [ ! -d "${drupal_new}/vendor" ]; then
  printf "\n"
  printf "**************************************************\n"
  printf "* Error: Please provide a valid new Drupal path. *\n"
  printf "**************************************************\n"
  print_help
  printf "\n"
  exit 1
fi

# Check the current drupal core that will be update
printf "\n"
printf "                         [Currnet your system status]\n"
printf "****************************************************************************\n"
drush --root=$drupal_current status
printf "****************************************************************************\n"
printf "\n"
printf "This is final confirmation. If you answer yes, then your system will be upgraded.\n"
printf "Is this correct information of your site that you want to upgrade?(y/n):"
read a
if [ "${a}" = "n" ] || [ "${a}" = "N" ]; then
  echo "Update terminated."
  exit 0
elif [ "$a" != "y"] && ["${a}" != "Y" ]; then
  echo "> Wrong input. Update stop."
  exit 0
fi

# drupal ownner check


# Update
printf "Archive dump..."
drush --root=$drupal_current ard
printf "done.\n"
printf "Set mainenance mode..."
drush --root=$drupal_current sset system.mainenance_mode 1
printf "done.\n"
printf "Flushing cash..."
drush --root=$drupal_current cr
printf "done.\n"

# Sudo
printf "You need sudo priviliges.\n"

# Remove current system
printf "Remove current core and vender..."
sudo rm -rf $drupal_current/core $drupal_current/vender
printf "done.\n"
printf "Revmove hidden setting files..."
sudo rm -f $drupal_current/*.* $drupal_current/.*
printf "done\n"

# Copy new system
printf "Copying new system..."
sudo cp -Rf $drupal_new/* $drupal_current
printf "done.\n"
printf "Copy new hidden setting files..."
sudo cp -f $drupal_new/.* $drupal_current
printf "done\n"

# Database table update
printf "Database update..."
drush --root=$drupal_current updb
drush --root=$drupal_current entup
printf "done.\n"

# Maintenance mode off
printf "Maintenance mode off..."
drush --root=$drupal_current sset system.maintenance_mode 0
printf "done.\n"
printf "Flushing cash..."
drush --root=$drupal_current cr
printf "done.\n"

# Check the new drupal core
printf "***********************************************************************\n"
drush --root=$drupal_current status
printf "***********************************************************************\n"
printf "Finish.\n"
