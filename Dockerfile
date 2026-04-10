FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG MIGRATE_VERSION=v4.18.3
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN apk add --no-cache ca-certificates git

WORKDIR /src

RUN git clone --depth 1 --branch "${MIGRATE_VERSION}" https://github.com/golang-migrate/migrate.git .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -tags 'postgres' -o /out/migrate ./cmd/migrate

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

COPY --from=builder /out/migrate /usr/local/bin/migrate
COPY migrations /migrations

WORKDIR /migrations

CMD ["migrate", "-help"]
