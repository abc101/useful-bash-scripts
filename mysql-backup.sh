#!/bin/bash
# Backup MySQL databases by Songmin Kim

# Backup directory path
backup_parent_dir="/srv/backup/mysql"

# Create backup directory
if [ ! -d ${backup_parent_dir} ]; then
=======
then
	mkdir -p ${backup_parent_dir}
		if [ "$?" = "0" ]; then
			:
		else
			echo "Fail to create backup folder."
		fi
else
	:
fi

# write date information to a log file
exec &>> ${backup_parent_dir}/backup.log
echo "****************************"
echo "*     Backup date time     *"
echo "* $(date +%c) *"
echo "****************************"
echo

# MySQL settings
mysql_user="root"
mysql_password="password"

# check MySQL password
echo exit | mysql --user=${mysql_user} --password=${mysql_password} -B 2>/dev/null
if [ "$?" -gt 0 ]; then
  echo "MySQL ${mysql_user} password incorrect"
  exit 1
else
  echo "MySQL ${mysql_user} password correct."
fi

# create backup directories and set permissions
backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Backup directory: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

# get MySQL databases except information_schema and performance_schema
mysql_databases=`echo 'show databases' | mysql --user=${mysql_user} --password=${mysql_password} -B | sed /^Database$/d | egrep -vi 'information_schema|performance_schema'`

# backup and compress each database
for database in ${mysql_databases}
do
  printf "Creating backup of \"${database}\" database ..."
  mysqldump --user=${mysql_user} --password=${mysql_password} --single-transaction --routines --triggers ${database} | gzip > "${backup_dir}/${database}.gz"
  chmod 600 "${backup_dir}/${database}.gz"
	printf "done.\n"
done

# remove backups older than 7 days
find ${backup_parent_dir} -maxdepth 1 -type d -mtime +7 -exec printf {} "will be removed.\n" \;
find ${backup_parent_dir} -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
echo
echo "********* End Work **********"
echo
