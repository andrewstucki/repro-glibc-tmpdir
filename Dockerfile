FROM golang:1.21

# First build the binary on a dynamically linked system that uses glibc
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN CGO_ENABLED=1 go build -tags cgo -o repro-cgo-dynamic .

# Also build the non-cgo binary
RUN CGO_ENABLED=0 go build -o repro-no-cgo .

FROM golang:1.21-alpine

# Now build the binary targeting a static libc like musl
RUN mkdir /app
ADD . /app
WORKDIR /app

RUN apk add gcc musl-dev

RUN CGO_ENABLED=1 go build -tags cgo -ldflags "-linkmode external -extldflags -static" -o repro-cgo-static .

FROM alpine:latest AS setcap

COPY --from=0 /app/repro-cgo-dynamic /usr/local/bin/repro-cgo-dynamic
COPY --from=0 /app/repro-cgo-dynamic /usr/local/bin/repro-cgo-dynamic-setcap
COPY --from=0 /app/repro-no-cgo /usr/local/bin/repro-no-cgo
COPY --from=0 /app/repro-no-cgo /usr/local/bin/repro-no-cgo-setcap
COPY --from=1 /app/repro-cgo-static /usr/local/bin/repro-cgo-static
COPY --from=1 /app/repro-cgo-static /usr/local/bin/repro-cgo-static-setcap

RUN apk add libcap
RUN setcap CAP_NET_BIND_SERVICE=+ep /usr/local/bin/repro-cgo-dynamic-setcap
RUN setcap CAP_NET_BIND_SERVICE=+ep /usr/local/bin/repro-cgo-static-setcap
RUN setcap CAP_NET_BIND_SERVICE=+ep /usr/local/bin/repro-no-cgo-setcap

# Run all of these back on a debian-based system to make sure we can find glibc
FROM golang:1.21

COPY --from=2 /usr/local/bin/repro-cgo-dynamic /usr/local/bin/repro-cgo-dynamic
COPY --from=2 /usr/local/bin/repro-cgo-dynamic-setcap /usr/local/bin/repro-cgo-dynamic-setcap
COPY --from=2 /usr/local/bin/repro-cgo-static /usr/local/bin/repro-cgo-static
COPY --from=2 /usr/local/bin/repro-cgo-static-setcap /usr/local/bin/repro-cgo-static-setcap
COPY --from=2 /usr/local/bin/repro-no-cgo /usr/local/bin/repro-no-cgo
COPY --from=2 /usr/local/bin/repro-no-cgo-setcap /usr/local/bin/repro-no-cgo-setcap

# And drop the user to non-root so ld.so strips out TMPDIR
USER 100