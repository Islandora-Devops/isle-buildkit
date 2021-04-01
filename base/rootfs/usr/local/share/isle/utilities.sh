#!/usr/bin/env bash

# Shared functions that are broadly useful, adds call stacks on error to help
# with debugging along with convenience functions.

set -E -T

function error_handler {
    local code=${1}
    local num=${BASH_LINENO[0]}
    local script=$(realpath "${BASH_SOURCE[1]}")
    set +x
    echo " "
    echo "Error: '${code}' on line '${num}' in '${script}'" >&2
    echo "Trace:"
    echo "------"
    for i in $(seq 0 $(("${#BASH_LINENO[@]}"-2))); do # Do no include the error_handler.
       local j=$(($i+1)) # Offset to account for error_handler.
       script=$(realpath "${BASH_SOURCE[$j]}")
       num=${BASH_LINENO[$i]}
       echo "# ${i} File: ${script}, Line: ${BASH_LINENO[$i]} Function: ${FUNCNAME[$j]:-}" >&2
       awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=${num} ${script} >&2
       echo "------"
    done
    exit ${code}
}
trap 'error_handler ${?}' ERR

function exit_handler {
    local code=${1}
    if [[ "${code}" == "0" ]]; then
        echo "Exited Successfully"
    else
        echo "Failed with exit code: ${code}"
    fi
    exit ${code}
}
trap 'exit_handler ${?}' EXIT

# Wait for a 20x response at the given address.
function wait_20x {
    local address=${1}; shift 
    echo "Waiting for reponse on $address"
    while ! curl --fail -i -X GET "${address}" &> /dev/null; do
        sleep 5
    done
}

# Checks if the given variable value matches against the expected value.
function expect {
  local var=${1}; shift
  local value=${1}; shift
  if [[ "${!var}" != "${value}" ]]; then
    echo "Value for ${var} is '${!var}' expected '${value}'"
    exit 1
  else
    echo "Value for ${var} matches expected '${value}'"
  fi
}