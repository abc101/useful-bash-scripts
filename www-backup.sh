#!/bin/bash
# Backup www by Songmin Kim
# Update: Dec 14 2016

# set backup directory path
backup_parent_dir="/srv/backup/www"

# create backup directories
if [ ! -d $backup_parent_dir ]; then
	mkdir -p $backup_parent_dir
		if [ "$?" = "0" ]; then
			:
		else
			echo "Fail to create backup folder!"
		fi
else
	:
fi

# write date information to the log file
exec &>> $backup_parent_dir/backup.log
echo "****************************"
echo "*     Backup date time     *"
echo "* $(date +%c) *"
echo "****************************"
echo

# create backup sub directory and set permissions
backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Backup directory: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

# each directory compress on $HOME/public_html
dirlist=`find /srv/www -maxdepth 1 -mindepth 1 -exec basename {} \;`
for dir in $dirlist
do
	echo -n "Start compressing /srv/www/$dir ... "
	tar czf ${backup_dir}/$dir.tar.gz -C /srv/www/ $dir
	echo "Success."
	echoRemoved if there is older than 7days folders
done

# remove backup files older than 7 days
find $backup_parent_dir -maxdepth 1 -type d -mtime +7 -exec echo {} "will be removed."\;
find $backup_parent_dir -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
echo
echo "Removed if there is older than 7days folders"
echo
echo "********* End Work **********"
echo
