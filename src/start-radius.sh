#!/bin/bash

echo "========================================="
echo "Intiialising container"
echo "========================================="

echo "Check if MySQL host is ready"
ping mysql -c 1
RETVAL=$?
while [ $RETVAL -ne 0 ]; do
	sleep 5
	ping mysql -c 1
	RETVAL=$?
done

echo "Check we can connect to the database"
echo "USE mysql;" | mysql -u root --password=${MYSQL_ROOT_PASSWORD}  -h mysql
RETVAL=$?
while [ $RETVAL -ne 0 ]; do
	sleep 1
	echo "USE mysql;" | mysql -u root --password=${MYSQL_ROOT_PASSWORD}  -h mysql
	RETVAL=$?
done

echo "USE radius;" | mysql -u radius --password=radius -h mysql radius
if [ $? -ne 0 ]; then
	echo "Initialising database"
	mysql -u root -h mysql --password=${MYSQL_ROOT_PASSWORD} < /usr/src/build/sql/radius-structure.sql
fi

#do something about initialising the config

if [ "${DEBUG}" = "1" ]; then
	/usr/sbin/freeradius -f -X
else
	/usr/sbin/freeradius -f
fi
