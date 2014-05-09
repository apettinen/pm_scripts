# device_management database migration tool
# Antti Pettinen
# 2014

# test if run as sudo/root
if [ $(whoami) != "root" ]; then
        echo "Please run as sudo/root"
        exit 1
fi

#declare some variables for simplicity

KAYTTAJA="_devicemgr"
KANTA="/Library/Server/ProfileManager/Config/var/PostgreSQL"
PSQL=/Applications/Server.app/Contents/ServerRoot/usr/bin/psql
PQRESTORE=/Applications/Server.app/Contents/ServerRoot/usr/bin/pq_restore
DUMPFILE="/Users/gula/prof_man_psql_dump_16_01_2014.sql"

# the re-migration command, at least for Server 3.0...
# actually this just WIPES the existing database and then Profile Manager should
# try to re-migrate...
REMIG=/Applications/Server.app/Contents/ServerRoot/usr/share/devicemgr/config/wipeDB.sh

#
SERVERVERS=$(serverinfo --shortversion)
if [ "${SERVERVERS:0:3}" = "3.1" ]; then
	KANNANOSA="devicemgr_v2m0"
else
	KANNANOSA="device_management"
fi

# stop devicemanager
serveradmin stop devicemgr

# start postgres 
serveradmin start postgres

# destroy the old database first # there should be a check here...
dropdb -h $KANTA -U $KAYTTAJA $KANNANOSA 

# ...and create the database again (just the name)
createdb -h $KANTA -U $KAYTTAJA $KANNANOSA

# then, let's import the old database
$PQRESTORE -c -U $KAYTTAJA -d $KANNANOSA -h $KANTA $DUMPFILE 

# and remigrate using wipeDB.sh
echo "This can take a long time, be patient"
$REMIG

#start the Profile Manager
serveradmin start devicemgr
exit 0