# syntax=docker/dockerfile:1.20.0
FROM base AS build

ARG TARGETARCH

# renovate: datasource=github-releases depName=transkribus-process packageName=ulsdevteam/transkribus-process
ARG TRANSKRIBUS_PROCESS_VERSION=1.1.0
ARG TRANSKRIBUS_PROCESS_FILE=v${TRANSKRIBUS_PROCESS_VERSION}.tar.gz
ARG TRANSKRIBUS_PROCESS_URL=https://github.com/ulsdevteam/transkribus-process/archive/refs/tags/${TRANSKRIBUS_PROCESS_FILE}
ARG TRANSKRIBUS_PROCESS_SHA256="8a88c135fed7668d3bdbfaefa0ca75f0cbb8daa406158784a05aea53bf0eb9f6"

# renovate: datasource=repology depName=alpine_3_22/dotnet8-sdk
ARG DOTNET_SDK_VERSION=8.0.122-r0

RUN --mount=type=cache,id=transkribus-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${TRANSKRIBUS_PROCESS_URL}" \
        --sha256 "${TRANSKRIBUS_PROCESS_SHA256}" \
        --strip \
        --dest "/source" \
    && \
    cleanup.sh

RUN --mount=type=cache,id=transkribus-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        dotnet8-sdk=="${DOTNET_SDK_VERSION}" \
    && \
    cd source && \
    dotnet publish -c Release -o /opt/transkribus && \
    cleanup.sh

FROM imagemagick
FROM base AS runtime

ARG TARGETARCH

ARG \
    # renovate: datasource=repology depName=alpine_3_22/aspnetcore8-runtime
    ASPNETCORE_VERSION=8.0.22-r0 \
    # renovate: datasource=repology depName=alpine_3_22/nodejs
    NODEJS_VERSION=22.16.0-r2 \
    # renovate: datasource=repology depName=alpine_3_22/npm
    NPM_VERSION=11.6.4-r0 \
    # renovate: datasource=npm depName=xslt3
    XSLT3_VERSION=2.7.0


# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=transkribus-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=bind,from=imagemagick,source=/packages,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add \
        /packages/imagemagick-*.apk \
        aspnetcore8-runtime=="${ASPNETCORE_VERSION}" \
        nodejs=="${NODEJS_VERSION}" \
        npm=="${NPM_VERSION}" \
    && \
    npm install -g "xslt3@${XSLT3_VERSION}" && \
    cleanup.sh

RUN create-service-user.sh \
    --name transkribus \
    --group jwt \
    /data \
    && \
    cleanup.sh

ENV \
    TRANSKRIBUS_ALTO_TO_HOCR_SEF_PATH=alto_to_hocr.sef.json \
    TRANSKRIBUS_ASPNETCORE_URLS=http://transkribus:5000/ \
    TRANSKRIBUS_ASPNETCORE_ENVIRONMENT=Production \
    TRANSKRIBUS_CONNECTION_STRING="Filename=/data/transkribus-process.db" \
    TRANSKRIBUS_USE_JWT_AUTHENTICATION=true

COPY --from=build /opt/transkribus /opt/transkribus

COPY --link rootfs /
