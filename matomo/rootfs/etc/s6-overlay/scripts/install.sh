#!/command/with-contenv bash
# shellcheck shell=bash
set -e

function mysql_count_query {
  cat <<-EOF
SELECT COUNT(DISTINCT table_name)
FROM information_schema.columns
WHERE table_schema = '${MATOMO_DB_NAME}';
EOF
}

# Check the number of tables to determine if it has already been installed.
function installed {
  local count
  count=$(execute-sql-file.sh <(mysql_count_query) -- -N 2>/dev/null) || exit $?
  [[ $count -ne 0 ]]
}

function post {
  local parameters="${1}"
  local payload="${2}"
  curl -s -c /tmp/cookies -L -X POST "http://localhost/index.php?${parameters}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "${payload}" &>/dev/null
}

function add_setting {
  local section="${1}"
  local key="${2}"
  local value="${3}"
  if [[ -n "${value}" ]]; then
    s6-setuidgid nginx /var/www/matomo/console config:set --section="${section}" --key="${key}" --value="${value}"
  fi
}

function install {
    # Simulate user performing install.
    post "action=databaseSetup&clientProtocol=https" \
      "type=InnoDB&host=${DB_MYSQL_HOST}&username=${MATOMO_DB_USER}&password=${MATOMO_DB_PASSWORD}&dbname=${MATOMO_DB_NAME}&tables_prefix=&adapter=PDO\MYSQL&submit=Next »"

    post "action=setupSuperUser&clientProtocol=https&module=Installation" \
      "login=${MATOMO_USER_NAME}&password=${MATOMO_USER_PASS}&password_bis=${MATOMO_USER_PASS}&email=${MATOMO_USER_EMAIL}&submit=Next »"

    post "action=firstWebsiteSetup&clientProtocol=https&module=Installation" \
      "siteName=${MATOMO_DEFAULT_NAME}&url=${MATOMO_DEFAULT_HOST}&timezone=${MATOMO_DEFAULT_TIMEZONE}&ecommerce=0&submit=Next »"

    post "action=finished&clientProtocol=https&module=Installation&site_idSite=1&site_name=${MATOMO_DEFAULT_NAME}" \
      "setup_geoip2=1&do_not_track=1&anonymise_ip=1&submit=Continue to Matomo »"

    # Add extra tools plugin.
    s6-setuidgid nginx /var/www/matomo/console plugin:activate ExtraTools

    # Add additional configurations.
    add_setting General "assume_secure_protocol" "${MATOMO_ASSUME_SECURE_PROTOCOL}"
    add_setting General "proxy_client_headers[]" "${MATOMO_PROXY_CLIENT_HEADERS}"
    add_setting General "proxy_host_headers" "${MATOMO_PROXY_HOST_HEADERS}"
    add_setting General "force_ssl" "${MATOMO_FORCE_SSL}"
    add_setting General "proxy_uri_header" "${MATOMO_PROXY_URI_HEADER}"

    # Add subsites.
    for site in $(env | grep "MATOMO_SITE_.*_HOST" | cut -f1 -d=); do
      # shellcheck disable=SC2001
      name=$(echo "${site}" | sed -e 's/MATOMO_SITE_\(.*\)_HOST/\1/')
      s6-setuidgid nginx /var/www/matomo/console site:add --name="${name}" --urls="${!site}"
    done
}

# External processes can look for `/installed` to check if installation is completed.
function finished {
    touch /installed
    cat <<-EOT


#####################
# Install Completed #
#####################
EOT
}

function main {
  # Wait for Nginx to be ready.
  s6-svwait -U /run/service/nginx

  if installed; then
    echo "Already Installed"
  else
    echo "Installing"
    install
  fi
  finished
}
main
