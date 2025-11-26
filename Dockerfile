FROM alpine:3.19

LABEL org.opencontainers.image.source="https://github.com/drunkod/alpine-nix-git-docker" \
      org.opencontainers.image.description="Alpine Linux with Nix package manager and Git" \
      org.opencontainers.image.title="Alpine Nix Git"

# Install base dependencies
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

# Set bash as default shell
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd

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

# Install Nix
RUN curl -L https://nixos.org/nix/install -o /tmp/nix-install.sh \
    && chmod +x /tmp/nix-install.sh \
    && sh /tmp/nix-install.sh --no-daemon \
    && rm /tmp/nix-install.sh \
    && rm -rf /var/cache/apk/*

# Simple universal profile setup - works everywhere
RUN { \
    echo '# Nix environment'; \
    echo '[ -e /root/.nix-profile/etc/profile.d/nix.sh ] && . /root/.nix-profile/etc/profile.d/nix.sh'; \
    echo 'export PATH="$PATH:/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin"'; \
    } | tee /root/.profile /root/.bashrc /root/.bash_profile > /dev/null

# Set environment in Docker layer
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV NIX_PATH="/root/.nix-defexpr/channels"

SHELL ["/bin/bash", "-l", "-c"]
WORKDIR /workspace

# Verify
RUN nix --version && git --version

CMD ["/bin/bash", "-l"]
