#!/bin/bash
# Backup www by Songmin Kim

# set backup directory path
backup_parent_dir="/srv/backup/www"

# set target directory
target_dir="/var/www"

# create backup directories
if [ ! -d ${backup_parent_dir} ]; then
	mkdir -p ${backup_parent_dir}
		if [ "$?" = "0" ]; then
			:
		else
			echo "Fail to create backup folder!"
		fi
else
	:
fi

# write date information to the log file
exec &>> ${backup_parent_dir}/backup.log
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
dirlist=`find ${target_dir} -maxdepth 1 -mindepth 1 -exec basename {} \;`
for dir in ${dirlist}
do
	printf "Start compressing ${target_dir}/${dir} ... "
	tar czf ${backup_dir}/${dir}.tar.gz -C ${target_dir} ${dir}
	printf "done.\n"
done

# remove backup files older than 7 days
find $backup_parent_dir -maxdepth 1 -type d -mtime +7 -exec printf {} "will be removed.\n" \;
find $backup_parent_dir -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
echo
echo "********* End Work **********"
echo
