FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.21 AS build

WORKDIR /source
RUN apk add git
RUN git clone https://github.com/ulsdevteam/transkribus-process.git .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.21 AS runtime

RUN apk add imagemagick nodejs npm
RUN npm install -g xslt3

WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "transkribus-process.dll", "msvc"]
