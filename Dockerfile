FROM alpine:3.19

LABEL org.opencontainers.image.source="https://github.com/drunkod/alpine-nix-git-docker" \
      org.opencontainers.image.description="Alpine Linux with Nix package manager and Git" \
      org.opencontainers.image.title="Alpine Nix Git"

# Install base dependencies including coreutils for GNU cp (required by Nix installer)
RUN apk update && apk add --no-cache \
    bash \
    curl \
    xz \
    git \
    shadow \
    sudo \
    ca-certificates \
    coreutils \
    gzip \
    tar

# Create nix build users
RUN addgroup -S nixbld \
    && for i in $(seq 1 10); do adduser -S -D -H -h /var/empty -s /sbin/nologin -G nixbld nixbld$i; done

# Create nix directories and config
RUN mkdir -p /nix /etc/nix /root/.config/nix \
    && echo 'build-users-group = nixbld' > /etc/nix/nix.conf \
    && echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf \
    && echo 'sandbox = false' >> /etc/nix/nix.conf \
    && echo 'filter-syscalls = false' >> /etc/nix/nix.conf \
    && echo 'experimental-features = flakes nix-command' > /root/.config/nix/nix.conf

# Install Nix using the official installer (single-user mode for Docker)
# The installer requires GNU coreutils for cp --preserve
RUN curl -L https://nixos.org/nix/install -o /tmp/nix-install.sh \
    && chmod +x /tmp/nix-install.sh \
    && sh /tmp/nix-install.sh --no-daemon \
    && rm /tmp/nix-install.sh \
    && rm -rf /var/cache/apk/*

# Setup environment
RUN echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc \
    && echo 'export PATH=$PATH:/root/.nix-profile/bin' >> /root/.bashrc

SHELL ["/bin/bash", "-c"]
WORKDIR /workspace

# Verify installation
# RUN . /root/.nix-profile/etc/profile.d/nix.sh && nix --version && git --version

CMD ["/bin/bash", "-l"]
