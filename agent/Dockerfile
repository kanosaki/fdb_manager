FROM golang:latest

ARG fdb_version=6.3.24

WORKDIR /app
RUN curl -LOJ https://github.com/apple/foundationdb/releases/download/${fdb_version}/foundationdb-clients_${fdb_version}-1_amd64.deb
RUN curl -LOJ https://github.com/apple/foundationdb/releases/download/${fdb_version}/foundationdb-server_${fdb_version}-1_amd64.deb
RUN dpkg -i foundationdb-clients_${fdb_version}-1_amd64.deb
RUN dpkg -i foundationdb-server_${fdb_version}-1_amd64.deb

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o fdb_manager_agnet ./...

CMD ['/app/fdb_manager_agent']
