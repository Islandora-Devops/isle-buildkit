# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG COMMIT=22bc67f0906d3a45148d585b28dbc94fc81151ca

RUN --mount=type=cache,id=crayfish-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/nigelgbanks/Crayfish.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfish

FROM ${repository}/composer:${tag}

COPY --link --from=download /var/www /var/www

COPY --link rootfs /
