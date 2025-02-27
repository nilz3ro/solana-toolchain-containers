# Solana toolchain containers using Docker

```
# Build original version (1.66/1.14.18/0.26.0)
docker build -t solana-toolchain:1.66.0-1.14.18-0.26.0 \
  --build-arg RUST_VERSION=1.66.0 \
  --build-arg SOLANA_VERSION=1.14.18 \
  --build-arg ANCHOR_VERSION=v0.26.0 \
  .
```

current versions:
* `solana-toolchain:1.66.0-1.14.18-0.26.0`
