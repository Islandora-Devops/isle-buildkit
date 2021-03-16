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
cat <<- EOF | mysql --no-defaults --protocol=socket --user=root
CREATE USER IF NOT EXISTS 'root'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
SET PASSWORD FOR 'root'@'%' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
FLUSH PRIVILEGES;
EOF

# Stop the database.
kill -s TERM ${MYSQLD_PID}

# Allow database to stop.
wait
