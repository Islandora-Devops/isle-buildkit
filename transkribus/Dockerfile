FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.21 AS build

ARG TRANSKRIBUS_PROCESS_VERSION=1.1.0

# build transkribus microservice
WORKDIR /source
ADD https://github.com/ulsdevteam/transkribus-process/archive/refs/tags/v${TRANSKRIBUS_PROCESS_VERSION}.tar.gz .
RUN tar xzvf v${TRANSKRIBUS_PROCESS_VERSION}.tar.gz
RUN cd transkribus-process-${TRANSKRIBUS_PROCESS_VERSION} && dotnet publish -c Release -o /app

FROM imagemagick
FROM base AS runtime

# install imagemagick from image
RUN --mount=type=bind,from=imagemagick,source=/packages,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/imagemagick-*.apk

# install asp.net runtime
RUN apk add aspnetcore8-runtime

# install xslt transformer
RUN apk add nodejs npm
RUN npm install -g xslt3

ENV \
    ASPNETCORE_URLS=http://transkribus:5000/ \
	ALTO_TO_HOCR_SEF_PATH=alto_to_hocr.sef.json \
	USE_JWT_AUTHENTICATION=true \
	CONNECTION_STRING="Filename=transkribus-process.db"

WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "transkribus-process.dll", "msvc"]
