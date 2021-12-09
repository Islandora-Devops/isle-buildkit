# ActiveMQ Dead Letter Queue (DLQ)

Provides a Docker image that will read messages from the ActiveMQ dead letter queue and emit them to stderr.

The purpose of this image is to provide observability of messages marked as undeliverable by ActiveMQ.  This may be important when diagnosing migration failures or derivative generation failures in Drupal.

## Env Vars

For a full discussion of the environment variables supported by this image, please see the README for the [derivative microservices](https://github.com/jhu-idc/derivative-ms) code repository.

## Usage

For up-to-date usage supported by this image, please see the README for the [derivative microservices](https://github.com/jhu-idc/derivative-ms) code repository.  

Obtain or build the image:
```shell
$ ./gradlew dlq:build # creates ghcr.io/jhu-sheridan-libraries/idc-isle-dc/dlq:latest
```

To connect to ActiveMQ's Dead Letter Queue (DLQ) and read off the messages, run:
```shell
$ docker run --rm --network idc_default ghcr.io/jhu-sheridan-libraries/idc-isle-dc/dlq -queue ActiveMQ.DLQ -host activemq -pass password -config ./config.json
```
* `--network idc_default` is required in order to attach this container to the backend network
* `-queue ActiveMQ.DLQ` is the name of the ActiveMQ dead letter queue read by this microservice
* `-host activemq` is the name of the ActiveMQ message broker container running on the backend network
* `-pass password` is the password used to authenticate to the ActiveMQ message broker
* `-config ./config.json` is required to use a custom configuration baked into this image used to simply log the messages from the DLQ

If you want to validate JWT tokens that are provided in message headers, you must provide the public key [of the public/private keypair] used by Drupal when signing JWT as an environment variable named `DRUPAL_JWT_PUBLIC_KEY`

## Configuration

This microservice is effectively configured by the baked in configuration, found at `./config.json` within the container.

The caller or service creating the container is responsible for setting the `DRUPAL_JWT_PUBLIC_KEY` env var if they want this microservice to validate JWTs on DLQ messages, and for providing the correct command line arguments to the microservice when invoking `docker run`