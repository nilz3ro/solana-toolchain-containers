#!/bin/bash
# build-toolchains.sh
#

# Cookie names for new tags
# ChocoChip
# OatmealRaisin
# DoubleChocolate
# SugarCookie
# SnickerDoodle
# PeppermintChip
# GrahamCracker
# Shortbread
# PB & J
# ButterscotchChip

# Array of version combinations to build
declare -a versions=(
    # "1.66.0 1.14.18 v0.26.0 butterscotch"
    # "1.75.0 1.18.26 v0.28.0 peanutbrittle"
    # "1.75.0 1.18.26 v0.30.1 chocolate-chip"
    # "1.75.0 2.0.1 v0.30.1 shortbread"
    "1.75.0 2.1.5 v0.30.1 oatmeal-raisin"
)

# Base name for all images
IMAGE_BASE="localhost/solana-toolchain"

for version in "${versions[@]}"; do
    read -r rust_ver sol_ver anchor_ver custom_tag <<< "$version"
    version_tag="${rust_ver}-${sol_ver}-${anchor_ver#v}"
    
    echo "Building toolchain: $version_tag (${custom_tag:-default})"
    
    # Build with version tag
    if podman build -t "${IMAGE_BASE}:${version_tag}" \
        --build-arg RUST_VERSION="$rust_ver" \
        --build-arg SOLANA_VERSION="$sol_ver" \
        --build-arg ANCHOR_VERSION="$anchor_ver" \
        --no-cache \
        .; then
        
        echo "Build successful for ${version_tag}"
        
        # If custom tag provided, add it as an additional tag
        if [ -n "$custom_tag" ]; then
            echo "Adding custom tag: ${custom_tag}"
            podman tag "${IMAGE_BASE}:${version_tag}" "${IMAGE_BASE}:${custom_tag}"
        fi
    else
        echo "Build failed for ${version_tag}"
        exit 1
    fi
    
    echo "----------------------------------------"
done

# Show all images at the end
echo "All solana-toolchain images:"
podman images "${IMAGE_BASE}"