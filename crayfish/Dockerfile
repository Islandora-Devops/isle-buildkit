# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/nginx:${tag} AS download

ARG COMMIT=85a8206a9ed1db302fdeb123f9d5391ef8aae001

RUN --mount=type=cache,id=crayfish-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/Islandora/Crayfish.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfish && \
    chown -R nginx:nginx /var/www

FROM ${repository}/nginx:${tag}

COPY --from=download /var/www /var/www

RUN mkdir -p /opt/keys/jwt && \
    chown nginx:nginx /opt/keys/jwt && \
    cleanup.sh

COPY rootfs /

STOPSIGNAL SIGWINCH

EXPOSE 8000
