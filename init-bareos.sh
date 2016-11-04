#!/bin/sh
./wait-for-it.sh mariadb:3306 -t 300 -- echo "mariadb is up"
/etc/bareos/scripts/update_bareos_tables
if [ $? -ne 0 ]; then
   /etc/bareos/scripts/make_bareos_tables
fi
bareos-dir -f -c /etc/bareos/bareos-dir.conf
