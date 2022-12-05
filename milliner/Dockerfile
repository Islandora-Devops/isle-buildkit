# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=milliner-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/public /var/www/html

FROM ${repository}/nginx:${tag}

EXPOSE 8000

ENV \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_FEDORA6=false \
    MILLINER_LOG_LEVEL=info

WORKDIR /var/www/crayfish/Milliner/

COPY --link --from=crayfish /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --link --from=crayfish /var/www /var/www

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
