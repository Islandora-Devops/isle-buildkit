FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.21 AS build

ARG IMAGEMAGICK_VERSION=7.1.0-16
ARG IMAGEMAGICK_SHA256=2a0a8e1a52476349764e24fd7c3568d1256ff72defcfe66764afb2237c64e421

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
RUN apk add git
RUN git clone https://github.com/ulsdevteam/transkribus-process.git .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.21 AS runtime

# copy imagemagick files and install additional dependencies
COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /usr/local/lib/* /usr/local/lib/
COPY --from=build /usr/local/include/* /usr/local/include
RUN apk add openjpeg jpeg-dev libbz2 libgomp libxml2-dev xz-dev

# install xslt transformer
RUN apk add nodejs npm
RUN npm install -g xslt3

WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "transkribus-process.dll", "msvc"]
