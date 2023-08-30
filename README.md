# Build image

```bash
docker build . -t repro
```

# Run the images

```bash
docker-compose run --rm repro-no-cgo && \
docker-compose run --rm repro-no-cgo-setcap && \
docker-compose run --rm repro-cgo-static && \
docker-compose run --rm repro-cgo-static-setcap && \
docker-compose run --rm repro-cgo-dynamic && \
docker-compose run --rm repro-cgo-dynamic-setcap
```

You should see output like the following:

```bash
Temporary Directory: /consul/connect-inject
Temporary Directory: /consul/connect-inject
Temporary Directory: /consul/connect-inject
Temporary Directory: /consul/connect-inject
Temporary Directory: /consul/connect-inject
Temporary Directory: /tmp
```