FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.21 AS build

ARG IMAGEMAGICK_VERSION=7.1.1-47
ARG IMAGEMAGICK_SHA256=6eb2f2adda0b768af2e6abb14f0a2f9187d623420b8430c9d64216bd40c646bf
ARG TRANSKRIBUS_PROCESS_VERSION=1.1.0

# build imagemagick with jp2 support
RUN apk add build-base \
	autoconf \
	automake \
	libtool \
	zlib-dev \
	libxml2-dev \
	jpeg-dev \
	glib-dev \
	libjpeg-turbo-dev \
	openjpeg-dev \
	openjpeg
WORKDIR /usr/local/src
ADD --checksum=sha256:${IMAGEMAGICK_SHA256} \
    https://imagemagick.org/archive/ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz .
RUN tar xzvf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
RUN cd ImageMagick-${IMAGEMAGICK_VERSION} && ./configure --with-jpeg --with-openjpeg && make && make install

# build transkribus microservice
WORKDIR /source
ADD https://github.com/ulsdevteam/transkribus-process/archive/refs/tags/v${TRANSKRIBUS_PROCESS_VERSION}.tar.gz .
RUN tar xzvf v${TRANSKRIBUS_PROCESS_VERSION}.tar.gz
RUN cd transkribus-process-${TRANSKRIBUS_PROCESS_VERSION} && dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.21 AS runtime

# copy imagemagick files and install additional dependencies
COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /usr/local/lib/* /usr/local/lib/
COPY --from=build /usr/local/include/* /usr/local/include
RUN apk add openjpeg jpeg-dev libbz2 libgomp libxml2-dev xz-dev

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
