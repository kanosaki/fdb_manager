# from: https://github.com/edwardinubuntu/flutter-web-dockerfile
# Environemnt to install flutter and build web
FROM debian:latest AS build-env

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
# we cannot use the stable release until this issue solved in stable: https://github.com/dart-lang/sdk/issues/54446
# but fdb_manager currently cant be built with beta version, so we cannot fdb_manager on Apple Silicon, use linux/amd64 environment, not Rosetta
#ARG FLUTTER_VERSION=beta
ARG FLUTTER_VERSION=3.16.9
ARG APP=/app/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --no-analytics && flutter precache && dart --disable-analytics

# copy source code to folder
COPY . $APP
# stup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter pub get
RUN flutter build web

# once heare the app will be compiled and ready to deploy

FROM golang:latest AS build-agent

ARG fdb_version=7.1.52

WORKDIR /app
RUN curl -LOJ https://github.com/apple/foundationdb/releases/download/${fdb_version}/foundationdb-clients_${fdb_version}-1_amd64.deb
RUN dpkg -i foundationdb-clients_${fdb_version}-1_amd64.deb

COPY agent/go.mod agent/go.sum ./
RUN go mod download && go mod verify

COPY agent .
RUN go build -v -o fdb_manager_agent .

FROM gcr.io/distroless/base

WORKDIR /app
COPY --from=build-agent /app/fdb_manager_agent ./
COPY --from=build-agent /usr/lib/libfdb_c.so /usr/lib/
# NOTE: make client library directory and setup multiversion client?

COPY --from=build-env /app/build/web ./web

EXPOSE 8080
ENTRYPOINT ["/app/fdb_manager_agent"]
