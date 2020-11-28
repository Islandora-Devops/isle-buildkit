#!/usr/bin/with-contenv /bin/bash
ENVS=$(awk 'BEGIN{for(v in ENVIRON) print v}' | grep '^DRUPAL');

echo '' > /etc/nginx/drupal_fastcgi_params  
for env in $ENVS ; do
        echo 'fastcgi_param' $env '"'${!env}'";' >> /etc/nginx/drupal_fastcgi_params;
done

cat /etc/nginx/drupal_fastcgi_params