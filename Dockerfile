FROM debian:latest AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN ./mvnw install -DskipTests

FROM debian:latest AS debian

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/target/ttrpg-convert-cli-* /app/ttrpg-convert-cli.jar
COPY --from=build /app/target/*.xml /app/ttrpg-convert-cli.jar

CMD ["java", "-jar", "/app/ttrpg-convert-cli"]
