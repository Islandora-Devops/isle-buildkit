#!/usr/bin/with-contenv bash

set -e

# Make run directory if it does not exist.
mkdir /run/mysqld &> /dev/null || true
chown mysql:mysql /run/mysqld

# Create the database if it does not exist.
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
    s6-setuidgid mysql mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --skip-test-db --user mysql
fi

# Startup the database so we can change the root users password.
s6-setuidgid mysql mysqld --skip-networking &
MYSQLD_PID=$!

# Wait for it to startup.
until mysql --no-defaults --protocol=socket --user=root -e "SELECT 1" &> /dev/null; 
do
sleep 1
done

# Change the root users password.
echo "Changing the root users password."
mysql --no-defaults --protocol=socket --user=root < /var/run/islandora/set-root-user-password.sql

# Stop the database.
kill -s TERM ${MYSQLD_PID}

# Allow database to stop.
wait
