FROM debian:latest AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY . /build

RUN ./mvnw install -DskipTests

FROM debian:latest AS debian

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /build/target/ttrpg-convert-cli-*.jar /app/ttrpg-convert-cli.jar
COPY --from=build /build/pom.xml /app/pom.xml
COPY ./docker/ttrpg-convert /usr/local/bin/ttrpg-convert
RUN chmod +x /usr/local/bin/ttrpg-convert

CMD ["ttrpg-convert", "--help"]

FROM alpine:latest AS alpine

RUN apk add --no-cache \
    openjdk17-jre \
    bash \
    libstdc++

WORKDIR /app

COPY --from=build /build/target/ttrpg-convert-cli-*.jar /app/ttrpg-convert-cli.jar
COPY --from=build /build/pom.xml /app/pom.xml
COPY ./docker/ttrpg-convert /usr/local/bin/ttrpg-convert
RUN chmod +x /usr/local/bin/ttrpg-convert

CMD ["ttrpg-convert", "--help"]
