#!/bin/sh
./wait-for-it.sh mariadb:3306 -t 300 -- echo "mariadb is up"
/usr/lib/bareos/scripts/update_bareos_tables
if [ $? -ne 0 ]; then
   /usr/lib/bareos/scripts/make_bareos_tables
fi
bareos-dir -f
# -c /etc/bareos/bareos-dir.conf
