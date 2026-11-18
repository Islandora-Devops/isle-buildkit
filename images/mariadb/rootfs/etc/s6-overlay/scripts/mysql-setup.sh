#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Make run directory if it does not exist.
mkdir /run/mysqld &>/dev/null || true
chown mysql:mysql /run/mysqld

# Create the database if it does not exist.
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
    s6-setuidgid mysql mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --skip-test-db --user mysql
fi

# Startup the database so we can change the root users password.
s6-setuidgid mysql mysqld --skip-networking &
MYSQLD_PID=$!

# Wait for it to startup.
until mysql --no-defaults --protocol=socket --user="${DB_ROOT_USER}" -e "SELECT 1" &>/dev/null; do
    sleep 1
done

# Change the root users password.
echo "Changing the root users (${DB_ROOT_USER}) password."
cat <<-EOF | mysql --no-defaults --protocol=socket --user="${DB_ROOT_USER}"
	CREATE USER IF NOT EXISTS '${DB_ROOT_USER}'@'%';
	GRANT ALL PRIVILEGES ON *.* TO '${DB_ROOT_USER}'@'%' WITH GRANT OPTION;
	SET PASSWORD FOR '${DB_ROOT_USER}'@'localhost' = PASSWORD('${DB_ROOT_PASSWORD}');
	SET PASSWORD FOR '${DB_ROOT_USER}'@'%' = PASSWORD('${DB_ROOT_PASSWORD}');
	FLUSH PRIVILEGES;
EOF

# Stop the database.
kill -s TERM "${MYSQLD_PID}"

# Allow database to stop.
wait
