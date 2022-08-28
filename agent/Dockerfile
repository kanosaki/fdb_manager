FROM golang:latest AS build_container

ARG fdb_version=7.1.19

WORKDIR /app
RUN curl -LOJ https://github.com/apple/foundationdb/releases/download/${fdb_version}/foundationdb-clients_${fdb_version}-1_amd64.deb
RUN dpkg -i foundationdb-clients_${fdb_version}-1_amd64.deb

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o fdb_manager_agent ./...

FROM gcr.io/distroless/base

WORKDIR /app
COPY --from=build_container /app/fdb_manager_agent ./
COPY --from=build_container /usr/lib/libfdb_c.so /usr/lib/
# NOTE: make client library directory and setup multiversion client?

ENTRYPOINT ['/app/fdb_manager_agent']
