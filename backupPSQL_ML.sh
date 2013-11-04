#!/bin/bash
# The purpose of this script is to just dump the Profile Manager
# PostgreSQL database in a format suitable for pg_restore
# Antti Pettinen
# 31.10.2013
# 04.10.2013 added OS X Server 3.0 support

# test if run as sudo/root
if [ $(whoami) != "root" ]; then
        echo "Please run as sudo/root"
        exit 1
fi

# stopping profile manager
serveradmin stop devicemgr

# starting postgres
serveradmin start postgres

# dumppikomennon polku
PGDUMP=/Applications/Server.app/Contents/ServerRoot/usr/bin/pg_dump
echo "Dumping the ProfileManager database of OS X Server:"

echo "Location of the backup [current location]:"
read DUMPLOK
if [ -z "$DUMPLOK" ]; then
        DUMPLOK="$PWD/"
        echo "Saving to default location $DUMPLOK"
else
        echo "Saving to $DUMPLOK"
fi

echo "Name of the backup [prof_man_psql_dump_$(date +"%d_%m_%Y").sql]"
read DUMPNAME
if [ -z "$DUMPNAME" ]; then
        DUMPNAME="prof_man_psql_dump_$(date +"%d_%m_%Y").sql"
fi
echo "Saving as $DUMPNAME"
DUMPKOHDE=$DUMPLOK$DUMPNAME
echo "Saving the Profile Manager database to $DUMPKOHDE"

# dumping the database; flags explained briefly (see man for details):
# -h: location of the unix socket of the database
# --username: _devicemgr
# ... followed by the users database: device_management
# -b=blobs, i.e., bigger stuff also
# -F c == --format=custom for flexible pg_restore usage (see help)
# -c = clean
# The biggest caveat here is the -h flag, i.e., the unix socket, which has been known to change
# between versions of the OS X Server. PLEASE DO CHECK THIS BEFOREHAND!
# The other is the --username, which has been _postgres previously, currently _devicemgr
# the -c flag is a bit redundant, as the man file says it's best for plain text dumps.. still used just in case

#check the OS X version

OSVERSION=$(sw_vers -productVersion)
if [ "${OSVERSION:0:4}" = "10.9" -o "10.8" ]; then
        SOCKETTI="/Library/Server/ProfileManager/Config/var/PostgreSQL"
elif [ "${OSVERSION:0:4}" = "10.8" ]; then
        SOCKETTI="/Library/Server/PostgreSQL For Server Services/Socket"
else
        echo "Only 10.8 - 10.9 supported"
        exit 1
fi

# and use the correct socket for dump
$PGDUMP -h $SOCKETTI --username=_devicemgr device_management -F c -c -b  > $DUMPKOHDE
echo "Profile Manager database succesfully dumped at $DUMPKOHDE, starting Profile Manager"
#start profile manager
serveradmin start devicemgr
echo "Profile Manager up and running"
exit 0