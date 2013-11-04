#!/bin/bash
# This script sets the Profile Manager PSQL database InstalledApplicationsList to NULL
# and the asks if the migration should be done again (from 10.8.5 Server 2.2.2)
# USE WITH CAUTION! The author takes no responsibility whatsover of the possible damage done
# This script is intended for OS X Server 3.0 PSQL database ONLY!
# Antti Pettinen
# 01.11.2013

# test if run as sudo/root
if [ $(whoami) != "root" ]; then
        echo "Please run as sudo/root"
        exit 1
fi

KAYTTAJA="_devicemgr"
KANNANOSA="device_management"
KANTA="/Library/Server/ProfileManager/Config/var/PostgreSQL"
# the re-migration command, at least for Server 3.0...
# actually this just WIPES the existing database and then Profile Manager should
# try to re-migrate...
REMIG=/Applications/Server.app/Contents/ServerRoot/usr/share/devicemgr/config/wipeDB.sh
# stop the Profile Manager
serveradmin stop devicemgr    

# set the list to NULL - this is truly brute force, wiping all the apps
# a more sophisticated way would be to find out what apps might not migrate and what will
psql -U $KAYTTAJA -d $KANNANOSA -h $KANTA -c "update devices set \"InstalledApplicationList\" = NULL;"

# ask if the user
while true; do
 read -p "Do you want to re-migrate the database from backup? [Y/N]" KE
 case $KE in
 [Yy]* ) $REMIG; break;;
 [Nn]* ) break ;;
 * ) echo "Please answer yes or no"
 esac
done

# start the Profile Manager
serveradmin start devicemgr
exit 0
