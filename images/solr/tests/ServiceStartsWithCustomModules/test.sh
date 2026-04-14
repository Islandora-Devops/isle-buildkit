#!/command/with-contenv bash
# shellcheck shell=bash

set -euo pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for service to start.
wait_20x http://localhost:8983/solr

# SOLR_MODULES should be present in the environment inherited by the live Solr process.
pid="$(pgrep -u solr -n java)"
process_env="$(s6-setuidgid solr sh -c "tr '\0' '\n' < /proc/${pid}/environ")"

[[ "${process_env}" == *"SOLR_MODULES="* ]]

IFS=',' read -r -a modules <<< "${SOLR_MODULES}"
for module in "${modules[@]}"; do
  [[ "${process_env}" == *"${module}"* ]]
done
