# Alpine Nix Git Docker Image

![Build Status](https://github.com/google-labs/alpine-nix-git/actions/workflows/docker-build.yml/badge.svg)

Alpine Linux based Docker image with Nix package manager and Git.

## Quick Start

```bash
# Pull image
docker pull ghcr.io/google-labs/alpine-nix-git:latest

# Run interactive shell
docker run -it --rm ghcr.io/google-labs/alpine-nix-git:latest
```

## Usage

```bash
# Inside container, source nix profile first
source /root/.nix-profile/etc/profile.d/nix.sh

# Check versions
nix --version
git --version

# Use nix-shell
nix-shell -p python3 --run "python --version"

# Use nix run (flakes)
nix run nixpkgs#hello
```

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from main branch |
| `vX.Y.Z` | Specific version |
| `sha-xxxxx` | Specific commit |
