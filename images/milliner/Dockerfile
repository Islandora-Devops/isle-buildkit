# syntax=docker/dockerfile:1.5.1
FROM crayfish

ARG TARGETARCH

EXPOSE 8000

WORKDIR /var/www/crayfish/Milliner/

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=milliner-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/public /var/www/html && \
    cleanup.sh

ENV \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_FEDORA6=true \
    MILLINER_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
