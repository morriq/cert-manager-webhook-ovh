FROM golang:1.13.6 AS build_deps

RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=1 CC=aarch64-linux-gnu-gcc GOOS=linux GOARCH=arm64 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM multiarch/ubuntu-core:arm64-bionic

COPY --from=build /workspace/webhook .

ENTRYPOINT ["webhook"]
