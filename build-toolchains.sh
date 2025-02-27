#!/bin/bash
# build-toolchains.sh

# Array of version combinations to build
declare -a versions=(
    # "1.66.0 1.14.18 v0.26.0 butterscotch"
    # "1.75.0 1.18.26 v0.28.0 peanutbrittle"
    "1.75.0 1.18.15 v0.29.0 sugarcookie"
)

for version in "${versions[@]}"; do
    read -r rust_ver sol_ver anchor_ver custom_tag <<< "$version"
    version_tag="${rust_ver}-${sol_ver}-${anchor_ver#v}"
    
    echo "Building toolchain: $version_tag (${custom_tag:-default})"
    
    # Build with version tag
    docker build -t "solana-toolchain:$version_tag" \
        --build-arg RUST_VERSION="$rust_ver" \
        --build-arg SOLANA_VERSION="$sol_ver" \
        --build-arg ANCHOR_VERSION="$anchor_ver" \
        --no-cache \
        .
    
    # If custom tag provided, add it as an additional tag
    if [ -n "$custom_tag" ]; then
        docker tag "solana-toolchain:$version_tag" "solana-toolchain:$custom_tag"
    fi
done
