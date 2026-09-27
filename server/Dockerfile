# Floppy Swing game server.
#   docker build -t floppy-server server/
#   docker run -p 8080:8080 -v floppy-data:/data -e ADMIN_TOKEN=change-me floppy-server
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub get --offline && dart compile exe bin/server.dart -o /app/server

FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/server /app/server
ENV DATA_DIR=/data PORT=8080
VOLUME /data
EXPOSE 8080
CMD ["/app/server"]
