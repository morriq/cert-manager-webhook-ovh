FROM golang:1.13.6-alpine AS build_deps

RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=1 CC=aarch64-linux-gnu-gcc GOOS=linux GOARCH=arm64 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM multiarch/ubuntu-core:arm64-bionic

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook .

ENTRYPOINT ["webhook"]
