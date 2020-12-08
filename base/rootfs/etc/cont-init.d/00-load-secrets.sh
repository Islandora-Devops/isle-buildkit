#!/usr/bin/with-contenv bash
set -e

# Read any secret files specified in environment variables.
echo "$(env | grep '=secret:')" | while read line
do
    # Skip empty lines
    [[ -z $line ]] && continue

    # Hack out the path to the secret.
    environment_variable=$(echo $line | cut -d= -f1)
    secret=$(echo $line | cut -d= -f2 | cut -d: -f2)

    # Load the secret's value into the environment variable
    if [ -f ${secret} ]; then
        s6-env -i ${environment_variable}="$(cat ${secret})" s6-dumpenv -- /var/run/s6/container_environment
    fi
done
