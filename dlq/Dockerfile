# syntax=docker/dockerfile:experimental
FROM golang:1.17-alpine3.15 as build

ARG REPO=https://github.com/jhu-idc/derivative-ms
ARG COMMIT=a4a9d0d61506057be1e3b8bc040a808b79d99592

WORKDIR /go/src/app

RUN apk add git && \
    git clone ${REPO} . && \
    git checkout ${COMMIT}

RUN go get -d -v ./... && \
    go install -v ./...

FROM alpine:3.15

WORKDIR /app

COPY --from=build /go/bin/derivative-ms ./derivative-ms

COPY rootfs/ /

ENTRYPOINT [ "./derivative-ms" ]

CMD [ "-h" ]
