#!/bin/bash

# Help
print_help() {
cat <<-HELP
This script is used to install drupal project by drush.
you need to provide the following arguments:

  1) Project name.
  2) database username.
  3) Database name.
  4) Database password.
  5) Site name.
  6) Project account name
  7) Project account password

Usage: bash ${0##*/} --project=PATH --db-user=DBUSER --db-pass=DBPASS --db-name=DBNAME --site-name=SITE_NAME --account-name=ACCOUNT --account-pass=PASSWORD
Example: bash ${0##*/} --project=myproject --db-user=user --db-pass=mydbpas --db-name=mydb --site-name=sitename --account-name=myaccount -account-pass=mypassword
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  sudo="sudo"
fi

project=${1}
dbuser=${2}
dbpass=${3}
dbname=${4}
site=${5}
accname=${6}
accpass=${7}

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project=*)
        project="${1#*=}"
        ;;
    --db-user=*)
        dbuser="${1#*=}"
        ;;
    --db-pass=*)
        dbpass="${1#*=}"
        ;;
    --db-name=*)
        dbname="${1#*=}"
        ;;
    --site-name=*)
        site="${1#*=}"
        ;;
    --account-name=*)
        accname="${1#*=}"
        ;;
    --account-pass=*)
        accpass="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "***********************************************************\n"
      printf "* Error: Invalid argument, run --help for valid arguments. *\n"
      printf "***********************************************************\n"
      exit 1
  esac
  shift
done

if [ -d "${project}" ]; then
  printf "The project already exist. Do you wnat clean install?(y/n)"
  read a
  if [ "${a}" == "n" ]; then
    exit 1
  fi
  ${sudo} rm -r ${project}
fi

printf "Downloading drupal core... \n\n"
drush dl drupal --drupal-project-rename=${project}
printf "done.\n"
printf "Change the drectory ownership... "
chmod -R g+w ${project}
${sudo} chown -R www-data:www-data ${project}
printf "done.\n"
printf "Installing $project... \n\n"
cd ${project}
mysql="mysql://${dbuser}:${dbpass}@localhost/${dbname}"
drush site-install standard --db-url=${mysql} --site-name=${site} --account-name=${accname} --account-pass=${accpass}
printf "done.\n"
printf "Change the default sites setting ownner ship... "
${sudo} chown -R www-data:www-data sites/default
printf "done.\n"
